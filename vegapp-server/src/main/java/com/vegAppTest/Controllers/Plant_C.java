package com.vegAppTest.Controllers;

import java.util.List;
import java.util.Optional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

import com.vegAppTest.Entities.Plot;
import com.vegAppTest.Entities.Plant;
import com.vegAppTest.Entities.Garden;
import com.vegAppTest.Entities.Gardener;

import com.vegAppTest.Repositories.Garden_R;
import com.vegAppTest.Repositories.Plot_R;
import com.vegAppTest.Repositories.Plant_R;
import com.vegAppTest.Repositories.Veggie_R;
import com.vegAppTest.Security.Service.ControllerService;

import jakarta.validation.constraints.Size;

@RestController
@Validated
public class Plant_C {

    public Plant_C() {
    }

    @Autowired
    Plant_R plant_repo;

    @Autowired
    Plot_R plot_repo;

    @Autowired
    Veggie_R veggie_repo;

    @Autowired
    ControllerService controller_service;

    @Autowired
    Garden_R garden_repo;

    /* ------------------------------ POST METHODS -------------------- */

    @PostMapping("/plant/{plot_name}/{vegetable_location}/{veggie_name}/{garden_name}/{version}")
    public ResponseEntity<Plant> createPlant(@RequestHeader("Authorization") String token,
            @PathVariable @Size(max = 255) String garden_name,
            @PathVariable @Size(max = 255) String vegetable_location, @PathVariable @Size(max = 255) String plot_name,
            @PathVariable @Size(max = 255) String veggie_name,
            @PathVariable Long version) {

        Gardener gardener = controller_service.getGardenerFromToken(token);

        Optional<Garden> garden = garden_repo.findOneByName(gardener.getId(), garden_name);
        if (!garden.isPresent()) {
            return new ResponseEntity<>(new Plant(), HttpStatus.NOT_FOUND);
        }
        Plot plot = null;
        for(Plot plot_loop : garden.get().getPlots()){
            if(plot_loop.getName().equals(plot_name) && plot_loop.getVersion() == version){
                plot = plot_loop;
                break;
            }
        }

        if (plot == null){
            return new ResponseEntity<>(new Plant(), HttpStatus.NOT_FOUND);
        }

        Plant plant = new Plant();
        plant.setVegetable_location(vegetable_location);

        Optional<Long> veggie = veggie_repo.findVeggieIdByVeggieNameAndGardenId(veggie_name, garden.get().getId());
        if (!veggie.isPresent()) {
            System.out.println("VEGGIE PAS TROUVE   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            return new ResponseEntity<>(new Plant(), HttpStatus.NOT_FOUND);
        }
        plant.setPlotId(plot.getId());
        plant.setVegetableId(veggie.get());

        plant_repo.save(plant);

        return new ResponseEntity<>(new Plant(), HttpStatus.CREATED);
    }

    /* ------------------------------ DELETE METHODS -------------------- */
    /* Delete the plants of a plot */
    @DeleteMapping("/plants/{plot_id}")
    public ResponseEntity<Plant> deletePlantsOfAPlot(@RequestHeader("Authorization") String token,
            @PathVariable Long plot_id) {

        List<Plant> plants = plant_repo.findByPlotId(plot_id);
        if (!plants.isEmpty()) {
            plant_repo.deleteAll(plants);
        }

        return new ResponseEntity<>(new Plant(), HttpStatus.OK);
    }
}
