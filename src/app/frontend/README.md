# FEPRO Frontend

**Vue.js 3 + Quasar Framework + TypeScript**

## 🚀 Быстрый старт

### Предварительные требования
- Node.js 20+
- npm 9+

### Установка и запуск

1. **Установка зависимостей**
```bash
cd src/app/frontend
npm install
```

2. **Запуск в режиме разработки**
```bash
npm run dev
```

3. **Сборка для продакшена**
```bash
npm run build
```

## 🏗️ Архитектура

### Технологический стек
- **Vue.js 3.4.21** - прогрессивный JavaScript фреймворк
- **Quasar Framework 2.16.1** - Material Design компоненты
- **TypeScript 5.4.0** - типизированный JavaScript
- **Apollo Client** - GraphQL клиент
- **Pinia** - управление состоянием
- **Vue Router** - маршрутизация
- **Vite** - быстрая сборка

### Структура проекта
```
src/
├── components/          # Переиспользуемые компоненты
├── pages/              # Страницы приложения
├── stores/             # Pinia stores
├── router/             # Конфигурация маршрутов
├── types/              # TypeScript типы
├── utils/              # Утилиты
├── App.vue             # Главный компонент
└── main.ts             # Точка входа
```

## 📱 Страницы

### Основные страницы
- **HomePage** - главная страница с навигацией
- **LoginPage** - страница входа в систему
- **ContractorsPage** - управление контрагентами
- **ContractorDetailPage** - детали контрагента
- **DocumentsPage** - управление документами
- **AnalyticsPage** - аналитика и отчеты
- **SettingsPage** - настройки системы

### Навигация
- **Защищенные маршруты** - требуют аутентификации
- **Роли пользователей** - Admin, Manager, User
- **Автоматическое перенаправление** - на основе статуса авторизации

## 🔐 Аутентификация

### Pinia Store (auth.ts)
- **Состояние**: user, token, isLoading, error
- **Геттеры**: isAuthenticated, userRole, isAdmin
- **Действия**: login, logout, updateUser, clearError

### Демо доступ
- **Логин**: admin
- **Пароль**: admin

## 🎨 UI/UX

### Quasar Framework
- **Material Design** компоненты
- **Адаптивная верстка** для всех устройств
- **Темная/светлая тема** (готовность)
- **Иконки** Material Design Icons

### Стили
- **Sass** для стилизации
- **Переменные Quasar** для кастомизации
- **Глобальные стили** для FEPRO
- **Адаптивность** для мобильных устройств

## 🔗 API Integration

### GraphQL
- **Apollo Client** для запросов
- **Автоматическая авторизация** через JWT токены
- **Обработка ошибок** и состояния загрузки
- **Кэширование** запросов

### Конфигурация
```typescript
const httpLink = createHttpLink({
  uri: 'http://localhost:8082/graphql'
})

const authLink = setContext((_, { headers }) => {
  const token = localStorage.getItem('auth-token')
  return {
    headers: {
      ...headers,
      authorization: token ? `Bearer ${token}` : ''
    }
  }
})
```

## 📊 Управление состоянием

### Pinia Stores
- **auth** - аутентификация и пользователь
- **contractors** - контрагенты (планируется)
- **documents** - документы (планируется)
- **analytics** - аналитика (планируется)

### Типизация
- **TypeScript интерфейсы** для всех моделей
- **Строгая типизация** параметров и возвращаемых значений
- **Автодополнение** в IDE

## 🛠️ Разработка

### Команды
```bash
# Разработка
npm run dev

# Сборка
npm run build

# Линтинг
npm run lint

# Форматирование
npm run format

# Проверка типов
npm run type-check

# Предварительный просмотр
npm run preview
```

### Линтинг и форматирование
- **ESLint** - проверка кода
- **Prettier** - форматирование
- **Vue ESLint** - правила для Vue компонентов
- **TypeScript ESLint** - правила для TypeScript

### Тестирование (планируется)
- **Vitest** - тестирование
- **Vue Test Utils** - тестирование компонентов
- **Jest** - unit тесты

## 🚀 Развертывание

### Сборка для продакшена
```bash
npm run build
```

### Оптимизация
- **Code splitting** - разделение кода на чанки
- **Tree shaking** - удаление неиспользуемого кода
- **Minification** - сжатие JavaScript и CSS
- **Source maps** - для отладки

### Docker
```dockerfile
FROM node:20-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
```

## 📝 TODO

### Ближайшие задачи
- [ ] Интеграция с GraphQL API
- [ ] Создание компонентов для контрагентов
- [ ] Реализация CRUD операций
- [ ] Добавление валидации форм
- [ ] Создание уведомлений
- [ ] Добавление тестов

### Долгосрочные задачи
- [ ] PWA функциональность
- [ ] Оффлайн режим
- [ ] Push уведомления
- [ ] Мобильное приложение (Capacitor)
- [ ] Интернационализация (i18n)

---

**FEPRO Frontend** - современный, быстрый и удобный интерфейс для системы управления контрагентами 🚀