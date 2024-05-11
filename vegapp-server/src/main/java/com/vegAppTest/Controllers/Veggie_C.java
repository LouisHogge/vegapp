package com.vegAppTest.Controllers;

import java.util.Optional;
import java.util.Arrays;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.crossstore.ChangeSetPersister.NotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

/*   Entities   */
import com.vegAppTest.Entities.CategoryPrimary;
import com.vegAppTest.Entities.CategorySecondary;
import com.vegAppTest.Entities.Gardener;
import com.vegAppTest.Entities.Veggie;

/*   Repositories   */
import com.vegAppTest.Repositories.CategoryPrimary_R;
import com.vegAppTest.Repositories.CategorySecondary_R;
import com.vegAppTest.Repositories.Garden_R;
import com.vegAppTest.Repositories.Veggie_R;
import com.vegAppTest.Repositories.Plot_R;
import com.vegAppTest.Repositories.Plant_R;

/*   Services   */
import com.vegAppTest.Security.Service.ControllerService;

/*   Validation  */
import org.springframework.validation.annotation.Validated;
import jakarta.validation.constraints.Size;

@RestController
@Validated
public class Veggie_C {

    @Autowired
    Veggie_R veggie_repo;

    @Autowired
    CategorySecondary_R category_secondary_repo;

    @Autowired
    CategoryPrimary_R category_primary_repo;

    @Autowired
    Plot_R plot_repo;

    @Autowired
    Plant_R plant_repo;

    @Autowired
    Garden_R garden_repo;

    @Autowired
    CategoryPrimary_R category_primary;

    @Autowired
    ControllerService controller_service;

    /* ------------------------------ POST METHODS -------------------- */

    @PostMapping("/vegetable/{category_primary_name}/{garden_name}/{category_secondary_name}")
    public ResponseEntity<?> createVeg(@PathVariable @Size(max = 255) String category_primary_name,
            @PathVariable @Size(max = 255) String garden_name, @RequestBody Veggie veggie,
            @PathVariable @Size(max = 255) String category_secondary_name,
            @RequestHeader("Authorization") String token) throws NotFoundException {

        Gardener gardener = controller_service.getGardenerFromToken(token);

        CategoryPrimary category_primary = category_primary_repo.findByGardenerIdCategoryNameGardenName(
                gardener.getId(), category_primary_name, garden_name).get();

        veggie.setCategory_primary(category_primary);

        /* Manually check constraints for Veggie fields */

        if (!(veggie.getSeed_availability() == 0 || veggie.getSeed_availability() == 1)) {
            return ResponseEntity.badRequest().body("Seed_avaibility is either 0 or 1");
        }

        if (veggie.getSeed_availability() == 1) {
            if (veggie.getSeed_expiration() < 1900 || veggie.getSeed_expiration() > 9999) {
                return ResponseEntity.badRequest().body("Seed expiration year must be a valid 4-digit number");
            }
        }

        if (veggie.getHarvest_start() < 0 || veggie.getHarvest_start() > 52) {
            return ResponseEntity.badRequest().body("Harvest start week must be between 0 and 52");
        }

        if (veggie.getHarvest_end() < 0 || veggie.getHarvest_end() > 52) {
            return ResponseEntity.badRequest().body("Harvest end week must be between 0 and 52");
        }

        if (!isValidMonth(veggie.getPlant_start()) || !isValidMonth(veggie.getPlant_end())) {
            return ResponseEntity.badRequest().body("Invalid month format");
        }

        /* End of constraints */

        Optional<CategorySecondary> category_secondary;
        Optional<Veggie> veg;
        Long category_s = 0l;
        if (!category_secondary_name.equals("null")) {
            category_secondary = category_secondary_repo
                    .findByGardenerIdCategoryNameGardenName(gardener.getId(), category_secondary_name, garden_name);

            if (category_secondary.isPresent()) {
                /* Add the catalogue secondary if found */
                veggie.setCategory_secondary(category_secondary.get());
                category_s = category_secondary.get().getId();

                veg = veggie_repo.veggieExistSecondary(veggie.getCategory_primary().getId(),
                        category_s, veggie.getName());

                if (veg.isPresent()) {
                    return new ResponseEntity<>(HttpStatus.CONFLICT);
                }
                veggie_repo.save(veggie);
                return ResponseEntity.status(HttpStatus.CREATED).body(veggie);
            }
        }
        veg = veggie_repo.veggieExistNoSecondary(veggie.getCategory_primary().getId(),
                veggie.getName());

        if (veg.isPresent()) {
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
        veggie_repo.save(veggie);
        return ResponseEntity.status(HttpStatus.CREATED).body(veggie);

    }

    /* Intermediate function to check if a month is valid */
    private boolean isValidMonth(String month) {
        if (month == null) {
            return false;
        }
        return Arrays.asList("Jan.", "Feb.", "March", "April", "May", "June",
                "July", "Aug.", "Sept.", "Oct.", "Nov.", "Dec.").contains(month);
    }

    /* ------------------------------ PUT METHODS -------------------- */

    @PutMapping("/vegetable/{garden_name}/{category_primary_name_new}/{category_secondary_name_new}/{veggie_name}/{category_primary_name_old}/{category_secondary_name_old}")
    public ResponseEntity<?> modifyVeggie(@PathVariable @Size(max = 255) String garden_name,
            @PathVariable @Size(max = 255) String category_primary_name_new,
            @PathVariable @Size(max = 255) String category_secondary_name_new,
            @RequestBody Veggie veggie, @PathVariable @Size(max = 255) String veggie_name,
            @PathVariable @Size(max = 255) String category_primary_name_old,
            @PathVariable @Size(max = 255) String category_secondary_name_old,
            @RequestHeader("Authorization") String token) {

        Gardener gardener = controller_service.getGardenerFromToken(token);

        /* Manually check constraints for Veggie fields */

        if (!(veggie.getSeed_availability() == 0 || veggie.getSeed_availability() == 1)) {
            return ResponseEntity.badRequest().body("Seed_avaibility is either 0 or 1");
        }

        if (veggie.getSeed_availability() == 1) {
            if (veggie.getSeed_expiration() < 1900 || veggie.getSeed_expiration() > 9999) {
                return ResponseEntity.badRequest().body("Seed expiration year must be a valid 4-digit number");
            }
        }

        if (veggie.getHarvest_start() < 0 || veggie.getHarvest_start() > 52) {
            return ResponseEntity.badRequest().body("Harvest start week must be between 0 and 52");
        }

        if (veggie.getHarvest_end() < 0 || veggie.getHarvest_end() > 52) {
            return ResponseEntity.badRequest().body("Harvest end week must be between 0 and 52");
        }

        if (!isValidMonth(veggie.getPlant_start()) || !isValidMonth(veggie.getPlant_end())) {
            return ResponseEntity.badRequest().body("Invalid month format");
        }

        /* End of constraints */

        CategoryPrimary category_primary_new = category_primary_repo.findByGardenerIdCategoryNameGardenName(
                gardener.getId(), category_primary_name_new, garden_name).get();

        CategoryPrimary category_primary_old = category_primary_repo.findByGardenerIdCategoryNameGardenName(
                gardener.getId(), category_primary_name_old, garden_name).get();

        Optional<CategorySecondary> category_secondary_old;
        Optional<CategorySecondary> category_secondary_new;
        CategorySecondary updated_secondary = null;
        Optional<Veggie> veg;
        // first check if the new category secondary exist
        // first check if the new category secondary exist
        if (!category_secondary_name_new.equals("null")) {
            category_secondary_new = category_secondary_repo
                    .findByGardenerIdCategoryNameGardenName(gardener.getId(), category_secondary_name_new, garden_name);
            if (category_secondary_new.isPresent()) {
                updated_secondary = category_secondary_new.get();
            }
        }

        if (!category_secondary_name_old.equals("null")) {
            category_secondary_old = category_secondary_repo
                    .findByGardenerIdCategoryNameGardenName(gardener.getId(), category_secondary_name_old, garden_name);

            if (category_secondary_old.isPresent()) {
                /* Check if the veggie exist with that secondary cat */
                veg = veggie_repo.veggieExistSecondary(category_primary_old.getId(),
                        category_secondary_old.get().getId(), veggie_name);

                if (veg.isPresent()) {

                    // update the veggie
                    // update the veggie
                    Veggie updated_veggie = veg.get();
                    updated_veggie.setName(veggie.getName());
                    updated_veggie.setHarvest_start(veggie.getHarvest_start());
                    updated_veggie.setHarvest_end(veggie.getHarvest_end());
                    updated_veggie.setNote(veggie.getNote());
                    updated_veggie.setPlant_start(veggie.getPlant_start());
                    updated_veggie.setPlant_end(veggie.getPlant_end());
                    updated_veggie.setSeed_availability(veggie.getSeed_availability());
                    updated_veggie.setSeed_expiration(veggie.getSeed_expiration());
                    updated_veggie.setCategory_primary(category_primary_new);
                    updated_veggie.setCategory_secondary(updated_secondary);
                    if (updated_secondary != null) {
                        updated_veggie.setCategory_secondary_id(updated_secondary.getId());
                    }
                    if (updated_secondary != null) {
                        updated_veggie.setCategory_secondary_id(updated_secondary.getId());
                    }
                    veggie_repo.save(updated_veggie);
                    return new ResponseEntity<>(updated_veggie, HttpStatus.OK);
                }
            }
            return new ResponseEntity<>(new Veggie(), HttpStatus.NOT_FOUND);
        }
        veg = veggie_repo.veggieExistNoSecondary(category_primary_old.getId(),
                veggie_name);

        if (veg.isPresent()) {
            Veggie updated_veggie = veg.get();
            updated_veggie.setName(veggie.getName());
            updated_veggie.setHarvest_start(veggie.getHarvest_start());
            updated_veggie.setHarvest_end(veggie.getHarvest_end());
            updated_veggie.setNote(veggie.getNote());
            updated_veggie.setPlant_start(veggie.getPlant_start());
            updated_veggie.setPlant_end(veggie.getPlant_end());
            updated_veggie.setSeed_availability(veggie.getSeed_availability());
            updated_veggie.setSeed_expiration(veggie.getSeed_expiration());
            updated_veggie.setCategory_primary(category_primary_new);
            updated_veggie.setCategory_secondary(updated_secondary);
            veggie_repo.save(updated_veggie);
            return new ResponseEntity<>(updated_veggie, HttpStatus.OK);
        }
        return new ResponseEntity<>(new Veggie(), HttpStatus.NOT_FOUND);

    }

    /* ------------------------------ DELETE METHODS -------------------- */
    @DeleteMapping("/vegetable/{veggie_name}/{category_primary_name}/{garden_name}/{category_secondary_name}")
    public void delVeg(@PathVariable @Size(max = 255) String category_primary_name,
            @PathVariable @Size(max = 255) String garden_name, @PathVariable @Size(max = 255) String veggie_name,
            @PathVariable @Size(max = 255) String category_secondary_name,
            @RequestHeader("Authorization") String token) {

        Gardener gardener = controller_service.getGardenerFromToken(token);
        CategoryPrimary category_primary = category_primary_repo.findByGardenerIdCategoryNameGardenName(
                gardener.getId(), category_primary_name, garden_name).get();

        System.out.println(category_secondary_name);

        if (!category_secondary_name.equals("null")) {
            CategorySecondary category_secondary = category_secondary_repo
                    .findByGardenerIdCategoryNameGardenName(gardener.getId(), category_secondary_name, garden_name)
                    .get();
            Optional<Veggie> veggie = veggie_repo.veggieExistSecondary(category_primary.getId(),
                    category_secondary.getId(),
                    veggie_name);

            if (veggie.isPresent()) {
                veggie_repo.delete(veggie.get());
            }
            return;
        }

        Optional<Veggie> veggie = veggie_repo.veggieExistNoSecondary(category_primary.getId(),
                veggie_name);

        if (veggie.isPresent()) {
            veggie_repo.delete(veggie.get());
        }
    }

}