package com.vegAppTest.Repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

import com.vegAppTest.Entities.Plot;
import jakarta.transaction.Transactional;
import java.util.Optional;

@Repository
@Transactional
public interface Plot_R extends JpaRepository<Plot, Long> {
        @Query(value = "SELECT plot_id FROM plot WHERE garden_id = :garden_id AND in_calendar = 1", nativeQuery = true)
        List<Long> findIdsOfDisplayedPlots(Long garden_id);

        @Query("SELECT COUNT(p) FROM Plot p WHERE p.garden.id = :garden_id AND p.name = :name AND p.version = :version")
        int checkIfExistingPlot(Long garden_id, String name, int version);

        @Query(value = "SELECT DISTINCT name FROM plot WHERE EXTRACT(YEAR FROM creation_date) = :year AND garden_id = :garden_id", nativeQuery = true)
        List<String> findPlotNamesByYear(int year, Long garden_id);

        @Query(value = "SELECT DISTINCT EXTRACT(YEAR FROM creation_date) FROM plot WHERE garden_id = :garden_id", nativeQuery = true)
        List<Integer> findDistinctYears(Long garden_id);

        @Query(value = "SELECT version FROM plot WHERE garden_id = :garden_id AND EXTRACT(YEAR FROM creation_date) = :year AND name = :name", nativeQuery = true)
        List<Integer> findPlotVersions(Long garden_id, int year, String name);

        @Query(value = "SELECT * FROM plot WHERE garden_id = :garden_id AND name = :name ORDER BY version DESC LIMIT 1", nativeQuery = true)
        Plot findPlotLatestVersion(Long garden_id, String name);

        @Query(value = "SELECT * FROM plot WHERE name = :name ORDER BY version DESC LIMIT 1", nativeQuery = true)
        Plot findLatestVersionByName(String name);

        @Query("SELECT p FROM Plot p WHERE p.garden.id = :garden_id AND p.name = :name AND p.version = :version")
        Optional<Plot> findByGardenAndNameAndVersion(Long garden_id, String name, int version);

        /* ------- */

        @Query("SELECT p FROM Plot p " +
                        "JOIN p.garden g " +
                        "JOIN g.gardener gr " +
                        "WHERE gr.id = :gardenerId " +
                        "AND g.id = :gardenId " +
                        "AND p.name = :plotName " +
                        "AND p.version = :version")
        Optional<Plot> findByGardenGardenerAndName(@Param("gardenerId") Long gardenerId,
                        @Param("gardenId") Long gardenId,
                        @Param("plotName") String plotName,
                        @Param("version") Long version);

        @Modifying
        @Query(value = "DELETE FROM plot p " +
                        "WHERE p.id IN (" +
                        "    SELECT p.id " +
                        "    FROM plot p " +
                        "    JOIN garden g ON p.garden_id = g.id " +
                        "    JOIN gardener gr ON g.gardener_id = gr.id " +
                        "    WHERE g.id = :gardenId AND gr.id = :gardenerId AND p.name = :name)", nativeQuery = true)
        void deleteByGardenGardenerAndName(@Param("gardenerId") Long gardenerId,
                        @Param("gardenId") Long gardenId,
                        @Param("name") String name);

        @Query("Select p FROM Plot p WHERE p.garden.id = :garden_id")
        List<Plot> findByGardenId(Long garden_id);

}