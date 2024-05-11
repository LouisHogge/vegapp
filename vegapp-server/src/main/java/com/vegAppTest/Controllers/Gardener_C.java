
package com.vegAppTest.Controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

import com.vegAppTest.Entities.Gardener;
import com.vegAppTest.Repositories.Gardener_R;
import com.vegAppTest.Security.Service.ControllerService;

@RestController
public class Gardener_C {

    @Autowired
    Gardener_R gardener_repo;

    @Autowired
    ControllerService controller_service;

    @GetMapping("/gardener")
    public ResponseEntity<String> getUser(@RequestHeader("Authorization") String token) {

        Gardener gardener = controller_service.getGardenerFromToken(token);
        return new ResponseEntity<>(
                gardener.getFirst_name() + "," + gardener.getLast_name() + "," + gardener.getEmail(),
                HttpStatus.NOT_FOUND);

    }

    @DeleteMapping("/gardener")
    public void delUser(@RequestHeader("Authorization") String token) {
        gardener_repo.deleteById(controller_service.getGardenerFromToken(token).getId());

    }

}
