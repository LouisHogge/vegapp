package com.vegAppTest.Repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vegAppTest.Entities.CategoryPrimary;
import jakarta.transaction.Transactional;

@Repository
@Transactional
public interface CategoryPrimary_R extends JpaRepository<CategoryPrimary, Long> {

        @Query("SELECT c FROM CategoryPrimary c JOIN c.garden g JOIN g.gardener gd WHERE gd.id = :gardener_id AND c.name = :categoryName AND g.name = :gardenName")
        Optional<CategoryPrimary> findByGardenerIdCategoryNameGardenName(@Param("gardener_id") Long gardenerId,
                        @Param("categoryName") String categoryName, @Param("gardenName") String gardenName);

        @Query("SELECT DISTINCT c " +
                        "FROM CategoryPrimary c " +
                        "JOIN c.garden g " +
                        "JOIN g.gardener gd " +
                        "WHERE gd.id = :gardenerId")
        List<CategoryPrimary> findAllCategoriesByGardenerId(@Param("gardenerId") Long gardenerId);

        @Modifying
        @Query("DELETE FROM CategoryPrimary c WHERE c.id IN (SELECT c2.id FROM CategoryPrimary c2 JOIN c2.garden g JOIN g.gardener gd WHERE gd.id = :gardenerId AND c2.name = :categoryName)")
        void deleteByGardenerIdAndCategoryName(@Param("gardenerId") Long gardenerId,
                        @Param("categoryName") String categoryName);

        @Query("Select c FROM CategoryPrimary c WHERE c.garden.id = :garden_id")
        List<CategoryPrimary> findByGardenId(Long garden_id);

}