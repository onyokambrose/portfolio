package com.onyokambrose.portfolio;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

/**
 * Entry point for the Onyok Ambrose portfolio API.
 *
 * Flyway runs the SQL migrations in db/migration before the application
 * starts serving requests, so the schema is always up to date on Render.
 */
@SpringBootApplication
@ConfigurationPropertiesScan
public class PortfolioApplication {

    public static void main(String[] args) {
        SpringApplication.run(PortfolioApplication.class, args);
    }
}
