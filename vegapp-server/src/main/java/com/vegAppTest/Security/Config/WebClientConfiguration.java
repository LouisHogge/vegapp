package com.vegAppTest.Security.Config;

import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;
import io.netty.handler.ssl.util.InsecureTrustManagerFactory;
import reactor.netty.http.client.HttpClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.reactive.ClientHttpConnector;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.web.reactive.function.client.WebClient;
import javax.net.ssl.SSLException;

@Configuration
public class WebClientConfiguration {

    @Bean
    public WebClient createWebClient() throws SSLException {
        // Disable SSL certificate validation
        SslContext sslContext = SslContextBuilder
                .forClient()
                .trustManager(InsecureTrustManagerFactory.INSTANCE)
                .build();

        // Create a custom HttpClient with the SSL context
        HttpClient httpClient = HttpClient.create().secure(t -> t.sslContext(sslContext));

        // Create a ReactorClientHttpConnector with the custom HttpClient
        ClientHttpConnector httpConnector = new ReactorClientHttpConnector(httpClient);

        // Create and return WebClient with the custom ClientHttpConnector
        return WebClient.builder().clientConnector(httpConnector).build();
    }
}
