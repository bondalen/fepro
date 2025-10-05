# Решение 009: JWT Security подход

**Дата:** 2025-01-02  
**Статус:** ✅ Принято  
**Участники:** Александр  

## Проблема

Необходимо выбрать подход к безопасности для системы управления отношениями с контрагентами FEPRO с учетом:
- Аутентификация пользователей
- Авторизация доступа к ресурсам
- Безопасность API
- Простота реализации и поддержки

## Рассмотренные варианты

### 1. Session-based аутентификация
- **Описание:** Серверные сессии с cookies
- **Плюсы:** Простота, возможность отзыва сессий, безопасность на сервере
- **Минусы:** Не масштабируется, требует sticky sessions, проблемы с CORS

### 2. JWT (JSON Web Tokens)
- **Описание:** Stateless токены с подписью
- **Плюсы:** Масштабируемость, stateless, поддержка мобильных приложений
- **Минусы:** Сложность отзыва токенов, размер токенов, безопасность на клиенте

### 3. OAuth 2.0 / OpenID Connect
- **Описание:** Стандарт авторизации с внешними провайдерами
- **Плюсы:** Стандартизация, интеграция с внешними системами
- **Минусы:** Сложность реализации, избыточность для простых случаев

## Решение

Выбран **JWT + RBAC** по следующим причинам:

### Основные преимущества:
1. **Stateless архитектура** - не требует хранения сессий на сервере
2. **Масштабируемость** - легко масштабировать горизонтально
3. **Мобильная поддержка** - отлично работает с мобильными приложениями
4. **Простота реализации** - стандартные библиотеки
5. **Гибкость** - можно включить любую информацию в токен

### Архитектурные решения:

#### JWT Structure
```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "sub": "user123",
    "username": "alex",
    "roles": ["USER", "ADMIN"],
    "permissions": ["contractor:read", "contractor:write"],
    "iat": 1640995200,
    "exp": 1641081600
  }
}
```

#### RBAC (Role-Based Access Control)
```java
public enum UserRole {
    USER("Пользователь"),
    MANAGER("Менеджер"), 
    ADMIN("Администратор");
    
    private final String description;
}

public enum Permission {
    CONTRACTOR_READ("contractor:read"),
    CONTRACTOR_WRITE("contractor:write"),
    CONTRACTOR_DELETE("contractor:delete"),
    USER_MANAGE("user:manage");
}
```

## Реализация

### Backend Security Configuration
```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/contractors/**").hasRole("USER")
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class)
            .build();
    }
}
```

### JWT Service
```java
@Service
public class JwtService {
    
    private final String secretKey = "fepro-secret-key";
    private final int jwtExpiration = 86400000; // 24 hours
    
    public String generateToken(UserDetails userDetails) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("roles", userDetails.getAuthorities());
        return createToken(claims, userDetails.getUsername());
    }
    
    public boolean validateToken(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        return (username.equals(userDetails.getUsername()) && !isTokenExpired(token));
    }
}
```

### Frontend Integration
```typescript
// Vue.js + Axios
const apiClient = axios.create({
  baseURL: '/api',
  headers: {
    'Content-Type': 'application/json'
  }
});

// Request interceptor
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('jwt_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  }
);

// Response interceptor
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Redirect to login
      router.push('/login');
    }
    return Promise.reject(error);
  }
);
```

## Последствия

### Положительные:
- ✅ Stateless архитектура
- ✅ Масштабируемость
- ✅ Мобильная поддержка
- ✅ Простота реализации
- ✅ Гибкость в настройке прав

### Отрицательные:
- ⚠️ Сложность отзыва токенов
- ⚠️ Размер токенов (больше чем cookies)
- ⚠️ Безопасность на клиенте
- ⚠️ Потенциальные проблемы с XSS

## Стратегия безопасности

### 1. Токены
- **Access Token** - короткоживущий (15 минут)
- **Refresh Token** - долгоживущий (7 дней)
- **Rotation** - обновление refresh токенов

### 2. Хранение токенов
- **Access Token** - в памяти (JavaScript)
- **Refresh Token** - httpOnly cookie
- **Защита от XSS** - CSP заголовки

### 3. Валидация
- **Подпись** - HMAC SHA256
- **Время жизни** - проверка exp
- **Blacklist** - для отозванных токенов

## Мониторинг безопасности

### Метрики:
- Количество неудачных попыток входа
- Время жизни токенов
- Частота обновления токенов

### Логирование:
- Все попытки аутентификации
- Неудачные попытки доступа
- Подозрительная активность

## Альтернативы на будущее

При росте требований к безопасности:
1. **OAuth 2.0** - интеграция с внешними провайдерами
2. **SAML** - корпоративная аутентификация
3. **Multi-factor authentication** - двухфакторная аутентификация

## Связанные решения

- [003-graphql-api-choice.md](./003-graphql-api-choice.md) - GraphQL API
- [006-spring-boot-framework-choice.md](./006-spring-boot-framework-choice.md) - Spring Boot
- [security-architecture.md](../architecture/security-architecture.md) - Архитектура безопасности