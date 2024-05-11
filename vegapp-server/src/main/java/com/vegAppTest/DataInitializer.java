package com.vegAppTest;



import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import java.util.Date;
import java.util.Calendar;

import com.vegAppTest.Entities.Garden;
import com.vegAppTest.Entities.CategoryPrimary;
import com.vegAppTest.Entities.Gardener.Role;
import com.vegAppTest.Entities.Gardener;
import com.vegAppTest.Entities.Veggie;
import com.vegAppTest.Entities.Plot;
import com.vegAppTest.Entities.Plant;
import com.vegAppTest.Repositories.CategoryPrimary_R;
import com.vegAppTest.Repositories.CategorySecondary_R;
import com.vegAppTest.Repositories.Garden_R;
import com.vegAppTest.Repositories.Gardener_R;
import com.vegAppTest.Repositories.Veggie_R;
import com.vegAppTest.Repositories.Plot_R;
import com.vegAppTest.Repositories.Plant_R;
import com.vegAppTest.Repositories.Sync_R;


@Configuration
public class DataInitializer {


@Bean
    public CommandLineRunner initializeUsers(CategorySecondary_R category_secondary_repo,
    Veggie_R veggie_repo, Garden_R garden_repo, Gardener_R gardener_repo, Plot_R plot_repo,
     Plant_R plant_repo, Sync_R sync_repo, CategoryPrimary_R category_primary_repo) {
        return args -> {
            // Insert hardcoded users

            if (category_primary_repo.count() == 0){   //to have them only once



                
                Gardener gardener = new Gardener("Mario", "Vitelo","mario.vitelo@hotmail.it", "$2a$10$6liX3VtqFEtp2lXzS8U2.uoaBuEk8nnLghunMK3kAknFlxSnieM1i", Role.USER);
                gardener_repo.save(gardener);

                Garden garden = new Garden();
                garden.setName("Garden of Mario");
                garden.setGardener(gardener);
                
                garden_repo.save(garden);

                Calendar calendar = Calendar.getInstance();
                calendar.set(Calendar.YEAR, 2020); 
                calendar.set(Calendar.MONTH, Calendar.FEBRUARY); 
                calendar.set(Calendar.DAY_OF_MONTH, 16); 
                Date specificDate = calendar.getTime();

                Plot plot1 = new Plot();
                plot1.setName("end of garden"); plot1.setNb_of_lines("1.2");plot1.setVersion(0);
                plot1.setOrientation(0);plot1.setIn_calendar(0);plot1.setNote("Plot note");plot1.setGarden(garden);
                plot1.setCreation_date(specificDate);
                plot_repo.save(plot1);

                Calendar calendar2 = Calendar.getInstance();
                calendar2.set(Calendar.YEAR, 2022); 
                calendar2.set(Calendar.MONTH, Calendar.MARCH); 
                calendar2.set(Calendar.DAY_OF_MONTH, 2);
                Date specificDate2 = calendar2.getTime();

               Plot plot2 = new Plot();
                plot2.setName("sunny corner"); plot2.setNb_of_lines("1.4/2.2/3.1");plot2.setVersion(0);
                plot2.setOrientation(0);plot2.setIn_calendar(0);plot2.setNote("Plot note");plot2.setGarden(garden);
                plot2.setCreation_date(specificDate2);
                plot_repo.save(plot2);

                Calendar calendar3 = Calendar.getInstance();
                calendar3.set(Calendar.YEAR, 2022); 
                calendar3.set(Calendar.MONTH, Calendar.MAY); 
                calendar3.set(Calendar.DAY_OF_MONTH, 10);
         //       Date specificDate3 = calendar3.getTime();


         /*        Plot plot3 = new Plot();
                plot3.setName("sunny corner"); plot3.setNb_of_lines("1.6/2.1/3.3");plot3.setVersion(1);
                plot3.setOrientation(0);plot3.setIn_calendar(0);plot3.setNote("Plot note");plot3.setGarden(garden);
                plot3.setCreation_date(specificDate3);
                plot_repo.save(plot3);
                */

                Calendar calendar4 = Calendar.getInstance();
                calendar4.set(Calendar.YEAR, 2023); 
                calendar4.set(Calendar.MONTH, Calendar.JULY); 
                calendar4.set(Calendar.DAY_OF_MONTH, 29);
           //     Date specificDate4 = calendar4.getTime();


          /*      Plot plot4 = new Plot();
                plot4.setName("sunny corner"); plot4.setNb_of_lines("1.4/2.5/3.5");plot4.setVersion(2);
                plot4.setOrientation(0);plot4.setIn_calendar(0);plot4.setNote("Plot note");plot4.setGarden(garden);
                plot4.setCreation_date(specificDate4);
                plot_repo.save(plot4);

                */ 
                
                Veggie veggie;

                CategoryPrimary category_primary = new CategoryPrimary("Bin");
                category_primary.setGarden(garden);
                category_primary_repo.save(category_primary);

                category_primary = new CategoryPrimary("Root");
                category_primary.setGarden(garden);
                category_primary_repo.save(category_primary);


                veggie = new Veggie("Carrot", 1, 2026, 18, 22, "March", "Nov.", "This is a note");
                veggie.setCategory_primary(category_primary);
                veggie.setCategory_primary_id(category_primary.getId());
                veggie_repo.save(veggie);

                Plant plant_carrot = new Plant(); 
                plant_carrot.setPlotId(1L);
                plant_carrot.setVegetableId(veggie.getId());
                plant_carrot.setVegetable_location("1.0");
                plant_repo.save(plant_carrot);

                Plant plant_carrot2 = new Plant(); 
                plant_carrot2.setPlotId(1L);
                plant_carrot2.setVegetableId(veggie.getId());
                plant_carrot2.setVegetable_location("1.1");
                plant_repo.save(plant_carrot2);


                category_primary = new CategoryPrimary("Nightshade");
                category_primary.setGarden(garden);
                category_primary_repo.save(category_primary);
                veggie = new Veggie("Tomato", 1, 2024, 15, 20, "March", "Nov.","This is a note");
                veggie.setCategory_primary(category_primary);
                veggie.setCategory_primary_id(category_primary.getId());
  
                veggie_repo.save(veggie);
                
                category_primary = new CategoryPrimary("Salad Green");
                category_primary.setGarden(garden);
                category_primary_repo.save(category_primary);
                veggie = new Veggie("Lettuce", 0, 2022, 8, 13, "March", "Aug.","This is a note");
                veggie.setCategory_primary(category_primary);
                veggie.setCategory_primary_id(category_primary.getId());
  
                veggie_repo.save(veggie);
                
                category_primary = new CategoryPrimary("Cruciferous");
                category_primary.setGarden(garden);
                category_primary_repo.save(category_primary);
                veggie = new Veggie("Broccoli", 1, 2026, 18, 22, "March", "Nov.","This is a note");
                veggie.setCategory_primary(category_primary);
  
                veggie_repo.save(veggie);
                veggie = new Veggie("Cauliflower", 1, 2027, 27, 31, "March", "Nov.","This is a note");
                veggie.setCategory_primary(category_primary);
                veggie.setCategory_primary_id(category_primary.getId());
                veggie_repo.save(veggie);
                
                
   /*            Plant plant_cau = new Plant(); 
                plant_cau.setPlotId(3L);
                plant_cau.setVegetableId(veggie.getId());
                plant_cau.setVegetable_location("3.1");
                plant_repo.save(plant_cau);   */ 
                
                category_primary = new CategoryPrimary("Alliums");
                category_primary.setGarden(garden);
                category_primary_repo.save(category_primary);
                veggie = new Veggie("Onion", 0, 2025, 12, 16, "March", "Nov.","This is a note");
                veggie.setCategory_primary(category_primary);  
                veggie.setCategory_primary_id(category_primary.getId());
                veggie_repo.save(veggie);

    /*             Plant plant_onion = new Plant(); 
                plant_onion.setPlotId(4L);
                plant_onion.setVegetableId(veggie.getId());
                plant_onion.setVegetable_location("2.4");
                plant_repo.save(plant_onion);*/

    /*            Plant plant_onion2 = new Plant(); 
                plant_onion2.setPlotId(3L);
                plant_onion2.setVegetableId(veggie.getId());
                plant_onion2.setVegetable_location("1.4");
                plant_repo.save(plant_onion2);*/ 

      /*           Plant plant_onion3 = new Plant(); 
                plant_onion3.setPlotId(1L);
                plant_onion3.setVegetableId(veggie.getId());
                plant_onion3.setVegetable_location("2.2");
                plant_repo.save(plant_onion3);*/

                
                category_primary = new CategoryPrimary("Podded");
                category_primary.setGarden(garden);
                category_primary_repo.save(category_primary);
                veggie = new Veggie("Cucumber", 1, 2030, 24, 28, "March", "Aug.","This is a note");
                veggie.setCategory_primary(category_primary);
                veggie.setCategory_primary_id(category_primary.getId());
  
                veggie_repo.save(veggie);

                veggie = new Veggie("Zucchini", 0, 2028, 28, 32, "March", "Aug.","This is a note");
                veggie.setCategory_primary(category_primary);
                veggie.setCategory_primary_id(category_primary.getId());
  
                veggie_repo.save(veggie);
                
                category_primary = new CategoryPrimary("Tubers");
                category_primary.setGarden(garden);
                category_primary_repo.save(category_primary);
                veggie = new Veggie("Potato", 0, 2025, 12, 16, "March", "Nov.","This is a note");
                veggie.setCategory_primary(category_primary);
                veggie.setCategory_primary_id(category_primary.getId());
  
                veggie_repo.save(veggie);

                veggie = new Veggie("Sweet Potato", 1, 2029, 29, 33, "March", "Nov.","This is a note");
                veggie.setCategory_primary(category_primary);
                veggie.setCategory_primary_id(category_primary.getId());
  
                veggie_repo.save(veggie);
                
                category_primary = new CategoryPrimary("Stem");
                category_primary.setGarden(garden);
                category_primary_repo.save(category_primary);
                veggie = new Veggie("Asparagus", 0, 2024, 15, 20, "March", "Aug.","This is a note");
                veggie.setCategory_primary(category_primary);
                veggie.setCategory_primary_id(category_primary.getId());
  
                veggie_repo.save(veggie);
                
                category_primary = new CategoryPrimary("Leafy Green");
                category_primary.setGarden(garden);
                category_primary_repo.save(category_primary);
                veggie = new Veggie("Spinach", 1, 2035, 34, 38, "March", "Nov.","This is a note");
                veggie.setCategory_primary(category_primary);
  
                veggie_repo.save(veggie);
                veggie = new Veggie("Kale", 1, 2023, 22, 26, "March", "Nov.","This is a note");
                veggie.setCategory_primary(category_primary);
                veggie.setCategory_primary_id(category_primary.getId());
  
                veggie_repo.save(veggie);
                
                category_primary = new CategoryPrimary("Brassica");
                category_primary.setGarden(garden);
                category_primary_repo.save(category_primary);
                veggie = new Veggie("Cabbage", 1, 2020, 10, 14, "March", "Nov.","This is a note");
                veggie.setCategory_primary(category_primary);
                veggie.setCategory_primary_id(category_primary.getId());
  
                veggie_repo.save(veggie);
                
                category_primary = new CategoryPrimary("Solanaceous");
                category_primary.setGarden(garden);
                category_primary_repo.save(category_primary);  
                veggie = new Veggie("Bell Pepper", 0, 2031, 26, 30, "March", "Nov.","This is a note");
                veggie.setCategory_primary(category_primary);
                veggie.setCategory_primary_id(category_primary.getId());
  
                veggie_repo.save(veggie);            
                
            }
        };
    }
}



