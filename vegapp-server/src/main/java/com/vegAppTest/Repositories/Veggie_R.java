package com.vegAppTest.Repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vegAppTest.Entities.Veggie;

import jakarta.transaction.Transactional;

@Repository
@Transactional
public interface Veggie_R extends JpaRepository<Veggie, Long> {

  @Query(value = "SELECT * FROM vegetable v WHERE v.category_secondary_id = :category_secondary_id AND v.category_primary_id = :category_primary_id AND v.name = :name", nativeQuery = true)
  Optional<Veggie> veggieExistSecondary(@Param("category_primary_id") Long category_primary_id,
      @Param("category_secondary_id") Long category_secondary_id, @Param("name") String name);

  @Query(value = "SELECT * FROM vegetable v WHERE v.category_primary_id = :category_primary_id AND v.name = :name", nativeQuery = true)
  Optional<Veggie> veggieExistNoSecondary(@Param("category_primary_id") Long category_primary_id,
      @Param("name") String name);

  @Query("Select v FROM Veggie v WHERE v.category_primary.id = :category_primary_id")
  List<Veggie> findByCategoryPrimaryId(Long category_primary_id);

  @Query(value = "SELECT v.id FROM vegetable v JOIN category_primary c ON v.category_primary_id = c.id JOIN garden g ON c.garden_id = g.id WHERE g.id = :gardenId AND v.name = :veggieName", nativeQuery = true)
  Optional<Long> findVeggieIdByVeggieNameAndGardenId(@Param("veggieName") String veggieName,
      @Param("gardenId") Long gardenId);

}
