package com.liferay.object.action;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequestMapping("/")
@RestController
public class HealthResource {

  @GetMapping("/")
  public String ready() {
    return "READY";
  }
}
