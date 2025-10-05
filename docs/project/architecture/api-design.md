# API Design - GraphQL Schema

## Обзор

FEPRO использует GraphQL как основной API для взаимодействия между фронтендом и бэкендом. GraphQL обеспечивает гибкость запросов, типобезопасность и единую точку входа.

## Основные принципы

### 1. Schema-First Design
- Сначала определяем схему, затем реализуем
- Используем SDL (Schema Definition Language)
- Валидация на уровне схемы

### 2. Типобезопасность
- Строгая типизация всех полей
- Валидация входных данных
- Автоматическая генерация типов

### 3. Гибкость запросов
- Клиент запрашивает только нужные данные
- Избегаем over-fetching и under-fetching
- Поддержка сложных запросов

## Схема данных

### Основные типы

```graphql
type Contractor {
  id: ID!
  name: String!
  inn: String
  email: String
  status: ContractorStatus!
  type: ContractorType!
  coordinates: Point
  address: String
  createdAt: DateTime!
  updatedAt: DateTime!
}

type Point {
  lat: Float!
  lng: Float!
}

enum ContractorStatus {
  ACTIVE
  INACTIVE
  SUSPENDED
  PENDING
}

enum ContractorType {
  INDIVIDUAL
  LLC
  CORPORATION
  PARTNERSHIP
}
```

### Входные типы

```graphql
input ContractorInput {
  name: String!
  inn: String
  email: String
  type: ContractorType!
  address: String
  coordinates: PointInput
}

input PointInput {
  lat: Float!
  lng: Float!
}

input ContractorFilter {
  status: ContractorStatus
  type: ContractorType
  search: String
  location: LocationFilter
}

input LocationFilter {
  center: PointInput!
  radius: Float! # в метрах
}
```

## Queries

### Основные запросы

```graphql
type Query {
  # Получить всех контрагентов
  contractors(filter: ContractorFilter): [Contractor!]!
  
  # Получить контрагента по ID
  contractor(id: ID!): Contractor
  
  # Поиск контрагентов
  searchContractors(query: String!): [Contractor!]!
  
  # Контрагенты в радиусе
  contractorsNearby(location: PointInput!, radius: Float!): [Contractor!]!
  
  # Статистика
  contractorStats: ContractorStats!
}
```

### Примеры запросов

```graphql
# Получить активных контрагентов
query GetActiveContractors {
  contractors(filter: { status: ACTIVE }) {
    id
    name
    inn
    status
  }
}

# Поиск контрагентов
query SearchContractors($query: String!) {
  searchContractors(query: $query) {
    id
    name
    inn
    type
    coordinates {
      lat
      lng
    }
  }
}

# Контрагенты рядом с точкой
query GetNearbyContractors($lat: Float!, $lng: Float!, $radius: Float!) {
  contractorsNearby(
    location: { lat: $lat, lng: $lng }
    radius: $radius
  ) {
    id
    name
    address
    coordinates {
      lat
      lng
    }
  }
}
```

## Mutations

### Основные мутации

```graphql
type Mutation {
  # Создать контрагента
  createContractor(input: ContractorInput!): Contractor!
  
  # Обновить контрагента
  updateContractor(id: ID!, input: ContractorInput!): Contractor!
  
  # Удалить контрагента
  deleteContractor(id: ID!): Boolean!
  
  # Изменить статус
  updateContractorStatus(id: ID!, status: ContractorStatus!): Contractor!
}
```

### Примеры мутаций

```graphql
# Создать нового контрагента
mutation CreateContractor($input: ContractorInput!) {
  createContractor(input: $input) {
    id
    name
    inn
    status
    createdAt
  }
}

# Обновить контрагента
mutation UpdateContractor($id: ID!, $input: ContractorInput!) {
  updateContractor(id: $id, input: $input) {
    id
    name
    inn
    status
    updatedAt
  }
}
```

## Подписки (Subscriptions)

### Real-time обновления

```graphql
type Subscription {
  # Подписка на изменения контрагентов
  contractorUpdated: Contractor!
  
  # Подписка на новые контрагенты
  contractorCreated: Contractor!
  
  # Подписка на удаление контрагентов
  contractorDeleted: ID!
}
```

### Пример подписки

```graphql
subscription OnContractorUpdated {
  contractorUpdated {
    id
    name
    status
    updatedAt
  }
}
```

## Обработка ошибок

### Типы ошибок

```graphql
type Error {
  code: String!
  message: String!
  field: String
}

union ContractorResult = Contractor | Error
```

### Валидация

```graphql
# Валидация ИНН
input ContractorInput {
  name: String! @constraint(minLength: 1, maxLength: 255)
  inn: String @constraint(pattern: "^\\d{10}$|^\\d{12}$")
  email: String @constraint(format: "email")
}
```

## Оптимизация производительности

### 1. DataLoader
- Решение N+1 проблем
- Батчинг запросов
- Кэширование результатов

### 2. Кэширование
- Кэширование запросов
- Инвалидация кэша
- Стратегии кэширования

### 3. Пагинация
```graphql
type ContractorConnection {
  edges: [ContractorEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type ContractorEdge {
  node: Contractor!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}
```

## Безопасность

### 1. Аутентификация
- JWT токены
- Проверка токенов
- Авторизация запросов

### 2. Авторизация
- Роли пользователей
- Права доступа
- Фильтрация данных

### 3. Валидация
- Входные данные
- SQL инъекции
- XSS защита

## Мониторинг

### 1. Метрики
- Время выполнения запросов
- Сложность запросов
- Частота использования

### 2. Логирование
- Все запросы
- Ошибки
- Производительность

### 3. Алерты
- Медленные запросы
- Ошибки
- Превышение лимитов

## Инструменты разработки

### 1. GraphQL Playground
- Тестирование запросов
- Интроспекция схемы
- Отладка

### 2. Apollo Studio
- Мониторинг
- Аналитика
- Управление схемой

### 3. Code Generation
- Автоматическая генерация типов
- Валидация схемы
- Документация

## Связанные документы

- [003-graphql-api-choice.md](../decisions/003-graphql-api-choice.md) - Выбор GraphQL
- [009-jwt-security-approach.md](../decisions/009-jwt-security-approach.md) - Безопасность
- [backend-architecture.md](./backend-architecture.md) - Архитектура бэкенда