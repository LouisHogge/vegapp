package com.vegAppTest.Controllers;

import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

/* Entities  */
import com.vegAppTest.Entities.Sync;
import com.fasterxml.jackson.databind.JsonNode;
/* Repositories */
import com.vegAppTest.Repositories.Sync_R;
import com.vegAppTest.Security.Service.ControllerService;
import com.vegAppTest.Wrapper.RequestData;
import org.springframework.web.bind.annotation.PutMapping;

@RestController
public class Sync_C {

    private final WebClient webClient;

    public Sync_C(WebClient webClient) {
        this.webClient = webClient;
    }

    @Autowired
    Sync_R sync_repo;

    @Autowired
    ControllerService controller_servcice;

    @PostMapping("/sync")
    public ResponseEntity<String> createSync(@RequestHeader("Authorization") String token) {
        /* With token, verify that user exist etc */

        Sync sync = new Sync();
        /* Then, initialize the fields for the synchronization */
        sync.setGardener_id(controller_servcice.getGardenerFromToken(token).getId()); // Hardcoded for now
        sync.setApi_number(0l);
        sync.setApi_response(null);

        try {
            /* If it doesn't already exist, then save the entry in the Database */
            sync_repo.save(sync);
            return ResponseEntity.ok("1");
        } catch (DataIntegrityViolationException ex) {
            /* The sync is ongoing and thus cannot be re-inserted */

            return ResponseEntity.status(HttpStatus.CONFLICT).body("0"); // Already in the DB
        }
    }

    /*
     * Rule :
     * - If an api_number of the request body is equal to the api_number of the DB,
     * then return the API response
     * - If an api_number of the request body is NOT equal to the api_number of the
     * DB, it must be equal to = api_number (from DB) + 1
     * - Any other case are not handled for now and return an error
     */

    @PutMapping("/sync")
    public ResponseEntity<String> updateSync(@RequestHeader("Authorization") String token,
            @RequestBody RequestData request_data) {
        /* Check things with the token */

        System.out.println("We entered HERE");
        if (request_data == null) {
            System.out.println("THE REQUEST DATA IS WRONG");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("-1");
        }

        /* For now, hardcoded for gardener 1 without token */
        Sync sync_db = sync_repo.findSyncByGardenerId(controller_servcice.getGardenerFromToken(token).getId());
        /* First verify that the sync is ongoing */
        if (sync_db == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("No sync is ongoing for this user");
        }

        /*
         * Now that we are sure that the sync is ongoing, compare the api_numbers of the
         * db and the request
         */
        if (request_data.api_number == sync_db.getApi_number()) {
            /*
             * If we are here, this means that the response was lost, and we need to resend
             * it
             */

            return ResponseEntity.status(HttpStatus.OK).body(sync_db.getApi_response());
        }

        if (request_data.api_number == sync_db.getApi_number() + 1) {
            /*
             * If we are here, this means that we received the previous response, and the
             * API request has not been applied yet
             */

            // 1. Apply API request
            MultiValueMap<String, String> headers = new LinkedMultiValueMap<>();

            headers.add("Authenticate", token); // Add the header with token

            ResponseEntity<String> response_entity = applyApiCall(request_data.request_type, request_data.url,
                    request_data.body, token, null, null);
            // 2. Increase api number in DB by 1
            sync_db.setApi_number(sync_db.getApi_number() + 1);

            // 3. Update the response to include the api_number, and request fields. The new
            // forged body is stored and sent to the User
            String updated_body = response_entity.getBody();
            updated_body = "{\"api_number\": " + sync_db.getApi_number() + ",  \"response\": " + updated_body + "}";

            ResponseEntity<String> updated_response_entity = new ResponseEntity<>(updated_body,
                    response_entity.getHeaders(), response_entity.getStatusCode());
            sync_db.setApi_response(updated_body);
            sync_repo.save(sync_db);
            // 4. return the response after saving the sync entity on the DB
            return updated_response_entity;
        }

        /*
         * If we are here, this means there is an unhandled error and we return the
         * online DB api number for debugging purposes
         */
        String error = sync_db.getApi_number().toString();
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                "Unexpected api_number, Received : " + request_data.api_number + " and expected is (+1) :" + error);
    }

    public ResponseEntity<String> applyApiCall(String request_type, String uri,
            JsonNode requestBody, String token,
            MultiValueMap<String, String> pathVariables, MultiValueMap<String, String> requestParams) {

        HttpMethod method;

        /* Retrieve the method from the String */
        switch (request_type) {

            case "get":

                method = HttpMethod.GET;
                break;

            case "post":

                method = HttpMethod.POST;
                break;

            case "put":

                method = HttpMethod.PUT;
                break;

            case "delete":

                method = HttpMethod.DELETE;
                break;

            default:
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body("Unhandled type of HTTP method :" + request_type);
        }

        WebClient.RequestBodySpec requestSpec = webClient
                .method(method)
                .uri(uri)
                .header("Authorization", token);

        // Add request body if it's not null
        if (requestBody != null) {
            requestSpec.body(BodyInserters.fromValue(requestBody));

        }

        return requestSpec.retrieve().toEntity(String.class).block();
    }

    @DeleteMapping("/sync")
    public void DeleteSync(@RequestHeader("Authorization") String token) {

        Sync sync = sync_repo.findSyncByGardenerId(controller_servcice.getGardenerFromToken(token).getId());
        if (sync != null) {
            sync_repo.delete(sync);
        }
    }
}
