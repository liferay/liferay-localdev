package com.liferay.object.action.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.client.AuthorizedClientServiceReactiveOAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.InMemoryReactiveOAuth2AuthorizedClientService;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.InMemoryReactiveClientRegistrationRepository;
import org.springframework.security.oauth2.client.registration.ReactiveClientRegistrationRepository;
import org.springframework.security.oauth2.client.web.reactive.function.client.ServerOAuth2AuthorizedClientExchangeFilterFunction;
import org.springframework.security.oauth2.core.AuthorizationGrantType;
import org.springframework.security.oauth2.core.ClientAuthenticationMethod;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class OAuthClientConfiguration {

  @Bean
  public ReactiveClientRegistrationRepository clientRegistrations(
      @Value("${coupon-action-user-agent.oauth2.authorization.uri}") String authorizationUri,
      @Value("${coupon-action-user-agent.oauth2.redirect.uris}") String redirectUris,
      @Value("${coupon-action-user-agent.oauth2.introspection.uri}") String introspectionUri,
      @Value("${coupon-action-user-agent.oauth2.user.agent.client.id}") String clientId,
      @Value("${coupon-action-user-agent.oauth2.token.uri}") String tokenUri,
      @Value("${coupon-action-user-agent.oauth2.user.agent.scopes}") String scopes) {

    ClientRegistration registration =
        ClientRegistration.withRegistrationId("dxp")
            .tokenUri(tokenUri)
            .clientId(clientId)
            .scope(scopes)
            .authorizationGrantType(AuthorizationGrantType.CLIENT_CREDENTIALS)
            .clientAuthenticationMethod(ClientAuthenticationMethod.CLIENT_SECRET_POST)
            .build();

    return new InMemoryReactiveClientRegistrationRepository(registration);
  }

  @Bean
  public WebClient webClient(ReactiveClientRegistrationRepository clientRegistrations) {
    ServerOAuth2AuthorizedClientExchangeFilterFunction oauth =
        new ServerOAuth2AuthorizedClientExchangeFilterFunction(
            new AuthorizedClientServiceReactiveOAuth2AuthorizedClientManager(
                clientRegistrations,
                new InMemoryReactiveOAuth2AuthorizedClientService(clientRegistrations)));

    oauth.setDefaultClientRegistrationId("dxp");

    return WebClient.builder().filter(oauth).build();
  }
}
