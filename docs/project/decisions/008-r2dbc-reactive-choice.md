# Решение 008: R2DBC реактивный подход

**Дата:** 2025-01-02  
**Статус:** ✅ Принято  
**Участники:** Александр  

## Проблема

Необходимо выбрать подход к работе с базой данных в Spring Boot приложении FEPRO с учетом:
- Производительность и масштабируемость
- Реактивное программирование
- Интеграция с Spring WebFlux
- Совместимость с PostgreSQL

## Рассмотренные варианты

### 1. JPA/Hibernate
- **Описание:** Классический ORM подход с блокирующими операциями
- **Плюсы:** Простота, богатая функциональность, автоматическая генерация SQL
- **Минусы:** Блокирующие операции, проблемы с производительностью, N+1 проблемы

### 2. R2DBC
- **Описание:** Реактивный драйвер для реляционных баз данных
- **Плюсы:** Неблокирующие операции, высокая производительность, реактивность
- **Минусы:** Сложность, ограниченная функциональность, learning curve

### 3. Spring Data JDBC
- **Описание:** Упрощенный подход к работе с БД
- **Плюсы:** Простота, производительность, минимальная абстракция
- **Минусы:** Нет автоматической генерации SQL, больше ручной работы

## Решение

Выбран **R2DBC** по следующим причинам:

### Основные преимущества:
1. **Неблокирующие операции** - высокая производительность
2. **Реактивность** - интеграция с Spring WebFlux
3. **Масштабируемость** - эффективное использование ресурсов
4. **Современный подход** - соответствует трендам разработки
5. **Производительность** - меньше потребление памяти

### Архитектурные решения:

#### R2DBC Configuration
```java
@Configuration
@EnableR2dbcRepositories
public class R2dbcConfig {
    
    @Bean
    public ConnectionFactory connectionFactory() {
        return new PostgresqlConnectionFactory(
            PostgresqlConnectionConfiguration.builder()
                .host("localhost")
                .port(5432)
                .database("fepro_dev")
                .username("fepro_user")
                .password("fepro_pass")
                .build()
        );
    }
}
```

#### Reactive Repository
```java
@Repository
public interface ContractorRepository extends ReactiveCrudRepository<Contractor, UUID> {
    
    Flux<Contractor> findByStatus(String status);
    
    Mono<Contractor> findByInn(String inn);
    
    @Query("SELECT * FROM contractors WHERE ST_DWithin(coordinates, ST_Point($1, $2), $3)")
    Flux<Contractor> findNearbyContractors(double lng, double lat, double radius);
    
    @Query("SELECT * FROM contractors WHERE name ILIKE $1")
    Flux<Contractor> findByNameContaining(String name);
}
```

#### Reactive Service
```java
@Service
@Transactional
public class ContractorService {
    
    private final ContractorRepository contractorRepository;
    private final ContractorMapper contractorMapper;
    
    public Mono<Contractor> createContractor(ContractorInput input) {
        return contractorMapper.toEntity(input)
            .flatMap(contractorRepository::save);
    }
    
    public Flux<Contractor> findContractors(ContractorFilter filter) {
        return contractorRepository.findAll()
            .filter(contractor -> matchesFilter(contractor, filter));
    }
    
    public Mono<Contractor> updateContractor(UUID id, ContractorInput input) {
        return contractorRepository.findById(id)
            .switchIfEmpty(Mono.error(new ContractorNotFoundException(id)))
            .flatMap(contractor -> contractorMapper.updateEntity(contractor, input))
            .flatMap(contractorRepository::save);
    }
}
```

## Реализация

### Maven Dependencies
```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-r2dbc</artifactId>
    </dependency>
    <dependency>
        <groupId>io.r2dbc</groupId>
        <artifactId>r2dbc-postgresql</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-webflux</artifactId>
    </dependency>
</dependencies>
```

### Entity Definition
```java
@Table("contractors")
public class Contractor {
    
    @Id
    private UUID id;
    
    @Column("name")
    private String name;
    
    @Column("inn")
    private String inn;
    
    @Column("email")
    private String email;
    
    @Column("status")
    private String status;
    
    @Column("coordinates")
    private String coordinates; // JSON representation
    
    @Column("created_at")
    private LocalDateTime createdAt;
    
    @Column("updated_at")
    private LocalDateTime updatedAt;
    
    // constructors, getters, setters
}
```

### Reactive Controller
```java
@RestController
@RequestMapping("/api/contractors")
public class ContractorController {
    
    private final ContractorService contractorService;
    
    @GetMapping
    public Flux<Contractor> getContractors(
            @RequestParam(required = false) String status) {
        return contractorService.findContractors(
            ContractorFilter.builder().status(status).build()
        );
    }
    
    @PostMapping
    public Mono<ResponseEntity<Contractor>> createContractor(
            @Valid @RequestBody ContractorInput input) {
        return contractorService.createContractor(input)
            .map(ResponseEntity::ok)
            .onErrorReturn(ResponseEntity.badRequest().build());
    }
    
    @GetMapping("/{id}")
    public Mono<ResponseEntity<Contractor>> getContractor(@PathVariable UUID id) {
        return contractorService.findById(id)
            .map(ResponseEntity::ok)
            .switchIfEmpty(Mono.just(ResponseEntity.notFound().build()));
    }
}
```

## Последствия

### Положительные:
- ✅ Неблокирующие операции
- ✅ Высокая производительность
- ✅ Реактивность
- ✅ Масштабируемость
- ✅ Современный подход

### Отрицательные:
- ⚠️ Сложность изучения
- ⚠️ Ограниченная функциональность
- ⚠️ Потенциальные проблемы с транзакциями
- ⚠️ Сложность отладки

## Стратегия реализации

### 1. Постепенная миграция
- **Phase 1:** Новые компоненты на R2DBC
- **Phase 2:** Миграция существующих компонентов
- **Phase 3:** Полный переход на реактивность

### 2. Гибридный подход
```java
@Configuration
public class DatabaseConfig {
    
    @Bean
    @Primary
    public DataSource dataSource() {
        // JPA для сложных запросов
        return new HikariDataSource();
    }
    
    @Bean
    public ConnectionFactory r2dbcConnectionFactory() {
        // R2DBC для простых операций
        return new PostgresqlConnectionFactory(...);
    }
}
```

### 3. Обработка ошибок
```java
@Service
public class ContractorService {
    
    public Mono<Contractor> findById(UUID id) {
        return contractorRepository.findById(id)
            .switchIfEmpty(Mono.error(new ContractorNotFoundException(id)))
            .onErrorMap(DataAccessException.class, ex -> 
                new ServiceException("Database error", ex));
    }
}
```

## Best Practices

### 1. Реактивные паттерны
- **Backpressure** - управление нагрузкой
- **Error handling** - правильная обработка ошибок
- **Composition** - комбинирование операций
- **Testing** - тестирование реактивных потоков

### 2. Производительность
- **Connection pooling** - пул соединений
- **Query optimization** - оптимизация запросов
- **Caching** - кэширование результатов
- **Monitoring** - мониторинг производительности

### 3. Тестирование
```java
@ExtendWith(SpringExtension.class)
@SpringBootTest
class ContractorServiceTest {
    
    @Autowired
    private ContractorService contractorService;
    
    @Test
    void shouldCreateContractor() {
        ContractorInput input = new ContractorInput("Test Company", "1234567890");
        
        StepVerifier.create(contractorService.createContractor(input))
            .assertNext(contractor -> {
                assertThat(contractor.getName()).isEqualTo("Test Company");
                assertThat(contractor.getInn()).isEqualTo("1234567890");
            })
            .verifyComplete();
    }
}
```

## Мониторинг и отладка

### Метрики:
- Количество активных соединений
- Время выполнения запросов
- Количество ошибок
- Throughput операций

### Инструменты:
- **Micrometer** - метрики
- **Spring Boot Actuator** - мониторинг
- **R2DBC Pool** - пул соединений

## Альтернативы на будущее

При необходимости:
1. **JPA** - для сложных запросов
2. **Spring Data JDBC** - для простых операций
3. **MyBatis** - для максимального контроля

## Связанные решения

- [005-postgresql-database-choice.md](./005-postgresql-database-choice.md) - PostgreSQL
- [006-spring-boot-framework-choice.md](./006-spring-boot-framework-choice.md) - Spring Boot
- [007-modular-monolith-pattern.md](./007-modular-monolith-pattern.md) - Modular Monolith
- [database-architecture.md](../architecture/database-architecture.md) - Архитектура БД