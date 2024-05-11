package com.vegAppTest.Repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.vegAppTest.Entities.Sync;
import jakarta.transaction.Transactional;

@Repository
@Transactional
public interface Sync_R extends JpaRepository<Sync, Long> {
    @Query("select s from Sync s where s.gardener_id = :gardener_id")
    Sync findSyncByGardenerId(Long gardener_id);

}
