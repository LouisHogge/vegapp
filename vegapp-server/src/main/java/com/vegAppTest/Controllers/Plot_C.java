package com.vegAppTest.Controllers;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import org.springframework.beans.factory.annotation.Autowired;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/*   Entities   */
import com.vegAppTest.Entities.Plot;
import com.vegAppTest.Entities.Garden;
import com.vegAppTest.Entities.Gardener;
import com.vegAppTest.Entities.Plant;
import com.vegAppTest.Entities.Veggie;

/*   Repositories   */
import com.vegAppTest.Repositories.Garden_R;
import com.vegAppTest.Repositories.Plot_R;
import com.vegAppTest.Repositories.Plant_R;
import com.vegAppTest.Repositories.Veggie_R;

/*   Services   */
import com.vegAppTest.Security.Service.ControllerService;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;

@RestController
@Validated
public class Plot_C {

    public Plot_C() {

    }

    @Autowired
    Plot_R plot_repo;

    @Autowired
    Garden_R garden_repo;

    @Autowired
    Plant_R plant_repo;

    @Autowired
    Veggie_R veggie_repo;
    @Autowired
    ControllerService controller_service;

    /* ------------------------------ GET METHODS -------------------- */

    // Get endpoints used to display the history on the web interface

    /* To get the plot years of a garden */
    @GetMapping("/plot_years")
    public ResponseEntity<List<Integer>> getPlotYearsByGarden(@RequestHeader("Authorization") String token,
            @RequestParam Long garden_id) {

        Gardener gardener = controller_service.getGardenerFromToken(token);
        // Check if the garden belongs to that gardener
        boolean gardenBelongsToGardener = false;
        for (Garden garden : gardener.getGardens()) {
            if (garden.getId() == garden_id) {
                gardenBelongsToGardener = true;
                break;
            }
        }
        if (gardenBelongsToGardener == false) {
            // The garden does not belong to that gardener
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
        List<Integer> years = plot_repo.findDistinctYears(garden_id);

        if (years.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(years);
    }

    /* To get the plot names of a garden for a year */
    @GetMapping("/plot_names")
    public ResponseEntity<List<String>> getPlotNamesByYear(@RequestHeader("Authorization") String token,
            @RequestParam @Min(1900) @Max(4000) int year, @RequestParam Long garden_id) {
        Gardener gardener = controller_service.getGardenerFromToken(token);
        // Check if the garden belongs to that gardener
        boolean gardenBelongsToGardener = false;
        for (Garden garden : gardener.getGardens()) {
            if (garden.getId() == garden_id) {
                gardenBelongsToGardener = true;
                break;
            }
        }
        if (gardenBelongsToGardener == false) {
            // The garden does not belong to that gardener
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
        List<String> plot_names = plot_repo.findPlotNamesByYear(year, garden_id);

        if (plot_names.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(plot_names);
    }

    /* To get the plot versions of a garden for a year and a plot */
    @GetMapping("/plot_versions")
    public ResponseEntity<List<Integer>> getPlotVersionsByGardenIdYearAndName(
            @RequestHeader("Authorization") String token,
            @RequestParam Long garden_id,
            @RequestParam @Min(1900) @Max(4000) int year,
            @RequestParam @Size(max = 255) String name) {

        Gardener gardener = controller_service.getGardenerFromToken(token);
        // Check if the garden belongs to that gardener
        boolean gardenBelongsToGardener = false;
        for (Garden garden : gardener.getGardens()) {
            if (garden.getId() == garden_id) {
                gardenBelongsToGardener = true;
                break;
            }
        }
        if (gardenBelongsToGardener == false) {
            // The garden does not belong to that gardener
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
        List<Integer> versions = plot_repo.findPlotVersions(garden_id, year, name);

        if (versions.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(versions);
    }

    /* To get the informations necessary to draw a specific plot */
    @GetMapping("/plot/draw")
    public ResponseEntity<List<String>> getPlotDrawingInfo(@RequestHeader("Authorization") String token,
            @RequestParam Long garden_id,
            @RequestParam @Size(max = 255) String name,
            @RequestParam @Min(0) @Max(500) int version) {

        Gardener gardener = controller_service.getGardenerFromToken(token);
        // Check if the garden belongs to that gardener
        boolean gardenBelongsToGardener = false;
        for (Garden garden : gardener.getGardens()) {
            if (garden.getId() == garden_id) {
                gardenBelongsToGardener = true;
                break;
            }
        }
        if (gardenBelongsToGardener == false) {
            // The garden does not belong to that gardener
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
        /* Find the plot */
        Optional<Plot> plott = plot_repo.findByGardenAndNameAndVersion(garden_id, name, version);

        if (plott.isPresent()) {
            Plot plot = plott.get();
            Long plot_id = plot.getId();

            /* Retrieve nb_of_lines and orientation and plants */
            String nb_of_lines = plot.getNb_of_lines();
            int orientation = plot.getOrientation();
            List<Plant> plants = plant_repo.findByPlotId(plot_id);

            /* Put everything in a list */
            List<String> draw_info = new ArrayList<>();
            draw_info.add("nb_of_lines: " + nb_of_lines);
            draw_info.add("orientation: " + orientation);
            for (Plant plant : plants) {
                /* Search the vegetable name */
                Optional<Veggie> veggiee = veggie_repo.findById(plant.getVeggie_id());
                String veggie_name = "";
                if (veggiee.isPresent()) {
                    Veggie veggie = veggiee.get();
                    veggie_name = veggie.getName();
                }

                String plant_info = "Plant ID: " + plant.getId() + ", Veggie ID: " + plant.getVeggie_id()
                        + ", Veggie Name: " + veggie_name + ", Location: " + plant.getVegetable_location();
                draw_info.add(plant_info);
            }

            return ResponseEntity.ok(draw_info);
        } else {

            return ResponseEntity.notFound().build();
        }
    }
    // end of history endpoints

    /* ------------------------------ POST METHODS -------------------- */

    @PostMapping("/plot/{garden_name}")
    public ResponseEntity<?> createPlot(@RequestBody Plot plot, @RequestHeader("Authorization") String token,
            @PathVariable @Size(max = 255) String garden_name) {

        Gardener gardener = controller_service.getGardenerFromToken(token);
        Optional<Garden> garden = garden_repo.findOneByName(gardener.getId(), garden_name);

        /* Manually check constraints for Plot fields */

        if (plot.getVersion() < 0 || plot.getVersion() > 2000) {
            return ResponseEntity.badRequest().body("Version should be between 0 and 2000");
        }

        if (!(plot.getOrientation() == 0 || plot.getOrientation() == 1)) {
            return ResponseEntity.badRequest().body("Orientation should be either 0 or 1");
        }

        if (!(plot.getIn_calendar() == 0 || plot.getIn_calendar() == 1)) {
            return ResponseEntity.badRequest().body("In_calendar should be either 0 or 1");
        }

        /* End of constraints */

        // If no garden -> cant create the plot
        if (!garden.isPresent()) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }

        Optional<Plot> plot_tmp = plot_repo.findByGardenAndNameAndVersion(garden.get().getId(), plot.getName(),
                plot.getVersion());

        if (plot_tmp.isPresent()) {
            return new ResponseEntity<>(new Plot(), HttpStatus.CONFLICT);
        }

        plot.setGarden(garden.get());
        plot_repo.save(plot);
        return ResponseEntity.status(HttpStatus.CREATED).body(plot);
    }

    /* ------------------------------ PUT METHODS -------------------- */

    @PutMapping("/plot/{garden_name}/{plot_name_old}")
    public ResponseEntity<?> modifyPlot(@RequestBody Plot plot, @RequestHeader("Authorization") String token,
            @PathVariable @Size(max = 255) String garden_name, @PathVariable @Size(max = 255) String plot_name_old) {

        Gardener gardener = controller_service.getGardenerFromToken(token);

        /* Manually check constraints for Plot fields */

        if (plot.getVersion() < 0 || plot.getVersion() > 2000) {
            return ResponseEntity.badRequest().body("Version should be between 0 and 2000");
        }

        if (!(plot.getOrientation() == 0 || plot.getOrientation() == 1)) {
            return ResponseEntity.badRequest().body("Orientation should be either 0 or 1");
        }

        if (!(plot.getIn_calendar() == 0 || plot.getIn_calendar() == 1)) {
            return ResponseEntity.badRequest().body("In_calendar should be either 0 or 1");
        }

        /* End of constraints */

        Optional<Garden> garden = garden_repo.findOneByName(gardener.getId(), garden_name);
        Plot plot_new = new Plot();
        String name = plot.getName();

        // If no garden -> cant create the plot
        if (!garden.isPresent()) {
            return new ResponseEntity<>(new Plot(), HttpStatus.NOT_FOUND);
        }

        Optional<Plot> plot_old = plot_repo.findByGardenAndNameAndVersion(garden.get().getId(), plot_name_old,
                plot.getVersion());

        if (plot_old.isPresent()) {

            plot_new = plot_old.get();
            plot_new.setName(name);
            plot_new.setNote(plot.getNote());
            plot_repo.save(plot_new);

            return new ResponseEntity<>(plot, HttpStatus.OK);
        }

        return new ResponseEntity<>(new Plot(), HttpStatus.NOT_FOUND);
    }

    /* ------------------------------ DELETE METHODS -------------------- */

    @DeleteMapping("/plot/{garden_name}/{plot_name}")
    public  ResponseEntity<Plot> DeletePlot(@RequestHeader("Authorization") String token,
            @PathVariable @Size(max = 255) String garden_name, @PathVariable @Size(max = 255) String plot_name) {

        Gardener gardener = controller_service.getGardenerFromToken(token);
        Optional<Garden> garden = garden_repo.findOneByName(gardener.getId(), garden_name);
        // If no garden -> cant delete the plot
        if (!garden.isPresent()) {
            return new ResponseEntity<>(new Plot(), HttpStatus.OK);
        }
        plot_repo.deleteByGardenGardenerAndName(gardener.getId(), garden.get().getId(), plot_name);
        return new ResponseEntity<>(new Plot(), HttpStatus.OK);
    }

}