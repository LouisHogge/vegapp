package com.vegAppTest.Controllers;

import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.web.bind.annotation.RestController;

/*   Entities   */
import com.vegAppTest.Entities.CategoryPrimary;
import com.vegAppTest.Entities.Garden;
/*   Repositories   */
import com.vegAppTest.Repositories.CategoryPrimary_R;
import com.vegAppTest.Repositories.Garden_R;
/*   Services   */
import com.vegAppTest.Security.Service.ControllerService;

@RestController
public class CategoryPrimary_C {

    @Autowired
    CategoryPrimary_R category_primary_repo;

    @Autowired
    ControllerService controller_servcice;

    @Autowired
    Garden_R garden_repo;

    public void addPrimaryCategories(Garden garden) {

        CategoryPrimary category_primary = new CategoryPrimary("Bin");
        category_primary.setGarden(garden);
        category_primary_repo.save(category_primary);

        category_primary = new CategoryPrimary("Root");
        category_primary.setGarden(garden);
        category_primary_repo.save(category_primary);

        category_primary = new CategoryPrimary("Nightshade");
        category_primary.setGarden(garden);
        category_primary_repo.save(category_primary);

        category_primary = new CategoryPrimary("Salad Green");
        category_primary.setGarden(garden);
        category_primary_repo.save(category_primary);

        category_primary = new CategoryPrimary("Cruciferous");
        category_primary.setGarden(garden);
        category_primary_repo.save(category_primary);

        category_primary = new CategoryPrimary("Alliums");
        category_primary.setGarden(garden);
        category_primary_repo.save(category_primary);

        category_primary = new CategoryPrimary("Podded");
        category_primary.setGarden(garden);
        category_primary_repo.save(category_primary);

        category_primary = new CategoryPrimary("Tubers");
        category_primary.setGarden(garden);
        category_primary_repo.save(category_primary);

        category_primary = new CategoryPrimary("Stem");
        category_primary.setGarden(garden);
        category_primary_repo.save(category_primary);

        category_primary = new CategoryPrimary("Leafy Green");
        category_primary.setGarden(garden);
        category_primary_repo.save(category_primary);

        category_primary = new CategoryPrimary("Brassica");
        category_primary.setGarden(garden);
        category_primary_repo.save(category_primary);

        category_primary = new CategoryPrimary("Solanaceous");
        category_primary.setGarden(garden);
        category_primary_repo.save(category_primary);
        return;
    }

}