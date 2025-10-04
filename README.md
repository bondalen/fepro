# FEPRO - Federation Professionals

**Система управления контрагентами**

[![Java](https://img.shields.io/badge/Java-21-orange.svg)](https://openjdk.java.net/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.4.5-green.svg)](https://spring.io/projects/spring-boot)
[![Vue.js](https://img.shields.io/badge/Vue.js-3.4.21-4FC08D.svg)](https://vuejs.org/)
[![Quasar](https://img.shields.io/badge/Quasar-2.16.1-1976D2.svg)](https://quasar.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791.svg)](https://www.postgresql.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## 🎯 Описание проекта

**FEPRO** (Federation Professionals) - это современная система управления контрагентами, построенная на основе проверенного стека технологий. Система предназначена для эффективного управления бизнес-процессами, связанными с контрагентами, включая CRM функциональность, документооборот и ГИС-аналитику.

## 🏗️ Архитектура

### Backend
- **Java 21 LTS** + **Spring Boot 3.4.5**
- **GraphQL API** + **R2DBC** (реактивный доступ к БД)
- **PostgreSQL 16** + **PostGIS** (ГИС-функциональность)
- **JWT аутентификация** + **Spring Security**
- **Redis** для кэширования
- **Liquibase** для миграций БД

### Frontend
- **Vue.js 3.4.21** + **TypeScript 5.4.0**
- **Quasar Framework 2.16.1** (Material Design)
- **Apollo Client** (GraphQL клиент)
- **Vite** (быстрая сборка)
- **Leaflet** (карты)

### Инфраструктура
- **Docker** + **Docker Compose**
- **MCP серверы** (интеграция с AI)
- **Автоматизированное развертывание**

## ✨ Основные возможности

### 🔧 Основной функционал
- **Управление контрагентами** - полный жизненный цикл
- **CRM функциональность** - воронка продаж и клиентские отношения
- **Документооборот** - создание, управление и отслеживание документов
- **Финансовый учет** - учет финансовых операций
- **Система уведомлений** - WebSocket уведомления в реальном времени
- **Многоязычность** - поддержка i18n

### 🚀 Расширенные возможности
- **ГИС-аналитика** - пространственный анализ контрагентов на картах
- **Автоматическая генерация документов** - PDF, Excel, CSV отчеты
- **Интеграция с внешними API** - платежные системы, email/SMS сервисы
- **Система отчетности** - аналитика и дашборды
- **Кэширование и оптимизация** - высокая производительность

## 🚀 Быстрый старт

### Предварительные требования
- Java 21 LTS
- Node.js 20+
- PostgreSQL 16
- Docker & Docker Compose
- Maven 3.9+

### Установка и запуск

1. **Клонирование репозитория**
```bash
git clone https://github.com/bondalen/fepro.git
cd fepro
```

2. **Запуск инфраструктуры**
```bash
docker-compose up -d postgres redis
```

3. **Запуск Backend**
```bash
mvn spring-boot:run
```

4. **Запуск Frontend**
```bash
cd src/app/frontend
npm install
npm run dev
```

5. **Доступ к приложению**
- Frontend: http://localhost:3000
- Backend API: http://localhost:8082/graphql
- GraphQL Playground: http://localhost:8082/graphiql

## 📊 Состояние проекта

### 🎯 Общий прогресс: 15%

**✅ Завершенные компоненты:**
- Планирование и архитектура
- JSON-документация
- Базовая инфраструктура
- Правила разработки

**🔄 В разработке:**
- Backend приложение
- Frontend интерфейс
- База данных и миграции
- Интеграция компонентов

## 📁 Структура проекта

```
fepro/
├── docs/                          # Документация
│   └── project-docs.json         # Основная JSON-документация
├── src/app/                       # Исходный код
│   ├── backend/                   # Spring Boot приложение
│   └── frontend/                  # Vue.js приложение
├── infrastructure/                # Инфраструктура
│   ├── docker/                    # Docker конфигурация
│   └── scripts/                   # Скрипты автоматизации
├── .cursorrules                   # Правила разработки
├── docker-compose.yml            # Docker Compose конфигурация
├── pom.xml                       # Maven конфигурация
└── README.md                     # Этот файл
```

## 🔧 Разработка

### Стандарты кодирования
- **Backend**: Google Java Style Guide
- **Frontend**: ESLint + Prettier
- **Git**: GitHub Flow
- **Тестирование**: JUnit 5 + Vue Test Utils

### Команды разработки
```bash
# Запуск в режиме разработки
mvn spring-boot:run

# Сборка проекта
mvn clean package

# Запуск тестов
mvn test

# Обновление миграций БД
mvn liquibase:update

# Линтинг Frontend
npm run lint

# Сборка Frontend
npm run build
```

## 🗄️ База данных

### Основные таблицы
- `contractors` - контрагенты
- `users` - пользователи системы
- `documents` - документы
- `contractor_locations` - ГИС данные

### Миграции
Проект использует Liquibase для управления схемой БД:
- `001-initial-schema.xml` - базовая схема
- `002-add-postgis.xml` - ГИС поддержка

## 🔐 Безопасность

- **JWT аутентификация** - безопасная авторизация
- **RBAC** - управление ролями и правами
- **HTTPS/TLS** - шифрование трафика
- **Аудит действий** - логирование операций
- **Rate limiting** - защита от атак

## 📈 Производительность

- **Реактивное программирование** - R2DBC для БД
- **Кэширование** - Redis + Caffeine
- **Оптимизированные запросы** - индексы и оптимизация SQL
- **CDN** - для статических ресурсов
- **Горизонтальное масштабирование** - готовность к росту

## 🤝 Вклад в проект

1. Форкните репозиторий
2. Создайте ветку для новой функции (`git checkout -b feature/amazing-feature`)
3. Зафиксируйте изменения (`git commit -m 'Add amazing feature'`)
4. Отправьте в ветку (`git push origin feature/amazing-feature`)
5. Откройте Pull Request

## 📄 Лицензия

Этот проект лицензирован под MIT License - см. файл [LICENSE](LICENSE) для деталей.

## 👨‍💻 Автор

**Александр** - Full-stack разработчик
- GitHub: [@bondalen](https://github.com/bondalen)

## 🙏 Благодарности

- [Spring Boot](https://spring.io/projects/spring-boot) - за отличный фреймворк
- [Vue.js](https://vuejs.org/) - за прогрессивный JavaScript фреймворк
- [Quasar Framework](https://quasar.dev/) - за Material Design компоненты
- [PostgreSQL](https://www.postgresql.org/) - за надежную СУБД
- [Docker](https://www.docker.com/) - за контейнеризацию

---

**FEPRO** - современное решение для управления контрагентами 🚀