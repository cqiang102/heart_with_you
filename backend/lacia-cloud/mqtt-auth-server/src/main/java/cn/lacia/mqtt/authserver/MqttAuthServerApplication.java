package cn.lacia.mqtt.authserver;

import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.ui.ModelMap;
import org.springframework.util.StringUtils;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.context.request.WebRequestInterceptor;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.stream.Collectors;

@SpringBootApplication
public class MqttAuthServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(MqttAuthServerApplication.class, args);
    }

    // to enable: ./mvnw spring-boot:run -Dspring-boot.run.profiles=debug
    @Profile("debug")
    @Configuration
    static class DebugConfiguration implements WebMvcConfigurer {

        @Override
        public void addInterceptors(InterceptorRegistry registry) {

            registry.addWebRequestInterceptor(new WebRequestInterceptor() {
                @Override
                public void preHandle(WebRequest request) {
                    LoggerFactory.getLogger(DebugConfiguration.class).info(
                            "HTTP request parameters: {}",
                            request.getParameterMap()
                                    .entrySet().stream()
                                    .map(entry -> entry.getKey() + " = " + StringUtils.arrayToCommaDelimitedString(entry.getValue()))
                                    .collect(Collectors.toList())
                    );
                }

                @Override
                public void postHandle(WebRequest request, ModelMap model) {

                }

                @Override
                public void afterCompletion(WebRequest request, Exception ex) {

                }
            });
        }

    }
}
