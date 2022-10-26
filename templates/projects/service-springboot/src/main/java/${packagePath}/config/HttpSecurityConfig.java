package ${package}.config;

import java.net.URL;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.config.annotation.web.configurers.oauth2.server.resource.OAuth2ResourceServerConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import com.nimbusds.jose.JOSEObjectType;
import com.nimbusds.jose.proc.DefaultJOSEObjectTypeVerifier;
import com.nimbusds.jose.proc.JWSAlgorithmFamilyJWSKeySelector;
import com.nimbusds.jose.proc.JWSKeySelector;
import com.nimbusds.jose.proc.SecurityContext;
import com.nimbusds.jwt.proc.DefaultJWTProcessor;

@Configuration
public class HttpSecurityConfig extends WebSecurityConfigurerAdapter {

	@Value("${com.liferay.lxc.dxp.mainDomain}")
	private String _mainDomain;

	@Bean
	public String mainDomain() {
		return _mainDomain;
	}

	@Value("${com.liferay.lxc.dxp.domains}")
	private String _lxcDXPDomains;

	@Bean
	public List<String> allowedOrigins() {
		return Stream.of(
			_lxcDXPDomains.split("\\s*\n\\s*")
		).map(
			String::trim
		).map(
			"https://"::concat
		).collect(
			Collectors.toList()
		);
	}

	@Bean
	public CorsConfigurationSource corsConfigurationSource() {
		CorsConfiguration configuration = new CorsConfiguration();
		configuration.setAllowedOrigins(allowedOrigins());
		configuration.setAllowedMethods(
			Arrays.asList("DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"));
		configuration.setAllowedHeaders(
			Arrays.asList("Authorization", "Content-Type"));
		UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
		source.registerCorsConfiguration("/**", configuration);
		return source;
	}

	@Override
	protected void configure(HttpSecurity httpSecurity) throws Exception {
		httpSecurity.cors(
		).and(
		).csrf(
		).disable(
		).sessionManagement().sessionCreationPolicy(
			SessionCreationPolicy.STATELESS
		);
	}

}
