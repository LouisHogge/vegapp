package com.vegAppTest.Repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

import com.vegAppTest.Entities.Plant;
import jakarta.transaction.Transactional;

@Repository
@Transactional

public interface Plant_R extends JpaRepository<Plant, Long> {

    @Query("SELECT p FROM Plant p WHERE p.plot_id = :plot_id")
    List<Plant> findByPlotId(Long plot_id);

    @Query(value = "SELECT v.veggie_id, v.harvest_end, v.harvest_start, v.plant_end, v.plant_start, v.seed_avaibility, v.seed_expiration, v.vegetable_name, v.category_id FROM plant p JOIN vegetables v ON p.veggie_id = v.veggie_id WHERE p.plot_id = :plot_id", nativeQuery = true)
    List<String> findVeggiesOfAplot(Long plot_id);

    @Query(value = "SELECT DISTINCT veggie_id FROM plant p JOIN plot pl ON p.plot_id = pl.plot_id WHERE pl.in_calendar = 1 AND pl.garden_id = :garden_id", nativeQuery = true)
    List<Long> findVeggieIdsInDisplayedPlots(Long garden_id);

}
