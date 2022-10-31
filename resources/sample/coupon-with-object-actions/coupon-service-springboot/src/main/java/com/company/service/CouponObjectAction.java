package com.company.service;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@RestController
public class CouponObjectAction {

  @PostMapping(
      consumes = MediaType.APPLICATION_JSON_VALUE,
      produces = MediaType.APPLICATION_JSON_VALUE,
      value = "/coupon/updated")
  public ResponseEntity<String> create(
      @AuthenticationPrincipal Jwt jwt,
      @RequestBody String json)
    throws JsonMappingException, JsonProcessingException {

    System.out.println("JWT ID: " + jwt.getId());
    System.out.println("JWT SUBJECT: " + jwt.getSubject());
    System.out.println("JWT CLAIMS: " + jwt.getClaims());

    ObjectMapper objectMapper = new ObjectMapper();
    JsonNode jsonNode = objectMapper.readTree(json);

    String msg = jsonNode.toString();
    System.out.println(msg);
    return new ResponseEntity<>(msg, HttpStatus.CREATED);
  }

}
