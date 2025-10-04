# FEPRO - Federation Professionals

Система управления контрагентами с современной архитектурой и полным стеком технологий.

## 🚀 Быстрый старт

### Развертывание в Docker

```bash
# Клонирование репозитория
git clone https://github.com/bondalen/fepro.git
cd fepro

# Развертывание
./scripts/deploy.sh

# Проверка статуса
docker-compose ps
```

### Доступ к приложению

- **Frontend**: http://localhost:8082
- **API**: http://localhost:8082/api
- **GraphQL**: http://localhost:8082/api/graphql
- **Health Check**: http://localhost:8082/api/actuator/health

## 📋 Скрипты управления

### Основные команды

```bash
# Полное развертывание
./scripts/deploy.sh

# Обновление приложения
./scripts/update.sh

# Создание резервной копии
./scripts/backup.sh

# Blue-Green развертывание
./scripts/blue-green-deploy.sh
```

### Детальное описание скриптов

| Скрипт | Назначение | Расположение | Применение |
|--------|------------|--------------|------------|
| `deploy.sh` | Полное развертывание приложения с проверками | `scripts/` | Production развертывание |
| `update.sh` | Обновление приложения с сохранением данных | `scripts/` | Обновление production версии |
| `backup.sh` | Создание резервной копии базы данных | `scripts/` | Резервное копирование данных |
| `blue-green-deploy.sh` | Blue-Green развертывание без простоя | `scripts/` | Безопасное обновление production |

## 🏗️ Архитектура

### Технологический стек

**Backend:**
- Spring Boot 3.4.5 + Java 21 LTS
- PostgreSQL 16 + PostGIS
- GraphQL API
- Hazelcast (кэширование)
- Liquibase (миграции)

**Frontend:**
- Vue.js 3.4.21 + TypeScript 5.4.0
- Quasar Framework 2.16.1
- Apollo Client (GraphQL)
- Vite (сборка)

**Инфраструктура:**
- Docker + Docker Compose
- Multi-stage build
- Non-root пользователь
- Health checks

### Структура проекта

```
fepro/
├── backend/          # Spring Boot приложение
├── frontend/         # Vue.js приложение
├── scripts/          # Скрипты развертывания
├── logs/             # Логи приложения
├── backups/          # Резервные копии
├── data/             # Данные PostgreSQL
├── migrations/       # Liquibase миграции
├── docker-compose.yml
├── Dockerfile
└── README.md
```

## 🔧 Конфигурация

### Окружения

- **Development** (`dev`) - локальная разработка
- **Staging** (`staging`) - тестовое окружение
- **Production** (`prod`) - продакшн окружение

### Переменные окружения

```bash
# Основные настройки
SPRING_PROFILES_ACTIVE=prod
SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/fepro_prod
SPRING_DATASOURCE_USERNAME=fepro_user
SPRING_DATASOURCE_PASSWORD=fepro_pass

# Hazelcast
HAZELCAST_ENABLED=true
HAZELCAST_CLUSTER_NAME=fepro-cluster

# Сервер
SERVER_PORT=8082
SERVER_SERVLET_CONTEXT_PATH=/api
```

## 📊 Мониторинг

### Health Checks

```bash
# Проверка здоровья приложения
curl http://localhost:8082/api/actuator/health

# Проверка базы данных
docker-compose exec postgres pg_isready -U fepro_user -d fepro_prod
```

### Логи

```bash
# Просмотр логов приложения
docker-compose logs -f fepro-app

# Просмотр логов базы данных
docker-compose logs -f postgres
```

### Метрики

- **Prometheus**: http://localhost:8082/api/actuator/prometheus
- **Metrics**: http://localhost:8082/api/actuator/metrics

## 🔄 Обновление

### Обычное обновление

```bash
# Создание резервной копии
./scripts/backup.sh

# Обновление приложения
./scripts/update.sh

# Проверка работоспособности
curl http://localhost:8082/api/actuator/health
```

### Blue-Green развертывание

```bash
# Blue-Green развертывание
./scripts/blue-green-deploy.sh

# Откат при необходимости
./scripts/blue-green-deploy.sh rollback
```

## 🗄️ База данных

### Подключение

```bash
# Подключение к базе данных
docker-compose exec postgres psql -U fepro_user -d fepro_prod
```

### Миграции

```bash
# Выполнение миграций
docker-compose exec fepro-app java -jar app.jar --spring.liquibase.contexts=prod
```

### Резервное копирование

```bash
# Создание резервной копии
./scripts/backup.sh

# Восстановление из резервной копии
./scripts/restore.sh database 20250102_120000
```

## 🚨 Устранение неполадок

### Проблемы с запуском

```bash
# Проверка статуса сервисов
docker-compose ps

# Просмотр логов
docker-compose logs -f

# Перезапуск сервисов
docker-compose restart
```

### Проблемы с базой данных

```bash
# Проверка подключения к БД
docker-compose exec postgres pg_isready -U fepro_user -d fepro_prod

# Просмотр логов БД
docker-compose logs postgres
```

### Проблемы с приложением

```bash
# Проверка здоровья приложения
curl http://localhost:8082/api/actuator/health

# Просмотр логов приложения
docker-compose logs fepro-app
```

## 📚 Документация

- **API Documentation**: http://localhost:8082/api/graphql
- **Project Documentation**: `docs/project-docs.json`
- **Architecture**: `docs/architecture.md`

## 🤝 Разработка

### Локальная разработка

```bash
# Запуск backend
cd backend
mvn spring-boot:run

# Запуск frontend
cd frontend
npm run dev
```

### Тестирование

```bash
# Запуск тестов
mvn test

# Запуск тестов с покрытием
mvn test jacoco:report
```

## 📄 Лицензия

MIT License - см. файл [LICENSE](LICENSE)

## 👥 Авторы

- **Александр** - Full-stack Developer

## 🔗 Ссылки

- **Repository**: https://github.com/bondalen/fepro
- **Issues**: https://github.com/bondalen/fepro/issues
- **Documentation**: https://github.com/bondalen/fepro/wiki