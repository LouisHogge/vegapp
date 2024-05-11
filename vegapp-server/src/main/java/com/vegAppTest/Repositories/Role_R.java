package com.vegAppTest.Repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.Modifying;

import com.vegAppTest.Entities.Role;

import jakarta.transaction.Transactional;

@Repository
@Transactional

public interface Role_R extends JpaRepository<Role, Long> {
    @Modifying
    @Query(value = "DELETE FROM role WHERE garden_id = :garden_id AND gardener_id = :gardener_id AND role = :rolee", nativeQuery = true)
    void deleteByGardenIdAndGardenerId(Long garden_id, Long gardener_id, int rolee);
}
