# Решение 006: Выбор Spring Boot фреймворка

**Дата:** 2025-01-02  
**Статус:** ✅ Принято  
**Участники:** Александр  

## Проблема

Необходимо выбрать бэкенд фреймворк для системы управления отношениями с контрагентами FEPRO с учетом:
- Производительность и масштабируемость
- Экосистема и инструменты
- Простота разработки и поддержки
- Интеграция с другими технологиями

## Рассмотренные варианты

### 1. Spring Boot
- **Описание:** Фреймворк для создания Spring приложений
- **Плюсы:** Богатая экосистема, автоматическая конфигурация, широкое распространение
- **Минусы:** Сложность, большой размер, потенциальные проблемы с производительностью

### 2. Micronaut
- **Описание:** Современный фреймворк для микросервисов
- **Плюсы:** Быстрый старт, низкое потребление памяти, compile-time DI
- **Минусы:** Меньшая экосистема, learning curve

### 3. Quarkus
- **Описание:** Kubernetes-native фреймворк
- **Плюсы:** Быстрый старт, низкое потребление памяти, GraalVM
- **Минусы:** Меньшая зрелость, ограниченная экосистема

## Решение

Выбран **Spring Boot 3.4.5** по следующим причинам:

### Основные преимущества:
1. **Богатая экосистема** - множество готовых решений
2. **Автоматическая конфигурация** - быстрый старт разработки
3. **Широкое распространение** - много ресурсов и сообщества
4. **Интеграция** - отличная поддержка GraphQL, JPA, Security
5. **Зрелость** - проверенное временем решение

### Архитектурные решения:

#### Spring Boot 3 + Java 21
```java
@SpringBootApplication
@EnableJpaRepositories
@EnableGraphQl
public class FeproApplication {
    public static void main(String[] args) {
        SpringApplication.run(FeproApplication.class, args);
    }
}
```

#### Модульная структура
```java
// Модуль contractor-management
@RestController
@RequestMapping("/api/contractors")
@Validated
public class ContractorController {
    
    private final ContractorService contractorService;
    
    @GetMapping
    public ResponseEntity<List<Contractor>> getContractors(
            @RequestParam(required = false) String status) {
        return ResponseEntity.ok(contractorService.findByStatus(status));
    }
    
    @PostMapping
    public ResponseEntity<Contractor> createContractor(
            @Valid @RequestBody ContractorInput input) {
        return ResponseEntity.ok(contractorService.create(input));
    }
}
```

#### GraphQL Integration
```java
@Controller
public class ContractorResolver {
    
    private final ContractorService contractorService;
    
    @QueryMapping
    public List<Contractor> contractors(@Argument ContractorFilter filter) {
        return contractorService.findContractors(filter);
    }
    
    @MutationMapping
    public Contractor createContractor(@Argument ContractorInput input) {
        return contractorService.createContractor(input);
    }
}
```

## Реализация

### Maven Configuration
```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.4.5</version>
    <relativePath/>
</parent>

<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-graphql</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
</dependencies>
```

### Configuration Classes
```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/contractors/**").hasRole("USER")
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class)
            .build();
    }
}
```

### Service Layer
```java
@Service
@Transactional
public class ContractorService {
    
    private final ContractorRepository contractorRepository;
    private final ContractorMapper contractorMapper;
    
    public List<Contractor> findContractors(ContractorFilter filter) {
        Specification<Contractor> spec = ContractorSpecifications.buildSpecification(filter);
        return contractorRepository.findAll(spec);
    }
    
    public Contractor createContractor(ContractorInput input) {
        Contractor contractor = contractorMapper.toEntity(input);
        return contractorRepository.save(contractor);
    }
}
```

## Последствия

### Положительные:
- ✅ Богатая экосистема
- ✅ Автоматическая конфигурация
- ✅ Широкое распространение
- ✅ Отличная документация
- ✅ Мощные возможности

### Отрицательные:
- ⚠️ Сложность для новичков
- ⚠️ Большой размер приложения
- ⚠️ Потенциальные проблемы с производительностью
- ⚠️ Много "магии" под капотом

## Стратегия оптимизации

### 1. Производительность
- **Lazy loading** - загрузка данных по требованию
- **Caching** - кэширование часто используемых данных
- **Connection pooling** - оптимизация соединений с БД
- **Async processing** - асинхронная обработка

### 2. Мониторинг
```yaml
# application.yml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: always
  metrics:
    export:
      prometheus:
        enabled: true
```

### 3. Логирование
```yaml
logging:
  level:
    root: INFO
    com.fepro: DEBUG
  file:
    name: /app/logs/fepro.log
    max-size: 10MB
    max-history: 7
```

## Best Practices

### 1. Структура пакетов
```
com.fepro
├── config/          # Конфигурационные классы
├── controller/      # REST контроллеры
├── resolver/        # GraphQL резолверы
├── service/         # Бизнес-логика
├── repository/      # Доступ к данным
├── entity/          # JPA сущности
├── dto/             # Data Transfer Objects
├── mapper/          # Мапперы между DTO и Entity
└── exception/       # Обработка исключений
```

### 2. Обработка ошибок
```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(ContractorNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleContractorNotFound(
            ContractorNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse("CONTRACTOR_NOT_FOUND", ex.getMessage()));
    }
}
```

### 3. Валидация
```java
public class ContractorInput {
    
    @NotBlank(message = "Name is required")
    @Size(max = 255, message = "Name too long")
    private String name;
    
    @Email(message = "Invalid email format")
    private String email;
    
    @Pattern(regexp = "^\\d{10}$|^\\d{12}$", message = "Invalid INN format")
    private String inn;
}
```

## Инструменты разработки

### Основные инструменты:
- **Spring Boot DevTools** - автоматическая перезагрузка
- **Spring Boot Actuator** - мониторинг и управление
- **Spring Boot Test** - тестирование
- **Spring Boot Maven Plugin** - сборка и запуск

### IDE поддержка:
- **IntelliJ IDEA** - отличная поддержка Spring
- **VS Code** - с расширениями Spring
- **Eclipse** - с Spring Tools

## Альтернативы на будущее

При росте требований к производительности:
1. **Micronaut** - для микросервисов
2. **Quarkus** - для Kubernetes
3. **Vert.x** - для реактивных приложений

## Связанные решения

- [003-graphql-api-choice.md](./003-graphql-api-choice.md) - GraphQL API
- [007-modular-monolith-pattern.md](./007-modular-monolith-pattern.md) - Modular Monolith
- [009-jwt-security-approach.md](./009-jwt-security-approach.md) - JWT Security
- [backend-architecture.md](../architecture/backend-architecture.md) - Архитектура бэкенда