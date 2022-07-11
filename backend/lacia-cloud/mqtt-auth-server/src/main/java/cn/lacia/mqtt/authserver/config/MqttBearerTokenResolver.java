package cn.lacia.mqtt.authserver.config;


import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.server.resource.BearerTokenError;
import org.springframework.security.oauth2.server.resource.BearerTokenErrors;
import org.springframework.security.oauth2.server.resource.web.BearerTokenResolver;
import org.springframework.util.StringUtils;

import javax.servlet.http.HttpServletRequest;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author lacia
 * @date 2022/4/21 - 12:31
 *
 * The default {@link BearerTokenResolver} implementation based on RFC 6750.
 *
 * @author Vedran Pavic
 * @since 5.1
 * @see <a href="https://tools.ietf.org/html/rfc6750#section-2" target="_blank">RFC 6750
 * Section 2: Authenticated Requests</a>
 */
public final class MqttBearerTokenResolver implements BearerTokenResolver {

    private static final Pattern authorizationPattern = Pattern.compile("^Bearer (?<token>[a-zA-Z0-9-._~+/]+=*)$",
            Pattern.CASE_INSENSITIVE);

    private boolean allowFormEncodedBodyParameter = false;

    private boolean allowUriQueryParameter = false;

    private String bearerTokenHeaderName = HttpHeaders.AUTHORIZATION;

    @Override
    public String resolve(final HttpServletRequest request) {
        final String authorizationHeaderToken = resolveFromAuthorizationHeader(request);
        final String parameterToken = isParameterTokenSupportedForRequest(request)
                ? resolveFromRequestParameters(request) : null;
        if (authorizationHeaderToken != null) {
            if (parameterToken != null) {
                final BearerTokenError error = BearerTokenErrors
                        .invalidRequest("Found multiple bearer tokens in the request");
                throw new OAuth2AuthenticationException(error);
            }
            return authorizationHeaderToken;
        }
        if (parameterToken != null && isParameterTokenEnabledForRequest(request)) {
            return parameterToken;
        }
        return null;
    }

    /**
     * 设置是否支持使用表单编码的正文参数传输访问令牌。默认为 {@code false}.
     * @param allowFormEncodedBodyParameter 如果支持表单编码的正文参数
     */
    public void setAllowFormEncodedBodyParameter(boolean allowFormEncodedBodyParameter) {
        this.allowFormEncodedBodyParameter = allowFormEncodedBodyParameter;
    }

    /**
     * 设置是否支持使用 URI 查询参数传输访问令牌。默认为 {@code false}.
     *
     * 规范建议不要使用这种机制来发送不记名令牌，甚至声明它只是为了完整性而包含在内。
     * @param allowUriQueryParameter 如果支持 URI 查询参数
     */
    public void setAllowUriQueryParameter(boolean allowUriQueryParameter) {
        this.allowUriQueryParameter = allowUriQueryParameter;
    }

    /**
     * 设置此值以配置解析承载令牌时检查的标头。该值默认为 {@link HttpHeaders#AUTHORIZATION}.
     *
     * 这允许将其他标头用作承载令牌源，例如
     * {@link HttpHeaders#PROXY_AUTHORIZATION}
     * @param bearerTokenHeaderName 检索承载令牌时要检查的标头。
     * @since 5.4
     */
    public void setBearerTokenHeaderName(String bearerTokenHeaderName) {
        this.bearerTokenHeaderName = bearerTokenHeaderName;
    }

    private String resolveFromAuthorizationHeader(HttpServletRequest request) {
        String authorization = request.getHeader(this.bearerTokenHeaderName);
        if (!StringUtils.startsWithIgnoreCase(authorization, "bearer")) {
            return null;
        }
        Matcher matcher = authorizationPattern.matcher(authorization);
        if (!matcher.matches()) {
            BearerTokenError error = BearerTokenErrors.invalidToken("令牌格式错误");
            throw new OAuth2AuthenticationException(error);
        }
        return matcher.group("token");
    }

    private static String resolveFromRequestParameters(HttpServletRequest request) {
//        String[] values = request.getParameterValues("access_token");
        String[] values = request.getParameterValues("username");
        if (values == null || values.length == 0) {
            return null;
        }
        if (values.length == 1) {
            return values[0];
        }
        BearerTokenError error = BearerTokenErrors.invalidRequest("在请求中发现多个令牌");
        throw new OAuth2AuthenticationException(error);
    }

    private boolean isParameterTokenSupportedForRequest(final HttpServletRequest request) {
        return (("POST".equals(request.getMethod())
                && MediaType.APPLICATION_FORM_URLENCODED_VALUE.equals(request.getContentType()))
                || "GET".equals(request.getMethod()));
    }

    private boolean isParameterTokenEnabledForRequest(final HttpServletRequest request) {
        return ((this.allowFormEncodedBodyParameter && "POST".equals(request.getMethod())
                && MediaType.APPLICATION_FORM_URLENCODED_VALUE.equals(request.getContentType()))
                || (this.allowUriQueryParameter && "GET".equals(request.getMethod())));
    }

}

