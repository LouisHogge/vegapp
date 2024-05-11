package com.vegAppTest.Security;

import org.springframework.web.bind.annotation.RestController;

import com.vegAppTest.Entities.Gardener;
import com.vegAppTest.Entities.Gardener.Role;
import com.vegAppTest.Repositories.Gardener_R;
import com.vegAppTest.Security.Service.JwtService;

import lombok.RequiredArgsConstructor;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.crossstore.ChangeSetPersister.NotFoundException;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@RestController
@RequiredArgsConstructor
@RequestMapping("/auth")
public class Authentication_C {

    @Autowired
    private final Gardener_R gardener_repo;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwt_service;
    private final AuthenticationManager auth_manager;

    @PostMapping("/register")
    public ResponseEntity<AuthenticationResponse> register(@RequestBody RegisterRequest request) {

        Gardener gardener = new Gardener(
                request.getFirst_name(),
                request.getLast_name(),
                request.getEmail(),
                passwordEncoder.encode(request.getPassword()),
                Role.USER);

        gardener_repo.save(gardener);
        String jwt_token = jwt_service.generateToken(gardener);
        return ResponseEntity.ok(AuthenticationResponse.builder()
                .token(jwt_token)
                .build());

    }

    @PostMapping("/authenticate")
    public ResponseEntity<AuthenticationResponse> authenticate(@RequestBody AuthenticationRequest request)
            throws NotFoundException {

        auth_manager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword())

        );
        /*
         * If username (here email is our username) and password pair is correct, we
         * continue, else an 403 forbidden is given
         */

        Gardener gardener = gardener_repo.findByEmail(request.getEmail())
                .orElseThrow(() -> new NotFoundException());

        String jwt_token = jwt_service.generateToken(gardener);
        return ResponseEntity.ok(AuthenticationResponse.builder()
                .token(jwt_token)
                .build());
    }
}
