package cn.lacia.auth.server.config.oauth2;

import cn.lacia.auth.server.model.BindUserDetails;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.core.AbstractOAuth2Token;
import org.springframework.security.oauth2.core.AuthorizationGrantType;
import org.springframework.security.oauth2.core.ClaimAccessor;
import org.springframework.security.oauth2.core.OAuth2AccessToken;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.OAuth2AuthorizationCode;
import org.springframework.security.oauth2.core.OAuth2Error;
import org.springframework.security.oauth2.core.OAuth2ErrorCodes;
import org.springframework.security.oauth2.core.OAuth2RefreshToken;
import org.springframework.security.oauth2.core.OAuth2Token;
import org.springframework.security.oauth2.core.OAuth2TokenType;
import org.springframework.security.oauth2.core.user.OAuth2UserAuthority;
import org.springframework.security.oauth2.server.authorization.OAuth2Authorization;
import org.springframework.security.oauth2.server.authorization.OAuth2AuthorizationService;
import org.springframework.security.oauth2.server.authorization.OAuth2TokenContext;
import org.springframework.security.oauth2.server.authorization.authentication.OAuth2AccessTokenAuthenticationToken;
import org.springframework.security.oauth2.server.authorization.authentication.OAuth2AuthorizationCodeAuthenticationToken;
import org.springframework.security.oauth2.server.authorization.authentication.OAuth2ClientAuthenticationToken;
import org.springframework.security.oauth2.server.authorization.client.RegisteredClient;
import org.springframework.security.oauth2.server.authorization.client.RegisteredClientRepository;
import org.springframework.security.oauth2.server.authorization.context.ProviderContextHolder;
import org.springframework.security.oauth2.server.authorization.token.DefaultOAuth2TokenContext;
import org.springframework.security.oauth2.server.authorization.token.OAuth2RefreshTokenGenerator;
import org.springframework.security.oauth2.server.authorization.token.OAuth2TokenGenerator;
import org.springframework.util.Assert;

import java.security.Principal;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Objects;
import java.util.function.Supplier;


/**
 * @author lacia
 * @date 2022/4/18 - 19:04
 */
@Slf4j
public class OAuth2PasswordAuthenticationProvider extends DaoAuthenticationProvider {
    private static final String ERROR_URI = "https://datatracker.ietf.org/doc/html/rfc6749#section-5.2";

    private final OAuth2AuthorizationService authorizationService;
    private final RegisteredClientRepository registeredClientRepository;
    private final PasswordEncoder passwordEncoder;


    private  OAuth2TokenGenerator<? extends OAuth2Token> tokenGenerator;

    @Deprecated
    private Supplier<String> refreshTokenGenerator;

    /**
     * Constructs an {@code OAuth2PasswordAuthenticationProvider} using the provided parameters.
     *
     * @param authorizationService       the authorization service
     * @param registeredClientRepository
     * @param passwordEncoder
     * @param tokenGenerator             the token generator
     * @since 0.2.3
     */
    public OAuth2PasswordAuthenticationProvider(OAuth2AuthorizationService authorizationService,
                                                RegisteredClientRepository registeredClientRepository,
                                                PasswordEncoder passwordEncoder, OAuth2TokenGenerator<?
            extends OAuth2Token> tokenGenerator) {
        super();
        setPasswordEncoder(passwordEncoder);
        this.registeredClientRepository = registeredClientRepository;
        this.passwordEncoder = passwordEncoder;
        Assert.notNull(authorizationService, "authorizationService cannot be null");
        Assert.notNull(tokenGenerator, "tokenGenerator cannot be null");
        this.authorizationService = authorizationService;
        this.tokenGenerator = tokenGenerator;

    }

    /**
     * Sets the {@code Supplier<String>} that generates the value for the {@link OAuth2RefreshToken}.
     *
     * @param refreshTokenGenerator the {@code Supplier<String>} that generates the value for the
     *                              {@link OAuth2RefreshToken}
     * @deprecated Use {@link OAuth2RefreshTokenGenerator} instead
     */
    @Deprecated
    public void setRefreshTokenGenerator(Supplier<String> refreshTokenGenerator) {
        Assert.notNull(refreshTokenGenerator, "refreshTokenGenerator cannot be null");
        this.refreshTokenGenerator = refreshTokenGenerator;
    }

    @Override
    public Authentication authenticate(Authentication authentication) throws AuthenticationException {
        CustomizeUsernamePasswordAuthenticationToken customizeToken =
                (CustomizeUsernamePasswordAuthenticationToken) authentication;

        // 验证用户名密码
        UsernamePasswordAuthenticationToken authenticationToken =
                new UsernamePasswordAuthenticationToken(customizeToken.getUsername(), customizeToken.getPassword());
        Authentication authenticate = super.authenticate(authenticationToken);
        if (Objects.isNull(authenticate)) {
            throw new OAuth2AuthenticationException(OAuth2ErrorCodes.ACCESS_DENIED);
        }
        // 获取 RegisteredClient 信息
        RegisteredClient registeredClient = registeredClientRepository.findByClientId(customizeToken.getClientId());
        if (Objects.isNull(registeredClient)
                || !passwordEncoder.matches(customizeToken.getClientSecret(),registeredClient.getClientSecret())) {
            throw new OAuth2AuthenticationException(OAuth2ErrorCodes.UNAUTHORIZED_CLIENT);
        }
        if(! registeredClient.getAuthorizationGrantTypes().contains(AuthorizationGrantType.PASSWORD)){
            throw new OAuth2AuthenticationException(OAuth2ErrorCodes.UNSUPPORTED_GRANT_TYPE);
        }
        OAuth2Authorization.Builder builder = OAuth2Authorization.withRegisteredClient(registeredClient)
                .principalName(authenticate.getName())
                .attribute(Principal.class.getName(),authenticate)
                .attribute(OAuth2Authorization.AUTHORIZED_SCOPE_ATTRIBUTE_NAME,registeredClient.getScopes() )
                .authorizationGrantType(customizeToken.getAuthorizationGrantType());
        OAuth2Authorization build = builder.build();
        DefaultOAuth2TokenContext.Builder tokenContextBuilder = DefaultOAuth2TokenContext.builder()
                .registeredClient(registeredClient)
                .principal(authenticate)
                .providerContext(ProviderContextHolder.getProviderContext())
                .authorization(build)
                .authorizedScopes(registeredClient.getScopes())
                .authorizationGrantType(AuthorizationGrantType.PASSWORD)
                .authorizationGrant(customizeToken);

        OAuth2Authorization.Builder authorizationBuilder = OAuth2Authorization.from(build);

        // ----- Access token -----
        OAuth2TokenContext tokenContext = tokenContextBuilder.tokenType(OAuth2TokenType.ACCESS_TOKEN).build();
        OAuth2Token generatedAccessToken = this.tokenGenerator.generate(tokenContext);
        if (generatedAccessToken == null) {
            OAuth2Error error = new OAuth2Error(OAuth2ErrorCodes.SERVER_ERROR,
                    "The token generator failed to generate the access token.", ERROR_URI);
            throw new OAuth2AuthenticationException(error);
        }
        OAuth2AccessToken accessToken = new OAuth2AccessToken(OAuth2AccessToken.TokenType.BEARER,
                generatedAccessToken.getTokenValue(), generatedAccessToken.getIssuedAt(),
                generatedAccessToken.getExpiresAt(), tokenContext.getAuthorizedScopes());
        if (generatedAccessToken instanceof ClaimAccessor) {
            authorizationBuilder.token(accessToken, (metadata) ->
                    metadata.put(OAuth2Authorization.Token.CLAIMS_METADATA_NAME,
                            ((ClaimAccessor) generatedAccessToken).getClaims()));
        } else {
            authorizationBuilder.accessToken(accessToken);
        }

        // ----- Refresh token -----
        OAuth2RefreshToken refreshToken = null;
        if (registeredClient.getAuthorizationGrantTypes().contains(AuthorizationGrantType.REFRESH_TOKEN)) {

            if (this.refreshTokenGenerator != null) {
                Instant issuedAt = Instant.now();
                Instant expiresAt = issuedAt.plus(registeredClient.getTokenSettings().getRefreshTokenTimeToLive());
                refreshToken = new OAuth2RefreshToken(this.refreshTokenGenerator.get(), issuedAt, expiresAt);
            } else {
                tokenContext = tokenContextBuilder.tokenType(OAuth2TokenType.REFRESH_TOKEN).build();
                OAuth2Token generatedRefreshToken = this.tokenGenerator.generate(tokenContext);
                if (!(generatedRefreshToken instanceof OAuth2RefreshToken)) {
                    OAuth2Error error = new OAuth2Error(OAuth2ErrorCodes.SERVER_ERROR,
                            "The token generator failed to generate the refresh token.", ERROR_URI);
                    throw new OAuth2AuthenticationException(error);
                }
                refreshToken = (OAuth2RefreshToken) generatedRefreshToken;
            }
            authorizationBuilder.refreshToken(refreshToken);
        }


        build = authorizationBuilder.build();


        this.authorizationService.save(build);

        Map<String, Object> additionalParameters = new HashMap<>();
        additionalParameters.put("info",authenticate.getPrincipal());
        ArrayList<OAuth2UserAuthority> authorities = new ArrayList<>();
        authorities.add(new OAuth2UserAuthority("User", additionalParameters));

        CustomizeUsernamePasswordAuthenticationToken customizeUsernamePasswordAuthenticationToken =
                new CustomizeUsernamePasswordAuthenticationToken(
                        authenticate, customizeToken.getUsername(), customizeToken.getPassword(),
                        registeredClient, additionalParameters, authorities
                );
        SecurityContextHolder.clearContext();
        log.info("密码模式生成 token");
        return new OAuth2AccessTokenAuthenticationToken(
                registeredClient, customizeUsernamePasswordAuthenticationToken, accessToken, refreshToken,additionalParameters);
    }

    @Override
    public boolean supports(Class<?> authentication) {
        return CustomizeUsernamePasswordAuthenticationToken.class.isAssignableFrom(authentication);
    }

}
