package com.vegAppTest.Controllers;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.beans.factory.annotation.Value;
import java.net.URI;
import org.springframework.http.MediaType;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@RestController
public class ArtifactRedirect_C {

    @Value("${gitlab.api.token}")
    private String gitlabApiToken;

    @Value("${gitlab.project.id}")
    private String projectId; // Use project ID directly

    private final String gitLabBaseURL = "https://gitlab.uliege.be";

    @GetMapping("/latest-artifact")
    public ResponseEntity<String> redirectLatestArtifact() {
        try {
            final String jobName = "frontend_build_apk"; // Specify the desired job name
            final int perPage = 100; // Adjust based on project's activity
            int page = 1;

            RestTemplate restTemplate = new RestTemplate();
            ObjectMapper mapper = new ObjectMapper();
            HttpHeaders headers = new HttpHeaders();
            headers.set("PRIVATE-TOKEN", gitlabApiToken);
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<String> entity = new HttpEntity<>(headers);

            boolean jobFound = false;
            String artifactUrl = "";

            while (!jobFound) {
                String jobsUrl = String.format(
                        "%s/api/v4/projects/3958/jobs?scope[]=success&per_page=%d&page=%d&ref=main", gitLabBaseURL,
                        perPage, page);
                ResponseEntity<String> response = restTemplate.exchange(jobsUrl, HttpMethod.GET, entity, String.class);
                JsonNode jobs = mapper.readTree(response.getBody());

                if (jobs.isArray() && jobs.size() > 0) {
                    for (JsonNode job : jobs) {
                        if (job.get("name").asText().equals(jobName) && job.has("artifacts_file")) {
                            long jobId = job.get("id").asLong();
                            artifactUrl = String.format("%s/%s/-/jobs/%d/artifacts/download", gitLabBaseURL, projectId,
                                    jobId);
                            jobFound = true;
                            break;
                        }
                    }
                    page++;
                } else {
                    // No more jobs or no jobs on this page
                    break;
                }
            }

            if (jobFound) {
                return ResponseEntity.status(HttpStatus.FOUND).location(URI.create(artifactUrl)).build();
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("No suitable job found.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}