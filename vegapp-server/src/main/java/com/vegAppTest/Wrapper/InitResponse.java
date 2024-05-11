package com.vegAppTest.Wrapper;

import java.util.ArrayList;
import java.util.List;

import com.vegAppTest.Entities.CategoryPrimary;
import com.vegAppTest.Entities.CategorySecondary;
import com.vegAppTest.Entities.Garden;
import com.vegAppTest.Entities.Plant;
import com.vegAppTest.Entities.Plot;
import com.vegAppTest.Entities.Veggie;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@AllArgsConstructor
public class InitResponse {

    private List<Garden> garden_list;
    private List<CategoryPrimary> category_primary_list;
    private List<CategorySecondary> category_secondary_list;
    private List<Veggie> veggie_list;
    private List<Plot> plot_list;
    private List<Plant> plant_list;

    public InitResponse() {
        garden_list = new ArrayList<>();
        category_primary_list = new ArrayList<>();
        category_secondary_list = new ArrayList<>();
        veggie_list = new ArrayList<>();
        plot_list = new ArrayList<>();
        plant_list = new ArrayList<>();
    }

    public void addCategoryPrimary(List<CategoryPrimary> category_primary, Long id) {
        for (CategoryPrimary category_primary_loop : category_primary) {
            category_primary_loop.setGarden_id(id);
        }
        category_primary_list.addAll(category_primary);
        return;
    }

    public void addCategorySecondary(List<CategorySecondary> category_secondary, Long id) {
        for (CategorySecondary category_secondary_loop : category_secondary) {
            category_secondary_loop.setGarden_id(id);
        }
        category_secondary_list.addAll(category_secondary);
        return;
    }

    public void addVegetable(List<Veggie> veggie, Long category_id, Long garden_id) {
        for (Veggie veggie_loop : veggie) {
            veggie_loop.setCategory_primary_id(category_id);
            veggie_loop.setGarden_id(garden_id);
        }
        veggie_list.addAll(veggie);
        return;
    }

    public void addPlot(List<Plot> plot, Long id) {
        for (Plot plot_loop : plot) {
            plot_loop.setGarden_id(id);
        }
        plot_list.addAll(plot);
        return;
    }

    public void addPlant(List<Plant> plant) {
        plant_list.addAll(plant);
        return;
    }


}
