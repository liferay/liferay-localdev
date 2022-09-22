package com.liferay.object.action;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequestMapping(value = "/coupons")
@RestController
public class CouponsController {

  @Qualifier("mainDomain")
  @Resource
  private String _mainDomain;


  @PostMapping(
      consumes = MediaType.APPLICATION_JSON_VALUE,
      produces = MediaType.APPLICATION_JSON_VALUE,
      value = "/issued")
  public ResponseEntity<String> create(@RequestBody String couponJson, @AuthenticationPrincipal OAuth2User principal) {
    System.out.println("HERE IS THE OBJECT JSON: " + couponJson);
    System.out.println("HERE IS THE OAuth2User principal: " + principal);

    return new ResponseEntity<>("OK", HttpStatus.CREATED);
  }

}
