# Решение 010: Liquibase стратегия миграций

**Дата:** 2025-01-02  
**Статус:** ✅ Принято  
**Участники:** Александр  

## Проблема

Необходимо выбрать инструмент и стратегию для управления миграциями базы данных в системе FEPRO с учетом:
- Версионирование схемы БД
- Автоматизация развертывания
- Откат изменений
- Совместимость с Spring Boot

## Рассмотренные варианты

### 1. Flyway
- **Описание:** Простой инструмент миграций на основе SQL
- **Плюсы:** Простота, быстрый старт, хорошая интеграция с Spring Boot
- **Минусы:** Только SQL, ограниченные возможности отката

### 2. Liquibase
- **Описание:** Мощный инструмент миграций с XML/YAML/JSON
- **Плюсы:** Кроссплатформенность, мощные возможности, хороший откат
- **Минусы:** Сложность, learning curve

### 3. JPA/Hibernate DDL
- **Описание:** Автоматическая генерация схемы из entities
- **Плюсы:** Простота, автоматизация
- **Минусы:** Потеря контроля, проблемы с production

## Решение

Выбран **Liquibase** по следующим причинам:

### Основные преимущества:
1. **Кроссплатформенность** - работает с любой БД
2. **Мощные возможности** - сложные миграции, откаты
3. **Интеграция с Spring Boot** - встроенная поддержка
4. **Версионирование** - четкое управление версиями
5. **Откат изменений** - возможность rollback

### Архитектурные решения:

#### Структура миграций
```
src/main/resources/db/changelog/
├── db.changelog-master.xml
├── changes/
│   ├── 001-initial-schema.xml
│   ├── 002-add-postgis.xml
│   ├── 003-add-indexes.xml
│   └── 004-add-constraints.xml
└── contexts/
    ├── dev-context.xml
    ├── staging-context.xml
    └── prod-context.xml
```

#### Master changelog
```xml
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
                        http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-4.20.xsd">

    <include file="changes/001-initial-schema.xml" context="dev,staging,prod"/>
    <include file="changes/002-add-postgis.xml" context="dev,staging,prod"/>
    <include file="changes/003-add-indexes.xml" context="dev,staging,prod"/>
    <include file="changes/004-add-constraints.xml" context="dev,staging,prod"/>

</databaseChangeLog>
```

## Реализация

### Spring Boot Configuration
```yaml
# application.yml
spring:
  liquibase:
    change-log: classpath:db/changelog/db.changelog-master.xml
    enabled: true
    contexts: dev
    drop-first: false
    rollback-file: rollback.sql
```

### Пример миграции
```xml
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
                        http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-4.20.xsd">

    <changeSet id="001" author="alex">
        <createTable tableName="contractors">
            <column name="id" type="UUID" defaultValueComputed="gen_random_uuid()">
                <constraints primaryKey="true" nullable="false"/>
            </column>
            <column name="name" type="VARCHAR(255)">
                <constraints nullable="false"/>
            </column>
            <column name="inn" type="VARCHAR(12)">
                <constraints unique="true"/>
            </column>
            <column name="email" type="VARCHAR(255)"/>
            <column name="status" type="VARCHAR(50)" defaultValue="active">
                <constraints nullable="false"/>
            </column>
            <column name="created_at" type="TIMESTAMP" defaultValueComputed="NOW()">
                <constraints nullable="false"/>
            </column>
            <column name="updated_at" type="TIMESTAMP" defaultValueComputed="NOW()">
                <constraints nullable="false"/>
            </column>
        </createTable>
        
        <rollback>
            <dropTable tableName="contractors"/>
        </rollback>
    </changeSet>

</databaseChangeLog>
```

### Maven Integration
```xml
<plugin>
    <groupId>org.liquibase</groupId>
    <artifactId>liquibase-maven-plugin</artifactId>
    <version>4.20.0</version>
    <configuration>
        <changeLogFile>src/main/resources/db/changelog/db.changelog-master.xml</changeLogFile>
        <url>jdbc:postgresql://localhost:5432/fepro_dev</url>
        <username>fepro_user</username>
        <password>fepro_pass</password>
    </configuration>
</plugin>
```

## Стратегия миграций

### 1. Версионирование
- **Семантическое версионирование** - MAJOR.MINOR.PATCH
- **Последовательные номера** - 001, 002, 003
- **Описательные имена** - 001-initial-schema.xml

### 2. Контексты
- **dev** - для разработки
- **staging** - для тестирования
- **prod** - для production

### 3. Откат
- **Автоматический rollback** - для каждого changeset
- **Ручной откат** - через Maven/Gradle
- **Резервные копии** - перед критическими изменениями

## Последствия

### Положительные:
- ✅ Кроссплатформенность
- ✅ Мощные возможности миграций
- ✅ Автоматический откат
- ✅ Интеграция с Spring Boot
- ✅ Версионирование изменений

### Отрицательные:
- ⚠️ Сложность изучения
- ⚠️ XML/YAML конфигурация
- ⚠️ Потенциальные проблемы с производительностью
- ⚠️ Сложность отладки

## Best Practices

### 1. Структура changeset
- **Один changeset = одна логическая операция**
- **Идемпотентность** - можно выполнять многократно
- **Описательные комментарии**

### 2. Безопасность
- **Резервные копии** перед критическими изменениями
- **Тестирование** на staging окружении
- **Постепенный rollout** в production

### 3. Мониторинг
- **Логирование** всех операций
- **Метрики** времени выполнения
- **Алерты** при ошибках

## Инструменты и команды

### Maven команды
```bash
# Применить миграции
mvn liquibase:update

# Откатить последний changeset
mvn liquibase:rollback

# Показать статус
mvn liquibase:status

# Сгенерировать rollback скрипт
mvn liquibase:rollbackSQL
```

### Spring Boot команды
```bash
# Применить миграции
java -jar app.jar --spring.liquibase.enabled=true

# Откатить миграции
java -jar app.jar --spring.liquibase.enabled=false
```

## Альтернативы на будущее

При росте сложности:
1. **Flyway** - для простых SQL миграций
2. **Custom migration tool** - для специфических требований
3. **Database versioning** - встроенные возможности БД

## Связанные решения

- [005-postgresql-database-choice.md](./005-postgresql-database-choice.md) - Выбор PostgreSQL
- [006-spring-boot-framework-choice.md](./006-spring-boot-framework-choice.md) - Spring Boot
- [database-design.md](../architecture/database-design.md) - Дизайн базы данных