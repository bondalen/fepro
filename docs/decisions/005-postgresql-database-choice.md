# Решение 005: Выбор PostgreSQL базы данных

**Дата:** 2025-01-02  
**Статус:** ✅ Принято  
**Участники:** Александр  

## Проблема

Необходимо выбрать базу данных для системы управления отношениями с контрагентами FEPRO с учетом:
- Требования к ГИС-функциональности
- Производительность и масштабируемость
- Надежность и ACID-транзакции
- Стоимость и лицензирование

## Рассмотренные варианты

### 1. PostgreSQL
- **Описание:** Объектно-реляционная СУБД с расширенными возможностями
- **Плюсы:** PostGIS, JSON поддержка, ACID, открытый исходный код
- **Минусы:** Сложность настройки, больше потребление памяти

### 2. MySQL
- **Описание:** Популярная реляционная СУБД
- **Плюсы:** Простота, высокая производительность, широкое распространение
- **Минусы:** Ограниченная ГИС поддержка, проблемы с ACID

### 3. MongoDB
- **Описание:** Документо-ориентированная NoSQL СУБД
- **Плюсы:** Гибкость схемы, горизонтальное масштабирование
- **Минусы:** Нет ACID транзакций, сложность с реляционными данными

## Решение

Выбран **PostgreSQL 16** по следующим причинам:

### Основные преимущества:
1. **PostGIS расширение** - мощная ГИС-функциональность
2. **ACID транзакции** - надежность данных
3. **JSON поддержка** - гибкость для метаданных
4. **Открытый исходный код** - бесплатное использование
5. **Мощные возможности** - расширяемость и производительность

### Архитектурные решения:

#### PostGIS для ГИС-функциональности
```sql
-- Создание таблицы с пространственными данными
CREATE TABLE contractors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    coordinates GEOMETRY(POINT, 4326),
    address TEXT
);

-- Создание пространственного индекса
CREATE INDEX idx_contractors_coordinates 
ON contractors USING GIST (coordinates);

-- Запрос контрагентов в радиусе
SELECT name, ST_Distance(coordinates, ST_Point(37.6173, 55.7558)) as distance
FROM contractors 
WHERE ST_DWithin(coordinates, ST_Point(37.6173, 55.7558), 1000);
```

#### JSON поля для метаданных
```sql
-- Таблица с JSON метаданными
CREATE TABLE contractor_metadata (
    contractor_id UUID REFERENCES contractors(id),
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Индексы для JSON полей
CREATE INDEX idx_contractor_metadata_gin 
ON contractor_metadata USING GIN (metadata);

-- Запросы по JSON полям
SELECT * FROM contractor_metadata 
WHERE metadata->>'industry' = 'construction';
```

## Реализация

### Spring Boot Configuration
```yaml
# application.yml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/fepro_dev
    username: fepro_user
    password: fepro_pass
    driver-class-name: org.postgresql.Driver
  jpa:
    database-platform: org.hibernate.dialect.PostgreSQLDialect
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        format_sql: true
        use_sql_comments: true
```

### Entity с пространственными данными
```java
@Entity
@Table(name = "contractors")
@TypeDef(name = "geometry", typeClass = GeometryType.class)
public class Contractor {
    
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;
    
    @Column(nullable = false)
    private String name;
    
    @Column(columnDefinition = "geometry(Point,4326)")
    @Type(type = "geometry")
    private Point coordinates;
    
    @Column(columnDefinition = "jsonb")
    private String metadata;
    
    // getters and setters
}
```

### Spatial Queries
```java
@Repository
public interface ContractorRepository extends JpaRepository<Contractor, UUID> {
    
    @Query(value = """
        SELECT * FROM contractors 
        WHERE ST_DWithin(coordinates, ST_Point(:lng, :lat), :radius)
        """, nativeQuery = true)
    List<Contractor> findNearbyContractors(
        @Param("lat") double latitude,
        @Param("lng") double longitude,
        @Param("radius") double radiusMeters
    );
    
    @Query(value = """
        SELECT c.*, ST_Distance(c.coordinates, ST_Point(:lng, :lat)) as distance
        FROM contractors c
        ORDER BY distance
        LIMIT :limit
        """, nativeQuery = true)
    List<Contractor> findNearestContractors(
        @Param("lat") double latitude,
        @Param("lng") double longitude,
        @Param("limit") int limit
    );
}
```

## Последствия

### Положительные:
- ✅ Мощная ГИС-функциональность
- ✅ ACID транзакции
- ✅ JSON поддержка
- ✅ Открытый исходный код
- ✅ Высокая производительность

### Отрицательные:
- ⚠️ Сложность настройки
- ⚠️ Больше потребление памяти
- ⚠️ Learning curve для PostGIS
- ⚠️ Потенциальные проблемы с производительностью

## Стратегия оптимизации

### 1. Индексы
- **B-tree** - для обычных полей
- **GIST** - для пространственных данных
- **GIN** - для JSON полей
- **Partial** - для условных индексов

### 2. Настройка производительности
```sql
-- Настройки PostgreSQL
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB
maintenance_work_mem = 64MB
```

### 3. Мониторинг
- **pg_stat_statements** - статистика запросов
- **pg_stat_activity** - активные соединения
- **pg_stat_user_tables** - статистика таблиц

## Backup и восстановление

### Стратегия бэкапов
```bash
# Полный бэкап
pg_dump -h localhost -U fepro_user -d fepro_prod > backup.sql

# Инкрементальный бэкап
pg_basebackup -h localhost -U fepro_user -D /backup/base

# Восстановление
psql -h localhost -U fepro_user -d fepro_prod < backup.sql
```

### Автоматизация
```bash
#!/bin/bash
# backup.sh
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump -h localhost -U fepro_user -d fepro_prod > "backups/backup_$DATE.sql"
echo "Backup created: backup_$DATE.sql"
```

## Альтернативы на будущее

При росте нагрузки:
1. **PostgreSQL кластер** - репликация и шардирование
2. **TimescaleDB** - для временных рядов
3. **Citus** - для горизонтального масштабирования

## Связанные решения

- [010-liquibase-migrations-strategy.md](./010-liquibase-migrations-strategy.md) - Liquibase миграции
- [006-spring-boot-framework-choice.md](./006-spring-boot-framework-choice.md) - Spring Boot
- [database-design.md](../architecture/database-design.md) - Дизайн базы данных