package com.vegAppTest.Security.Service;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;

@Service
public class JwtService {

    private static final String SECRET_KEY = "784a4b207a6d4a7b4d5f464e3b3379705e27562027506b4055532b2b687e4c3f";

    public String extractUsername(String token) {

        return extractClaim(token, Claims::getSubject);
    }

    /* Generate token without claims */
    public String generateToken(UserDetails user_details) {
        return generateToken(new HashMap<>(), user_details);
    }

    /* Generate token with claims */
    public String generateToken(
            Map<String, Object> extra_claims,
            UserDetails user_details) {

        return Jwts
                .builder()
                .setClaims(extra_claims)
                .setSubject(user_details.getUsername())
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + (52 * 7 * 24 * 60 * 60 * 1000))) // This line is to
                                                                                                      // set an
                                                                                                      // expiration Date
                                                                                                      // ( = validity
                                                                                                      // time)
                .signWith(getSignInKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    public boolean isTokenValid(String token, UserDetails user_details) {
        final String username = extractUsername(token);
        return (username.equals(user_details.getUsername())) && !isTokenExpired(token);
    }

    private Claims extractAllClaims(String token) {
        return Jwts
                .parserBuilder()
                .setSigningKey(getSignInKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    private boolean isTokenExpired(String token) {

        return extractExpiration(token).before(new Date());
    }

    private Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    public <T> T extractClaim(String token, Function<Claims, T> claims_resolver) {
        final Claims claims = extractAllClaims(token);
        return claims_resolver.apply(claims);
    }

    private Key getSignInKey() {
        byte[] key_bytes = Decoders.BASE64.decode(SECRET_KEY);
        return Keys.hmacShaKeyFor(key_bytes);
    }
}
