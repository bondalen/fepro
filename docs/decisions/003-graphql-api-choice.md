# Решение 003: Выбор GraphQL API

**Дата:** 2025-01-02  
**Статус:** ✅ Принято  
**Участники:** Александр  

## Проблема

Необходимо выбрать подход к проектированию API для системы управления отношениями с контрагентами FEPRO с учетом требований:
- Гибкость запросов данных
- Эффективность передачи данных
- Типобезопасность
- Простота интеграции с фронтендом

## Рассмотренные варианты

### 1. REST API
- **Описание:** Классический REST подход с множественными эндпоинтами
- **Плюсы:** Простота, широкое распространение, хорошая документация
- **Минусы:** Over-fetching/under-fetching, множественные запросы, слабая типизация

### 2. GraphQL
- **Описание:** Query language для API с единой точкой входа
- **Плюсы:** Гибкие запросы, типобезопасность, единый эндпоинт, интроспекция
- **Минусы:** Сложность кэширования, learning curve, потенциальные N+1 проблемы

### 3. gRPC
- **Описание:** Высокопроизводительный RPC фреймворк
- **Плюсы:** Высокая производительность, строгая типизация, потоковая передача
- **Минусы:** Сложность для веб-клиентов, ограниченная поддержка браузеров

## Решение

Выбран **GraphQL** по следующим причинам:

### Основные преимущества:
1. **Гибкость запросов** - клиент запрашивает только нужные данные
2. **Типобезопасность** - строгая схема и валидация
3. **Единая точка входа** - один эндпоинт для всех операций
4. **Интроспекция** - автоматическая документация API
5. **Эффективность** - минимизация over-fetching

### Архитектурные соображения:
- Фронтенд на Vue.js отлично интегрируется с GraphQL
- Apollo Client предоставляет мощные возможности кэширования
- GraphQL хорошо подходит для сложных запросов контрагентов
- Возможность постепенной миграции с REST при необходимости

## Реализация

### Backend (Spring Boot + GraphQL)
```java
@RestController
@RequestMapping("/graphql")
public class ContractorResolver {
    
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

### Frontend (Vue.js + Apollo Client)
```typescript
const GET_CONTRACTORS = gql`
  query GetContractors($filter: ContractorFilter) {
    contractors(filter: $filter) {
      id
      name
      inn
      status
      coordinates {
        lat
        lng
      }
    }
  }
`;
```

### GraphQL Schema
```graphql
type Contractor {
  id: ID!
  name: String!
  inn: String
  email: String
  status: ContractorStatus!
  coordinates: Point
  createdAt: DateTime!
  updatedAt: DateTime!
}

input ContractorInput {
  name: String!
  inn: String
  email: String
  address: String
}

input ContractorFilter {
  status: ContractorStatus
  type: ContractorType
  search: String
}
```

## Последствия

### Положительные:
- ✅ Гибкие запросы данных
- ✅ Типобезопасность на клиенте и сервере
- ✅ Автоматическая документация API
- ✅ Эффективная передача данных
- ✅ Мощные возможности кэширования

### Отрицательные:
- ⚠️ Сложность кэширования на уровне HTTP
- ⚠️ Потенциальные N+1 проблемы
- ⚠️ Learning curve для команды
- ⚠️ Сложность отладки сложных запросов

## Стратегия реализации

### Phase 1: Базовые операции
- CRUD операции для контрагентов
- Простые запросы и мутации
- Базовая схема

### Phase 2: Расширенная функциональность
- Фильтрация и поиск
- Пагинация
- Сложные запросы

### Phase 3: Оптимизация
- DataLoader для N+1 проблем
- Кэширование запросов
- Мониторинг производительности

## Мониторинг и отладка

### Инструменты:
- GraphQL Playground для тестирования
- Apollo Studio для мониторинга
- Custom metrics для производительности

### Метрики:
- Время выполнения запросов
- Сложность запросов
- Частота использования полей

## Альтернативы на будущее

При необходимости рассмотреть:
1. Hybrid подход (GraphQL + REST)
2. GraphQL Federation для микросервисов
3. GraphQL Subscriptions для real-time обновлений

## Связанные решения

- [004-vuejs-framework-choice.md](./004-vuejs-framework-choice.md) - Выбор фронтенд фреймворка
- [006-spring-boot-framework-choice.md](./006-spring-boot-framework-choice.md) - Выбор бэкенд фреймворка
- [api-design.md](../architecture/api-design.md) - Дизайн API