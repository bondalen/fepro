# Решение 004: Выбор Vue.js фреймворка

**Дата:** 2025-01-02  
**Статус:** ✅ Принято  
**Участники:** Александр  

## Проблема

Необходимо выбрать фронтенд фреймворк для системы управления отношениями с контрагентами FEPRO с учетом:
- Простота разработки для одного разработчика
- Производительность и размер бандла
- Экосистема и инструменты
- Интеграция с GraphQL

## Рассмотренные варианты

### 1. React
- **Описание:** Популярный фреймворк от Facebook
- **Плюсы:** Большая экосистема, много библиотек, хорошая производительность
- **Минусы:** Сложность для новичков, JSX, много boilerplate кода

### 2. Vue.js
- **Описание:** Прогрессивный фреймворк с простым API
- **Плюсы:** Простота изучения, отличная документация, гибкость
- **Минусы:** Меньшая экосистема, меньшая популярность

### 3. Angular
- **Описание:** Полнофункциональный фреймворк от Google
- **Плюсы:** Мощные возможности, TypeScript из коробки, enterprise-ready
- **Минусы:** Сложность, большой размер, steep learning curve

## Решение

Выбран **Vue.js 3.4.21** по следующим причинам:

### Основные преимущества:
1. **Простота изучения** - отлично подходит для одного разработчика
2. **Отличная документация** - подробные руководства и примеры
3. **Гибкость** - можно использовать постепенно
4. **Производительность** - быстрый рендеринг и маленький размер
5. **Composition API** - современный подход к разработке

### Архитектурные решения:

#### Vue.js 3 + Composition API
```typescript
// ContractorList.vue
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useContractorStore } from '@/stores/contractor'

const contractorStore = useContractorStore()
const contractors = ref([])
const loading = ref(false)

onMounted(async () => {
  loading.value = true
  await contractorStore.fetchContractors()
  contractors.value = contractorStore.contractors
  loading.value = false
})
</script>

<template>
  <div class="contractor-list">
    <div v-if="loading">Загрузка...</div>
    <div v-else>
      <ContractorCard 
        v-for="contractor in contractors" 
        :key="contractor.id"
        :contractor="contractor"
      />
    </div>
  </div>
</template>
```

#### Quasar Framework Integration
```typescript
// main.ts
import { createApp } from 'vue'
import { Quasar } from 'quasar'
import App from './App.vue'

import '@quasar/extras/material-icons/material-icons.css'
import 'quasar/src/css/index.sass'

const app = createApp(App)

app.use(Quasar, {
  plugins: {}, // import Quasar plugins and add here
})

app.mount('#app')
```

## Реализация

### Структура проекта
```
frontend/
├── src/
│   ├── components/           # Переиспользуемые компоненты
│   │   ├── ContractorCard.vue
│   │   ├── ContractorForm.vue
│   │   └── MapView.vue
│   ├── views/               # Страницы приложения
│   │   ├── ContractorList.vue
│   │   ├── ContractorDetail.vue
│   │   └── Dashboard.vue
│   ├── stores/              # Pinia stores
│   │   ├── contractor.ts
│   │   └── auth.ts
│   ├── composables/         # Composition API функции
│   │   ├── useContractors.ts
│   │   └── useAuth.ts
│   ├── router/              # Vue Router
│   │   └── index.ts
│   └── apollo/              # Apollo Client
│       └── client.ts
```

### Apollo Client Integration
```typescript
// apollo/client.ts
import { ApolloClient, InMemoryCache, createHttpLink } from '@apollo/client/core'
import { setContext } from '@apollo/client/link/context'

const httpLink = createHttpLink({
  uri: 'http://localhost:8082/api/graphql'
})

const authLink = setContext((_, { headers }) => {
  const token = localStorage.getItem('jwt_token')
  return {
    headers: {
      ...headers,
      authorization: token ? `Bearer ${token}` : ''
    }
  }
})

export const apolloClient = new ApolloClient({
  link: authLink.concat(httpLink),
  cache: new InMemoryCache()
})
```

### Pinia Store
```typescript
// stores/contractor.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { useQuery } from '@vue/apollo-composable'
import { GET_CONTRACTORS } from '@/graphql/queries'

export const useContractorStore = defineStore('contractor', () => {
  const contractors = ref([])
  const loading = ref(false)
  const error = ref(null)

  const contractorCount = computed(() => contractors.value.length)

  const fetchContractors = async () => {
    loading.value = true
    try {
      const { result } = useQuery(GET_CONTRACTORS)
      contractors.value = result.value?.contractors || []
    } catch (err) {
      error.value = err
    } finally {
      loading.value = false
    }
  }

  return {
    contractors,
    loading,
    error,
    contractorCount,
    fetchContractors
  }
})
```

## Последствия

### Положительные:
- ✅ Простота разработки
- ✅ Отличная документация
- ✅ Быстрая разработка
- ✅ Хорошая производительность
- ✅ Гибкость архитектуры

### Отрицательные:
- ⚠️ Меньшая экосистема по сравнению с React
- ⚠️ Меньше готовых компонентов
- ⚠️ Потенциальные проблемы с масштабированием команды

## Стратегия разработки

### 1. Компонентная архитектура
- **Атомарные компоненты** - базовые UI элементы
- **Молекулярные компоненты** - комбинации атомов
- **Организменные компоненты** - сложные блоки

### 2. State Management
- **Pinia** - для глобального состояния
- **Composables** - для переиспользуемой логики
- **Local state** - для компонентного состояния

### 3. Тестирование
- **Unit тесты** - для компонентов и stores
- **Integration тесты** - для взаимодействия
- **E2E тесты** - для пользовательских сценариев

## Инструменты разработки

### Основные инструменты:
- **Vue CLI / Vite** - сборка проекта
- **Vue DevTools** - отладка
- **ESLint + Prettier** - качество кода
- **TypeScript** - типизация

### UI Framework:
- **Quasar Framework** - Material Design компоненты
- **Vuetify** - альтернативный UI фреймворк
- **Tailwind CSS** - utility-first CSS

## Производительность

### Оптимизации:
- **Lazy loading** - загрузка компонентов по требованию
- **Code splitting** - разделение кода на чанки
- **Tree shaking** - удаление неиспользуемого кода
- **Caching** - кэширование GraphQL запросов

### Метрики:
- **First Contentful Paint** - < 1.5s
- **Largest Contentful Paint** - < 2.5s
- **Cumulative Layout Shift** - < 0.1
- **Bundle size** - < 500KB gzipped

## Альтернативы на будущее

При росте команды и сложности:
1. **React** - для больших команд
2. **Angular** - для enterprise приложений
3. **Svelte** - для максимальной производительности

## Связанные решения

- [003-graphql-api-choice.md](./003-graphql-api-choice.md) - GraphQL API
- [009-jwt-security-approach.md](./009-jwt-security-approach.md) - JWT Security
- [frontend-architecture.md](../architecture/frontend-architecture.md) - Архитектура фронтенда