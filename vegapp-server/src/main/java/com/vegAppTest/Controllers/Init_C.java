package com.vegAppTest.Controllers;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;

import org.springframework.web.bind.annotation.RestController;

import com.vegAppTest.Entities.CategoryPrimary;
/*   Entities   */
import com.vegAppTest.Entities.Garden;
import com.vegAppTest.Entities.Plot;
import com.vegAppTest.Repositories.CategoryPrimary_R;
import com.vegAppTest.Repositories.CategorySecondary_R;
/*   Repositories   */
import com.vegAppTest.Repositories.Garden_R;
import com.vegAppTest.Repositories.Plant_R;
import com.vegAppTest.Repositories.Plot_R;
import com.vegAppTest.Repositories.Veggie_R;
/*   Services   */
import com.vegAppTest.Security.Service.ControllerService;
import com.vegAppTest.Wrapper.InitResponse;

@RestController
public class Init_C {

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
    ControllerService controller_service;

    @GetMapping("/init")
    public ResponseEntity<InitResponse> retrieveAllData(@RequestHeader("Authorization") String token) {

        InitResponse init_response = new InitResponse();

        /* Retrieve all garden based on the gardener id */
        init_response.setGarden_list(
                garden_repo.findAllByGardenerId(controller_service.getGardenerFromToken(token).getId()));

        /* Retrieve all primary & secondary cat & plots based on each garden id */
        for (Garden garden_loop : init_response.getGarden_list()) {
            init_response.addCategoryPrimary(category_primary_repo.findByGardenId(garden_loop.getId()),
                    garden_loop.getId());
            init_response.addCategorySecondary(category_secondary_repo.findByGardenId(garden_loop.getId()),
                    garden_loop.getId());
            init_response.addPlot(plot_repo.findByGardenId(garden_loop.getId()), garden_loop.getId());
        }

        /* Retrive all veggies from the primary category id */
        for (CategoryPrimary category_loop : init_response.getCategory_primary_list()) {
            init_response.addVegetable(veggie_repo.findByCategoryPrimaryId(category_loop.getId()),
                    category_loop.getId(), category_loop.getGarden_id());
        }

        /* Retrieve all planted veggies from a plot id */
        for (Plot plot_loop : init_response.getPlot_list()) {
            init_response.addPlant(plant_repo.findByPlotId(plot_loop.getId()));
        }

        return new ResponseEntity<>(init_response, HttpStatus.OK);
    }

    @GetMapping("/init/{garden_id}")
    public ResponseEntity<InitResponse> retrieveGardenData(@RequestHeader("Authorization") String token,
            @PathVariable Long garden_id) {

        InitResponse init_response = new InitResponse();

        Optional<Garden> tmp = garden_repo.findById(garden_id);
        if (!tmp.isPresent()) {
            return new ResponseEntity<>(new InitResponse(), HttpStatus.NOT_FOUND);
        }

        Garden garden = tmp.get();
        if (!garden_repo.findOneByName(controller_service.getGardenerFromToken(token).getId(), garden.getName())
                .isPresent()) {
            return new ResponseEntity<>(new InitResponse(), HttpStatus.NOT_FOUND);
        }

        /* Retrieve all primary & secondary cat & plots based the garden id */

        init_response.addCategoryPrimary(category_primary_repo.findByGardenId(garden_id), garden_id);
        init_response.addCategorySecondary(category_secondary_repo.findByGardenId(garden_id), garden_id);
        init_response.addPlot(plot_repo.findByGardenId(garden_id), garden_id);

        /* Retrive all veggies from the primary category id */
        for (CategoryPrimary category_loop : init_response.getCategory_primary_list()) {
            init_response.addVegetable(veggie_repo.findByCategoryPrimaryId(category_loop.getId()),
                    category_loop.getId(), category_loop.getGarden_id());
        }

        /* Retrieve all planted veggies from a plot id */
        for (Plot plot_loop : init_response.getPlot_list()) {
            init_response.addPlant(plant_repo.findByPlotId(plot_loop.getId()));
        }

        return new ResponseEntity<>(init_response, HttpStatus.OK);
    }

}
