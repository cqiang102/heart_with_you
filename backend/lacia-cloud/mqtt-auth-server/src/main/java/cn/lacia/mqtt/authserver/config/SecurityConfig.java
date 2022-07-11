package cn.lacia.mqtt.authserver.config;

import org.springframework.context.annotation.Bean;
import org.springframework.http.HttpHeaders;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.oauth2.server.resource.web.BearerTokenResolver;
import org.springframework.security.oauth2.server.resource.web.DefaultBearerTokenResolver;
import org.springframework.security.web.SecurityFilterChain;

/**
 * @author lacia
 * @date 2022/4/21 - 11:52
 */
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    BearerTokenResolver bearerTokenResolver() {
        MqttBearerTokenResolver bearerTokenResolver = new MqttBearerTokenResolver();
        bearerTokenResolver.setBearerTokenHeaderName(HttpHeaders.PROXY_AUTHORIZATION);
        bearerTokenResolver.setAllowFormEncodedBodyParameter(true);
        return bearerTokenResolver;
    }

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .authorizeRequests()
                .anyRequest().authenticated()
                .and().cors().disable().csrf().disable()
                .oauth2ResourceServer(oauth2 ->
                        oauth2.jwt(Customizer.withDefaults())
                        .bearerTokenResolver(bearerTokenResolver()));
        return http.build();
    }
}
