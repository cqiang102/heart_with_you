package cn.lacia.auth.server.config.oauth2;

import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.SpringSecurityCoreVersion;
import org.springframework.security.oauth2.core.AuthorizationGrantType;
import org.springframework.security.oauth2.server.authorization.client.RegisteredClient;

import java.util.Collection;
import java.util.Collections;
import java.util.Map;

/**
 * @author lacia
 * @date 2022/4/18 - 17:47
 */
public class CustomizeUsernamePasswordAuthenticationToken extends AbstractAuthenticationToken {
    private static final long serialVersionUID = SpringSecurityCoreVersion.SERIAL_VERSION_UID;

    private final String username;

    private final String password;

    private final String clientId;
    private final String clientSecret;

    public String getClientId() {
        return clientId;
    }

    public String getClientSecret() {
        return clientSecret;
    }

    public RegisteredClient getRegisteredClient() {
        return registeredClient;
    }

    private final RegisteredClient registeredClient;

    private final AuthorizationGrantType authorizationGrantType;
    private final Authentication clientPrincipal;
    private final Map<String, Object> additionalParameters;

    public CustomizeUsernamePasswordAuthenticationToken(Authentication clientPrincipal, String username,
                                                        String password, String clientId, String clientSecret,
                                                        Map<String, Object> additionalParameters) {
        super(Collections.emptyList());
        this.clientPrincipal = clientPrincipal;
        this.username = username;
        this.password = password;
        this.clientId = clientId;
        this.clientSecret = clientSecret;
        this.registeredClient = null;
        this.authorizationGrantType = AuthorizationGrantType.PASSWORD;
        this.additionalParameters = additionalParameters;
        setAuthenticated(false);
    }

    public CustomizeUsernamePasswordAuthenticationToken(Authentication clientPrincipal, String username,
                                                        String password, RegisteredClient registeredClient,
                                                        Map<String, Object> additionalParameters, Collection<?
            extends GrantedAuthority> authorities) {
        super(authorities);
        this.username = username;
        this.password = password;
        this.registeredClient = registeredClient;
        this.clientId = registeredClient.getClientId();
        this.clientSecret = registeredClient.getClientSecret();
        this.authorizationGrantType = AuthorizationGrantType.PASSWORD;
        this.clientPrincipal = clientPrincipal;
        this.additionalParameters = additionalParameters;
        super.setAuthenticated(true);
    }

    public String getUsername() {
        return username;
    }

    public String getPassword() {
        return password;
    }

    public AuthorizationGrantType getAuthorizationGrantType() {
        return authorizationGrantType;
    }

    public Authentication getClientPrincipal() {
        return clientPrincipal;
    }

    public Map<String, Object> getAdditionalParameters() {
        return additionalParameters;
    }

    @Override
    public Object getCredentials() {
        return "";
    }

    @Override
    public Object getPrincipal() {
        return clientPrincipal;
    }
}
