package com.vegAppTest.Repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vegAppTest.Entities.CategorySecondary;
import com.vegAppTest.Entities.CategorySecondary.Color;

import jakarta.transaction.Transactional;

@Repository
@Transactional
public interface CategorySecondary_R extends JpaRepository<CategorySecondary, Long> {

        @Query("SELECT  c FROM CategorySecondary c JOIN c.garden g JOIN g.gardener gd WHERE gd.id = :gardener_id AND c.name = :categoryName")
        Optional<CategorySecondary> findByGardenerIdAndCategoryName(@Param("gardener_id") Long gardenerId,
                        @Param("categoryName") String categoryName);

        @Query("SELECT c FROM CategorySecondary c JOIN c.garden g JOIN g.gardener gd WHERE gd.id = :gardener_id AND c.name = :categoryName AND g.name = :gardenName")
        Optional<CategorySecondary> findByGardenerIdCategoryNameGardenName(@Param("gardener_id") Long gardenerId,
                        @Param("categoryName") String categoryName, @Param("gardenName") String gardenName);

        @Query("SELECT DISTINCT c " +
                        "FROM CategorySecondary c " +
                        "JOIN c.garden g " +
                        "JOIN g.gardener gd " +
                        "WHERE gd.id = :gardenerId")
        List<CategorySecondary> findAllCategoriesByGardenerId(@Param("gardenerId") Long gardenerId);

        @Modifying
        @Query("DELETE FROM CategorySecondary c WHERE c.id IN (SELECT c2.id FROM CategorySecondary c2 JOIN c2.garden g JOIN g.gardener gd WHERE gd.id = :gardenerId AND c2.name = :categoryName)")
        void deleteByGardenerIdAndCategoryName(@Param("gardenerId") Long gardenerId,
                        @Param("categoryName") String categoryName);

        @Modifying
        @Query("UPDATE CategorySecondary e SET e.name = :newName, e.color = :newColor WHERE e.id = :id")
        void updatePropertyById(@Param("id") Long id, @Param("newName") String newName,
                        @Param("newColor") Color newColor);

        @Query("Select c FROM CategorySecondary c WHERE c.garden.id = :garden_id")
        List<CategorySecondary> findByGardenId(Long garden_id);

}
