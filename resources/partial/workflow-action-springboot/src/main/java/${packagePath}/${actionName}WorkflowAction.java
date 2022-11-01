package ${package};

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.reactive.function.client.WebClient;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import reactor.core.publisher.Mono;

@RestController
public class ${actionName}WorkflowAction {

  private final String _mainDomain;
  private final WebClient _webClient;

  public ${actionName}WorkflowAction(@Qualifier("mainDomain") String mainDomain) {
    _mainDomain = mainDomain;
    _webClient = WebClient.builder().baseUrl(
      "https://".concat(_mainDomain)
    ).defaultHeader(
      HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE
    ).defaultHeader(
      HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE
    ).build();
  }

  @PostMapping(
      consumes = MediaType.APPLICATION_JSON_VALUE,
      value = "${resourcePath}")
  public ResponseEntity<String> action(
      @AuthenticationPrincipal Jwt jwt,
      @RequestBody JsonNode jsonNode)
    throws JsonMappingException, JsonProcessingException {

    System.out.println("JWT ID: " + jwt.getId());
    System.out.println("JWT SUBJECT: " + jwt.getSubject());
    System.out.println("JWT CLAIMS: " + jwt.getClaims());
    System.out.println("WORKFLOW INPUT: " + jsonNode.toString());

    String transition = decideHowToTransitionTheTask(jsonNode);

    transitionTheTask(
      jsonNode.get("transitionURL").asText(), transition,
      jwt.getTokenValue());

    return new ResponseEntity<>(HttpStatus.OK);
  }

  /*
   * Use the information in workflowTaskDetails to calculate a transition. The
   * available transition as found in the "next-transitions" property of the
   * workflowPayload.
   */
  private String decideHowToTransitionTheTask(JsonNode workflowPayload) {
    JsonNode nextTransitions = workflowPayload.get("nextTransitionNames");

    System.out.println("Available transitions: " + nextTransitions);

    return "approve";
  }

  /*
   * Make an API call back to the
   */
  private void transitionTheTask(
    String transitionURI, String transition, String jwtToken) {

    _webClient.post().uri(
      transitionURI
    ).header(
      HttpHeaders.AUTHORIZATION, "Bearer " + jwtToken
    ).bodyValue(
      new ObjectMapper().createObjectNode().put(
        "transitionName", transition
      )
    ).exchangeToMono(
      r -> {
        if (r.statusCode().equals(HttpStatus.OK)) {
            return r.bodyToMono(String.class);
        }
        else if (r.statusCode().is4xxClientError()) {
            return Mono.just("Error response");
        }
        else {
            return r.createException()
              .flatMap(Mono::error);
        }
      }
    ).doOnNext(System.out::println).subscribe();
  }

}
