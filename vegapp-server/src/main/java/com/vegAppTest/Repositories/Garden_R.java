package com.vegAppTest.Repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vegAppTest.Entities.Garden;

import jakarta.transaction.Transactional;

@Repository
@Transactional
public interface Garden_R extends JpaRepository<Garden, Long> {

    @Query("SELECT g FROM Garden g WHERE g.gardener.id = :gardener_id")
    List<Garden> findAllByGardenerId(Long gardener_id);

    @Query("SELECT g FROM Garden g WHERE g.gardener.id = :gardener_id AND name = :name")
    Optional<Garden> findOneByName(Long gardener_id, String name);

    @Modifying
    @Query("DELETE FROM Garden g WHERE g.gardener.id = :gardener_id AND g.name = :name")
    void deleteByName(@Param("gardener_id") Long gardenerId, @Param("name") String name);

}