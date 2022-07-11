package cn.lacia.resources.server.config;

import cn.lacia.common.model.Result;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.netty.util.CharsetUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.InsufficientAuthenticationException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.oauth2.server.resource.InvalidBearerTokenException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * @author lacia
 * @date 2022/4/20 - 14:03
 */
@Slf4j
@Component
public class AuthenticationEntryPointImpl implements AuthenticationEntryPoint {
    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response,
                         AuthenticationException authException) throws IOException, ServletException {
        authException.printStackTrace();
        log.info("{} : {} : {}", request.getRequestURI(), authException, authException.getMessage());
        Result.ResultBuilder resultBuilder = Result.builder().code("130");
        if (authException instanceof InvalidBearerTokenException) {
            resultBuilder.code("140").message("token 无效");
        } else if (authException instanceof InsufficientAuthenticationException) {
            resultBuilder.message("权限不足");
        } else {
            resultBuilder.message(authException.getMessage());
        }
        response.setStatus(HttpServletResponse.SC_OK);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding(CharsetUtil.UTF_8.toString());
        response.getWriter().print(new ObjectMapper().setDefaultPropertyInclusion(JsonInclude.Include.NON_NULL).writeValueAsString(resultBuilder.build()));
    }
}
