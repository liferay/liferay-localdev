package com.liferay.object.action;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;

@Configuration
@EnableScheduling
@SpringBootApplication
public class CouponActionApp {

  public static void main(String[] args) {
    System.getenv().entrySet().stream()
        .sorted((a, b) -> a.getKey().compareTo(b.getKey()))
        .map(e -> e.getKey() + "=" + e.getValue())
        .forEach(System.out::println);


    Path dxpMetadataPath = Paths.get("/etc/liferay/lxc/dxp-metadata");
    
    try {

		Files.list(dxpMetadataPath).filter(p -> p.getFileName().toString().startsWith("com.liferay.lxc.dxp")).forEach(path -> {
			System.out.println(path + " -> ");
			try {
				System.out.println(Files.readString(path));
			} catch (IOException e1) {
			}
		});
	} catch (IOException e1) {
		// TODO Auto-generated catch block
		e1.printStackTrace();
	}
    
    Path initMetadataPath = Paths.get("/etc/liferay/lxc/ext-init-metadata");
    
    try {
		Files.list(initMetadataPath).filter(p -> p.getFileName().toString().startsWith("coupon-action")).forEach(path -> {
			System.out.println(path + " -> ");
			try {
				System.out.println(Files.readString(path));
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		});
	} catch (IOException e1) {
		// TODO Auto-generated catch block
		e1.printStackTrace();
	}
    SpringApplication.run(CouponActionApp.class, args);
  }
}
