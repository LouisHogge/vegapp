package com.vegAppTest.Repositories;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.vegAppTest.Entities.Gardener;

import jakarta.transaction.Transactional;

@Repository
@Transactional
public interface Gardener_R extends JpaRepository<Gardener, Long> {

    Optional<Gardener> findByEmail(String email);

    /*
     * Use this one in controllers because we suppose that the user exist, else the
     * endpoint should not be accessable
     */
    Gardener getReferenceByEmail(String email);
}
