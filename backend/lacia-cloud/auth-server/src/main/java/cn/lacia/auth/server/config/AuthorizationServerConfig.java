/*
 * Copyright 2020-2022 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package cn.lacia.auth.server.config;

import cn.lacia.auth.server.config.oauth2.CustomizeUsernamePasswordAuthenticationConverter;
import cn.lacia.auth.server.config.oauth2.OAuth2ConfigurerUtils;
import cn.lacia.auth.server.config.oauth2.OAuth2PasswordAuthenticationProvider;
import cn.lacia.auth.server.exception.AuthenticationEntryPointImpl;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.oauth2.server.authorization.OAuth2AuthorizationServerConfigurer;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.core.OAuth2Token;
import org.springframework.security.oauth2.server.authorization.OAuth2AuthorizationService;
import org.springframework.security.oauth2.server.authorization.client.RegisteredClientRepository;
import org.springframework.security.oauth2.server.authorization.token.OAuth2TokenGenerator;
import org.springframework.security.oauth2.server.authorization.web.authentication.DelegatingAuthenticationConverter;
import org.springframework.security.oauth2.server.authorization.web.authentication.OAuth2AuthorizationCodeAuthenticationConverter;
import org.springframework.security.oauth2.server.authorization.web.authentication.OAuth2ClientCredentialsAuthenticationConverter;
import org.springframework.security.oauth2.server.authorization.web.authentication.OAuth2RefreshTokenAuthenticationConverter;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.util.matcher.RequestMatcher;

import java.util.Arrays;

/**
 * @author Joe Grandja
 * @since 0.0.1
 */
@Configuration(proxyBeanMethods = false)
public class AuthorizationServerConfig {
    private final OAuth2AuthorizationService authorizationService;
    private final RegisteredClientRepository registeredClientRepository;
    private final PasswordEncoder passwordEncoder;

    private final UserDetailsService userDetailsService;

    private final AuthenticationEntryPointImpl authenticationEntryPoint;

    public AuthorizationServerConfig(OAuth2AuthorizationService authorizationService,
                                     RegisteredClientRepository registeredClientRepository,
                                     PasswordEncoder passwordEncoder, @Qualifier("userDetailsServiceImpl") UserDetailsService userDetailsService, AuthenticationEntryPointImpl authenticationEntryPoint) {
        this.authorizationService = authorizationService;
        this.registeredClientRepository = registeredClientRepository;
        this.passwordEncoder = passwordEncoder;
        this.userDetailsService = userDetailsService;

        this.authenticationEntryPoint = authenticationEntryPoint;
    }


    @Bean
    @Order(Ordered.HIGHEST_PRECEDENCE)
    public SecurityFilterChain authorizationServerSecurityFilterChain(HttpSecurity http) throws Exception {
        OAuth2TokenGenerator<? extends OAuth2Token> tokenGenerator = OAuth2ConfigurerUtils.getTokenGenerator(http);

        OAuth2PasswordAuthenticationProvider authenticationProvider =
                new OAuth2PasswordAuthenticationProvider(
                        authorizationService, registeredClientRepository, passwordEncoder, tokenGenerator
                );

        authenticationProvider.setUserDetailsService(userDetailsService);
        OAuth2AuthorizationServerConfigurer<HttpSecurity> authorizationServerConfigurer =
                new OAuth2AuthorizationServerConfigurer<>();
        authorizationServerConfigurer
                .tokenRevocationEndpoint(Customizer.withDefaults())
                .tokenIntrospectionEndpoint(Customizer.withDefaults())
                .tokenEndpoint((tokenEndpoint) -> tokenEndpoint.accessTokenRequestConverter(new DelegatingAuthenticationConverter(
                        Arrays.asList(
                                new CustomizeUsernamePasswordAuthenticationConverter(),
                                new OAuth2AuthorizationCodeAuthenticationConverter(),
                                new OAuth2RefreshTokenAuthenticationConverter(),
                                new OAuth2ClientCredentialsAuthenticationConverter()
                        ))));
        RequestMatcher endpointsMatcher = authorizationServerConfigurer
                .getEndpointsMatcher();
        http
                .requestMatcher(endpointsMatcher)
                .authenticationProvider(authenticationProvider)
//                .exceptionHandling().authenticationEntryPoint(authenticationEntryPoint).and()
                .authorizeRequests(authorizeRequests ->
                        authorizeRequests
                                .mvcMatchers("/oauth2/token").permitAll()
                        .anyRequest().authenticated()
                )
                .csrf(csrf -> csrf.ignoringRequestMatchers(endpointsMatcher));
        http.apply(authorizationServerConfigurer);
        http.oauth2ResourceServer().accessDeniedHandler((request,response,e)->{
            e.printStackTrace();
        }).authenticationEntryPoint(authenticationEntryPoint).jwt();
        return http.formLogin().loginPage("/loginPage").and().build();
//        return http.formLogin(Customizer.withDefaults()).build();

    }

}
