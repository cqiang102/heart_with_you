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
package cn.lacia.auth.server.config;

import cn.lacia.auth.server.exception.AuthenticationEntryPointImpl;
import org.springframework.context.annotation.Bean;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

/**
 * @author Joe Grandja
 * @since 0.1.0
 */
@EnableWebSecurity
public class DefaultSecurityConfig {
    private final AuthenticationEntryPointImpl authenticationEntryPoint;

    public DefaultSecurityConfig(AuthenticationEntryPointImpl authenticationEntryPoint) {
        this.authenticationEntryPoint = authenticationEntryPoint;

    }

    @Bean
    SecurityFilterChain defaultSecurityFilterChain(HttpSecurity http) throws Exception {

        http
                .csrf().disable()
                .oauth2ResourceServer()
                .authenticationEntryPoint(authenticationEntryPoint).jwt().and()
                .and()
                .authorizeRequests()
                .antMatchers("/api/register", "/registerPage").permitAll()
                .antMatchers("/loginPage", "/login").anonymous()
                .anyRequest().authenticated();
        // 自定义登录页
        // 配置异常处理
        // 完成 mqtt 身份验证
        // 完成文件服务器
        // 提供根据 name 查询用户资料接口
        // 关注 消息 type 判断
        // 动态功能
        //    新增
        //    自己可见
        //    分页查询
        //    随机查询
        // 发送消息
        // 判断是否存在关注关系
        // 定制消息传输协议
        //     发送图片
        //     发送语音
        //     发送文件
        //         发送视频
        // 匹配功能
        //     接收用户定位
        //     查询附近的人
        return http.formLogin().loginPage("/loginPage").and().build();
//        return http.build();
//        return http.formLogin(Customizer.withDefaults()).build();
    }
}
