package com.vegAppTest.Controllers;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.data.crossstore.ChangeSetPersister.NotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;

import org.springframework.web.bind.annotation.RestController;

/*   Entities   */
import com.vegAppTest.Entities.Garden;
import com.vegAppTest.Entities.Gardener;

/*   Repositories   */
import com.vegAppTest.Repositories.Garden_R;

/*   Services   */
import com.vegAppTest.Security.Service.ControllerService;

/*   Validation  */
import jakarta.validation.constraints.Size;

@RestController
@Validated
public class Garden_C {

    @Autowired
    Garden_R garden_repo;

    @Autowired
    ControllerService controller_servcice;

    @Autowired
    CategoryPrimary_C primary_C;

    /* ------------------------------ GET METHODS -------------------- */

    /* To get all gardens from DB */
    @GetMapping("/garden")
    public ResponseEntity<List<Garden>> getAllGarden(@RequestHeader("Authorization") String token) {

        return new ResponseEntity<>(garden_repo.findAllByGardenerId(
                controller_servcice
                        .getGardenerFromToken(token)
                        .getId()),
                HttpStatus.OK);
    }

    /* To get a specific garden from DB */
    @GetMapping("/garden/{name}")
    public ResponseEntity<Garden> getGarden(@RequestHeader("Authorization") String token,
            @PathVariable @Size(max = 255) String name) {

        Gardener gardener = controller_servcice.getGardenerFromToken(token);

        if (name == null) {
            return new ResponseEntity<>(new Garden(), HttpStatus.BAD_REQUEST);
        }
        /* First check DB if object exist */
        Optional<Garden> garden_optional = garden_repo.findOneByName(gardener.getId(), name);
        if (garden_optional.isPresent()) {
            /* If exist, then fetch and send it */
            return new ResponseEntity<>(garden_optional.get(), HttpStatus.OK);
        }
        /* If not, send error */
        return new ResponseEntity<>(new Garden(), HttpStatus.NOT_FOUND);
    }

    /* ------------------------------ POST METHODS -------------------- */
    /* To create a garden */
    @PostMapping("/garden")
    public Garden createGarden(@RequestHeader("Authorization") String token,
            @RequestBody Garden garden) throws NotFoundException {

        Gardener gardener = controller_servcice.getGardenerFromToken(token);
        if (garden.getName() == null) {
            return null;
        }
/* Add primary categories */
        garden.setGardener(gardener);
        garden_repo.save(garden);
        primary_C.addPrimaryCategories(garden);
        return garden;

    }

    /* ------------------------------ PUT METHODS -------------------- */
    @PutMapping("/garden")
    public ResponseEntity<Garden> changeGarden(@RequestHeader("Authorization") String token,
            @RequestBody Garden garden) throws NotFoundException {

        Optional<Garden> tmp = garden_repo.findById(garden.getId());
        if (tmp.isPresent()) {
            Garden updated_garden = tmp.get();
            updated_garden.setName(garden.getName());
            garden_repo.save(updated_garden);
            return new ResponseEntity<>(updated_garden, HttpStatus.OK);
        }
        return new ResponseEntity<>(new Garden(), HttpStatus.NOT_FOUND);

    }

    /* ------------------------------ DELETE METHODS -------------------- */

    @DeleteMapping("/garden/{garden_id}")
    public void delGarden(@RequestHeader("Authorization") String token, @PathVariable Long garden_id) {
        garden_repo.deleteById(garden_id);
        return;
    }

}
