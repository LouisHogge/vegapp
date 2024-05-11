package com.vegAppTest.Security.Service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.vegAppTest.Entities.Gardener;
import com.vegAppTest.Repositories.Gardener_R;

@Service
public class ControllerService {

    @Autowired
    JwtService jwt_service;

    @Autowired
    Gardener_R gardener_repo;

    public Gardener getGardenerFromToken(String token) {
        String jwtToken = token.substring(7); // Remove "Bearer " prefix
        String userEmail = jwt_service.extractUsername(jwtToken); // Extract user's email from JWT claims
        return gardener_repo.getReferenceByEmail(userEmail);
    }
}
