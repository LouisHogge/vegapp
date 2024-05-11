package com.vegAppTest.Controllers;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.data.crossstore.ChangeSetPersister.NotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/*   Entities   */
import com.vegAppTest.Entities.Role;
import com.vegAppTest.Entities.Garden;
import com.vegAppTest.Entities.Gardener;

/*   Repositories   */
import com.vegAppTest.Repositories.Role_R;
import com.vegAppTest.Repositories.Garden_R;
import com.vegAppTest.Repositories.Gardener_R;
/*   Services   */
import com.vegAppTest.Security.Service.ControllerService;

@RestController
public class Role_C {

    @Autowired
    Role_R role_repo;

    @Autowired
    Garden_R garden_repo;

    @Autowired
    Gardener_R gardener_repo;

    @Autowired
    ControllerService controller_servcice;

    /* ------------------------------ POST METHODS -------------------- */
    /* To create a role */
    @PostMapping("/role")
    public ResponseEntity<Role> createRole(@RequestHeader("Authorization") String token,
            @RequestBody Role role) throws NotFoundException {

        // Check constraints on role fields
        if (role.getGarden_id() == null || role.getGardener_id() == null
                || (role.getRole() != 1 && role.getRole() != 2)) {
            return new ResponseEntity<>(new Role(), HttpStatus.BAD_REQUEST);
        }
        // Verify that the garden and the gardener given in the body exist
        Optional<Garden> garden = garden_repo.findById(role.getGarden_id());
        Optional<Gardener> gardener = gardener_repo.findById(role.getGardener_id());
        if (garden.isPresent() && gardener.isPresent()) {
            role_repo.save(role);
            return new ResponseEntity<>(role, HttpStatus.OK);
        }
        // If not, return a null
        return new ResponseEntity<>(new Role(), HttpStatus.OK);
    }

    /* ------------------------------ DELETE METHODS -------------------- */
    @DeleteMapping("/role")
    public ResponseEntity<?> delRole(@RequestHeader("Authorization") String token, @RequestParam Long garden_id,
            @RequestParam Long gardener_id, @RequestParam int role) {

        // Check constraints on role fields
        if (garden_id == null || gardener_id == null || (role != 1 && role != 2)) {
            return new ResponseEntity<>(new Role(), HttpStatus.BAD_REQUEST);
        }

        role_repo.deleteByGardenIdAndGardenerId(garden_id, gardener_id, role);
        return ResponseEntity.ok().build();
    }
}