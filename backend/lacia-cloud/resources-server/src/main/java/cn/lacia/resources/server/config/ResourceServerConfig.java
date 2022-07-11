/*
 * Copyright 2020-2021 the original author or authors.
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
package cn.lacia.resources.server.config;

import org.springframework.context.annotation.Bean;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

/**
 * @author lacia
 * @date 2022/4/16 - 10:15
 */
@EnableWebSecurity
public class ResourceServerConfig {
    private final  AuthenticationEntryPointImpl authEntryPoint;

    public ResourceServerConfig(AuthenticationEntryPointImpl authEntryPoint) {
        this.authEntryPoint = authEntryPoint;
    }
    @Bean
    PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }


    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .authorizeRequests()
                .anyRequest()
                .access("hasAuthority('SCOPE_user')")
                .and().cors().disable().csrf().disable()
                .oauth2ResourceServer()
                .authenticationEntryPoint(authEntryPoint).jwt(Customizer.withDefaults());
        return http.build();
    }

}
