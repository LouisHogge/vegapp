package com.vegAppTest.Security.Config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import lombok.RequiredArgsConstructor;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwTAuthentificationFilter jwt_auth_filter;
    private final AuthenticationProvider authentication_provider;

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers("/", "/css/**", "/images/**", "/website/**", "/index.html",
                                "/login.html", "/signup.html", "/auth/**", "/latest-artifact",
                                "https://gitlab.uliege.be/SPEAM/2023-2024/team-6/-/jobs/**")
                        .permitAll()
                        // "/url/**" This allows to only look at the prefix url, and ignore the rest of
                        // the url
                        .anyRequest().authenticated())
                .sessionManagement(sessionManagement -> sessionManagement
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS))

                .authenticationProvider(authentication_provider)
                .addFilterBefore(jwt_auth_filter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
