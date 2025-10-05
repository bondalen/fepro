# Архитектура Backend

## Обзор архитектуры

Backend приложения FEPRO построен на принципах модульного монолита с использованием Spring Boot.

## Основные компоненты

### 1. Framework Layer
- **Spring Boot 3.4.5** - основной фреймворк
- **Java 21 LTS** - язык программирования
- **Maven** - система сборки

### 2. Data Layer
- **PostgreSQL 16** - основная база данных
- **R2DBC** - реактивный доступ к данным
- **Liquibase** - управление миграциями

### 3. API Layer
- **GraphQL** - API интерфейс
- **Spring WebFlux** - реактивный веб-слой

### 4. Security Layer
- **JWT** - токены аутентификации
- **Spring Security** - безопасность

### 5. Cache Layer
- **Hazelcast** - распределенное кэширование
- **Caffeine** - локальное кэширование

## Модульная структура

```
src/main/java/io/github/bondalen/fepro/
├── config/          # Конфигурация
├── controller/      # GraphQL контроллеры
├── service/         # Бизнес-логика
├── repository/      # Доступ к данным
├── model/           # Доменные модели
├── security/        # Безопасность
└── cache/           # Кэширование
```

## Принципы проектирования

- **Reactive Programming** - неблокирующие операции
- **Domain-Driven Design** - доменно-ориентированное проектирование
- **Clean Architecture** - чистая архитектура
- **SOLID Principles** - принципы SOLID

## Конфигурация

### application.yml
```yaml
spring:
  application:
    name: fepro-backend
  profiles:
    active: dev
  r2dbc:
    url: r2dbc:postgresql://localhost:5432/fepro_db
    username: fepro_user
    password: fepro_pass
```

## Мониторинг

- **Spring Boot Actuator** - метрики и health checks
- **Micrometer** - сбор метрик
- **Logback** - логирование

## Развертывание

- **Docker** - контейнеризация
- **Docker Compose** - оркестрация
- **GitHub Actions** - CI/CD