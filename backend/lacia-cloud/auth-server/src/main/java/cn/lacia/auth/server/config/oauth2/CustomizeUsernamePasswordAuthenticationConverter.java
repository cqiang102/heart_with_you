package cn.lacia.auth.server.config.oauth2;

import lombok.extern.slf4j.Slf4j;
import org.springframework.lang.Nullable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.core.AuthorizationGrantType;
import org.springframework.security.oauth2.core.OAuth2ErrorCodes;
import org.springframework.security.oauth2.core.endpoint.OAuth2ParameterNames;
import org.springframework.security.web.authentication.AuthenticationConverter;
import org.springframework.util.MultiValueMap;
import org.springframework.util.StringUtils;

import javax.servlet.http.HttpServletRequest;
import java.util.Map;
import java.util.stream.Collectors;


/**
 * @author lacia
 * @date 2022/4/18 - 17:43
 *
 */
@Slf4j
public final class CustomizeUsernamePasswordAuthenticationConverter implements AuthenticationConverter {
    public static final String CUSTOMIZE_CLIENT_PASSWORD = "client_password";

    @Nullable
    @Override
    public Authentication convert(HttpServletRequest request) {
        // grant_type (REQUIRED)
        String grantType = request.getParameter(OAuth2ParameterNames.GRANT_TYPE);
        if (!AuthorizationGrantType.PASSWORD.getValue().equals(grantType)) {
            return null;
        }

        MultiValueMap<String, String> parameters = OAuth2EndpointUtils.getParameters(request);

        // username (REQUIRED)
        String username = parameters.getFirst(OAuth2ParameterNames.USERNAME);
        if (!StringUtils.hasText(username) ||
                parameters.get(OAuth2ParameterNames.USERNAME).size() != 1) {
            OAuth2EndpointUtils.throwError(OAuth2ErrorCodes.INVALID_REQUEST, OAuth2ParameterNames.USERNAME,request.getRequestURI());
        }

        // password (REQUIRED)
        String password = parameters.getFirst(OAuth2ParameterNames.PASSWORD);
        if (StringUtils.hasText(password) &&
                parameters.get(OAuth2ParameterNames.PASSWORD).size() != 1) {
            OAuth2EndpointUtils.throwError(OAuth2ErrorCodes.INVALID_REQUEST, OAuth2ParameterNames.PASSWORD,request.getRequestURI());
        }
        // clientId (REQUIRED)
        String clientId = parameters.getFirst(OAuth2ParameterNames.CLIENT_ID);
        if (StringUtils.hasText(clientId) &&
                parameters.get(OAuth2ParameterNames.CLIENT_ID).size() != 1) {
            OAuth2EndpointUtils.throwError(OAuth2ErrorCodes.INVALID_REQUEST, OAuth2ParameterNames.CLIENT_ID,request.getRequestURI());
        }
        // clientSecret (REQUIRED)
        String clientSecret = parameters.getFirst(CUSTOMIZE_CLIENT_PASSWORD);
        if (StringUtils.hasText(clientSecret) &&
                parameters.get(CUSTOMIZE_CLIENT_PASSWORD).size() != 1) {
            OAuth2EndpointUtils.throwError(OAuth2ErrorCodes.INVALID_REQUEST, CUSTOMIZE_CLIENT_PASSWORD,request.getRequestURI());
        }
        // @formatter:off
        Map<String, Object> additionalParameters = parameters
                .entrySet()
                .stream()
                .filter(e -> !e.getKey().equals(OAuth2ParameterNames.GRANT_TYPE) &&
                        !e.getKey().equals(OAuth2ParameterNames.CLIENT_ID) &&
                        !e.getKey().equals(OAuth2ParameterNames.CLIENT_SECRET) &&
                        !e.getKey().equals(CUSTOMIZE_CLIENT_PASSWORD) &&
                        !e.getKey().equals(OAuth2ParameterNames.USERNAME) &&
                        !e.getKey().equals(OAuth2ParameterNames.PASSWORD))
                .collect(Collectors.toMap(Map.Entry::getKey, e -> e.getValue().get(0)));
        // @formatter:on
        log.info("使用密码模式登陆 {}",username);
        return new CustomizeUsernamePasswordAuthenticationToken(null, username, password, clientId,clientSecret,additionalParameters);
    }
}
