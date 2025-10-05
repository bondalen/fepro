package io.github.bondalen.fepro;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Главный класс приложения FEPRO
 * Federation Professionals - система управления отношениями с контрагентами
 */
@SpringBootApplication
public class FeproApplication {

    public static void main(String[] args) {
        SpringApplication.run(FeproApplication.class, args);
    }
}