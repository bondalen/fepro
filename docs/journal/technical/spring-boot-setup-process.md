# Процесс настройки Spring Boot

## Обзор процесса

Пошаговое описание процесса настройки Spring Boot приложения для проекта FEPRO.

## Этапы настройки

### 1. Создание Maven проекта
- Инициализация проекта с Spring Boot Starter
- Настройка базовой структуры каталогов
- Конфигурация pom.xml

### 2. Добавление зависимостей
- Spring Boot Starter Web
- Spring Boot Starter Data JPA
- Spring Boot Starter Security
- Spring Boot Starter Test

### 3. Настройка плагинов
- Spring Boot Maven Plugin
- Maven Compiler Plugin
- Maven Surefire Plugin

### 4. Создание основного класса
- Аннотация @SpringBootApplication
- Метод main()
- Базовая конфигурация

## Конфигурационные файлы

### pom.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.4.5</version>
        <relativePath/>
    </parent>
    
    <groupId>io.github.bondalen</groupId>
    <artifactId>fepro-backend</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>
    
    <properties>
        <java.version>21</java.version>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

### application.yml
```yaml
spring:
  application:
    name: fepro-backend
  profiles:
    active: dev

server:
  port: 8080

logging:
  level:
    io.github.bondalen.fepro: DEBUG
    org.springframework: INFO
```

## Основной класс приложения

### FeproApplication.java
```java
package io.github.bondalen.fepro;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class FeproApplication {
    public static void main(String[] args) {
        SpringApplication.run(FeproApplication.class, args);
    }
}
```

## Проверка настройки

### Команды для проверки
```bash
# Сборка проекта
mvn clean compile

# Запуск приложения
mvn spring-boot:run

# Проверка health endpoint
curl http://localhost:8080/actuator/health
```

## Следующие шаги

1. Настройка базы данных
2. Создание доменных моделей
3. Реализация репозиториев
4. Создание сервисов
5. Настройка контроллеров