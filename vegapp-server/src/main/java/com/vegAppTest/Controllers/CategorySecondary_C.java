package com.vegAppTest.Controllers;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.data.crossstore.ChangeSetPersister.NotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

/*   Entities   */
import com.vegAppTest.Entities.CategorySecondary;
import com.vegAppTest.Entities.Garden;
import com.vegAppTest.Entities.Gardener;
import com.vegAppTest.Entities.Veggie;
/*   Repositories   */
import com.vegAppTest.Repositories.CategorySecondary_R;
import com.vegAppTest.Repositories.Garden_R;
import com.vegAppTest.Repositories.Veggie_R;
/*   Services   */
import com.vegAppTest.Security.Service.ControllerService;

import jakarta.validation.constraints.Size;

@RestController
@Validated
public class CategorySecondary_C {

    @Autowired
    CategorySecondary_R category_secondary_repo;

    @Autowired
    ControllerService controller_servcice;

    @Autowired
    Garden_R garden_repo;

    @Autowired
    Veggie_R veggie_repo;

    /* ------------------------------ POST METHODS -------------------- */
    /* To create a category */
    @PostMapping("/categorySecondary/{garden_name}")
    public ResponseEntity<CategorySecondary> createCat(@RequestHeader("Authorization") String token,
            @RequestBody CategorySecondary category_secondary,
            @PathVariable @Size(max = 255) String garden_name) throws NotFoundException {

        Gardener gardener = controller_servcice.getGardenerFromToken(token);

        // Verify is Category body is correctly initialized
        if (category_secondary.getName() == null || garden_name == null) {
            return new ResponseEntity<>(new CategorySecondary(), HttpStatus.BAD_REQUEST);
        }

        // Verify that this garden exists for this User.
        Optional<Garden> garden = garden_repo.findOneByName(gardener.getId(), garden_name);
        if (garden.isPresent()) {

            /* Check if the category exists */
            Optional<CategorySecondary> category_secondary_opt = category_secondary_repo
                    .findByGardenerIdAndCategoryName(
                            controller_servcice
                                    .getGardenerFromToken(token)
                                    .getId(),
                            category_secondary.getName());
            if (category_secondary_opt.isPresent()) {

                // If it is present, we send an error code stating that it already exists.
                return new ResponseEntity<>(new CategorySecondary(), HttpStatus.CONFLICT);

            }
            // if not
            category_secondary.setGarden(garden.get());
            category_secondary_repo.save(category_secondary);
            return new ResponseEntity<>(category_secondary, HttpStatus.OK);
        }
        // If the garden doesnt exist, return a null
        return new ResponseEntity<>(new CategorySecondary(), HttpStatus.NOT_FOUND);

    }

    /* ------------------------------ PUT METHODS -------------------- */
    @PutMapping("/categorySecondary/{garden_name}/{category_name}")
    ResponseEntity<CategorySecondary> modifyCat(@RequestHeader("Authorization") String token,
            @RequestBody CategorySecondary category_secondary,
            @PathVariable @Size(max = 255) String garden_name, @PathVariable @Size(max = 255) String category_name) {

        Gardener gardener = controller_servcice.getGardenerFromToken(token);

        if (category_secondary.getName() == null || garden_name == null) {
            return new ResponseEntity<>(new CategorySecondary(), HttpStatus.BAD_REQUEST);
        }
        // Verify that this garden exists for this User.
        Optional<Garden> garden = garden_repo.findOneByName(gardener.getId(), garden_name);

        if (garden.isPresent()) {

            /* Check if the category exists */
            Optional<CategorySecondary> category_secondary_opt = category_secondary_repo
                    .findByGardenerIdAndCategoryName(
                            controller_servcice
                                    .getGardenerFromToken(token)
                                    .getId(),
                            category_name);
            if (category_secondary_opt.isPresent()) {

                // If it is present, we send an error code stating that it already exists.

                category_secondary_repo.updatePropertyById(category_secondary_opt.get().getId(),
                        category_secondary.getName(),
                        category_secondary.getColor());

                return new ResponseEntity<>(category_secondary, HttpStatus.OK);

            }
            // if not, we can't change it
            return new ResponseEntity<>(new CategorySecondary(), HttpStatus.NOT_FOUND);
        }

        return new ResponseEntity<>(new CategorySecondary(), HttpStatus.NOT_FOUND);
    }

    /* ------------------------------ DELETE METHODS -------------------- */
    @DeleteMapping("/categorySecondary/{category_name}/{garden_name}")
    public ResponseEntity<CategorySecondary> delCat(@RequestHeader("Authorization") String token,
            @PathVariable @Size(max = 255) String category_name,
            @PathVariable @Size(max = 255) String garden_name) {

        CategorySecondary parent = category_secondary_repo.findByGardenerIdCategoryNameGardenName(
                controller_servcice.getGardenerFromToken(token).getId(),
                category_name,
                garden_name).orElse(null);

        for (Veggie child : parent.getVeggies()) {
            // Remove or nullify the reference to the parent in the child entity
            child.setCategory_secondary(null); // Assuming there is a setter method to set the parent to
                                               // null
            // Save the child entity to update the changes
            veggie_repo.save(child);
        }
        category_secondary_repo.delete(parent);

        return new ResponseEntity<>(new CategorySecondary(), HttpStatus.OK);
    }
}