# Решение проблем Spring Boot

## Общие проблемы

### 1. Ошибки компиляции

#### Проблема: Java версия не совпадает
```
Error: java: invalid source release: 21
```

**Решение:**
```bash
# Проверить версию Java
java -version

# Установить правильную версию
sudo apt install openjdk-21-jdk

# Обновить JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
```

#### Проблема: Maven не находит зависимости
```
Could not resolve dependencies
```

**Решение:**
```bash
# Очистить кэш Maven
mvn dependency:purge-local-repository

# Пересобрать проект
mvn clean install
```

### 2. Проблемы запуска

#### Проблема: Порт уже занят
```
Port 8080 was already in use
```

**Решение:**
```bash
# Найти процесс, использующий порт
sudo lsof -i :8080

# Остановить процесс
sudo kill -9 <PID>

# Или изменить порт в application.yml
server:
  port: 8081
```

#### Проблема: Приложение не запускается
```
Application failed to start
```

**Решение:**
```bash
# Проверить логи
tail -f logs/application.log

# Запустить с отладкой
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
```

### 3. Проблемы с базой данных

#### Проблема: Не удается подключиться к БД
```
Connection refused
```

**Решение:**
```yaml
# Проверить настройки в application.yml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/fepro_db
    username: fepro_user
    password: fepro_pass
```

#### Проблема: Ошибки миграций
```
Migration failed
```

**Решение:**
```bash
# Проверить статус миграций
mvn liquibase:status

# Применить миграции
mvn liquibase:update
```

## Диагностика

### Полезные команды
```bash
# Проверить конфигурацию
mvn spring-boot:run -Dspring-boot.run.arguments="--debug"

# Проверить профили
mvn spring-boot:run -Dspring-boot.run.arguments="--spring.profiles.active=dev"

# Проверить порты
netstat -tulpn | grep :8080
```

### Логирование
```yaml
# Включить отладочные логи
logging:
  level:
    io.github.bondalen.fepro: DEBUG
    org.springframework: INFO
    org.hibernate.SQL: DEBUG
```

## Профилактика

### Регулярные проверки
- Обновлять зависимости
- Проверять совместимость версий
- Тестировать на разных окружениях

### Мониторинг
- Настроить health checks
- Отслеживать метрики производительности
- Логировать ошибки

## Контакты

При возникновении проблем:
1. Проверить данное руководство
2. Изучить логи приложения
3. Обратиться к команде разработки