package com.vegAppTest.Security.Config;

import java.io.IOException;

import org.springframework.web.filter.OncePerRequestFilter;

import com.vegAppTest.Security.Service.JwtService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class JwTAuthentificationFilter extends OncePerRequestFilter {

    @Autowired
    private final JwtService jwt_service;

    @Autowired
    private UserDetailsService user_details_service;

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request, @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain)
            throws ServletException, IOException {

        final String aut_header = request.getHeader("Authorization");
        final String jwt;
        final String user_email;

        /* Check if Request contains the token in Header, return if not */
        if (aut_header == null || !aut_header.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        jwt = aut_header.substring(7);
        user_email = jwt_service.extractUsername(jwt);
        /* Check if user is already logged in, if yes we won't check if user exists */
        if (user_email != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            UserDetails user_details = this.user_details_service.loadUserByUsername(user_email);
            if (jwt_service.isTokenValid(jwt, user_details)) {
                UsernamePasswordAuthenticationToken auth_token = new UsernamePasswordAuthenticationToken(
                        user_details,
                        null,
                        user_details.getAuthorities());
                auth_token.setDetails(
                        new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(auth_token);
            }
        }
        filterChain.doFilter(request, response);
    }

}

/*
 * A filter is used to filter HTTP request and take action depending on the
 * request (parse header, body, etc )
 */