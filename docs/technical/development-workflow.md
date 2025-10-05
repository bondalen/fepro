# Development Workflow

## Обзор

Документ описывает процессы разработки, Git стратегию, CI/CD pipeline и инструменты для проекта FEPRO.

## Git Strategy

### GitHub Flow

Используем упрощенную модель GitHub Flow:

1. **main** - основная ветка (production-ready код)
2. **feature/*** - ветки для новых функций
3. **hotfix/*** - ветки для критических исправлений

### Правила работы с ветками

#### Создание feature ветки
```bash
# От основной ветки
git checkout main
git pull origin main
git checkout -b feature/contractor-management

# От другой feature ветки
git checkout feature/base-feature
git checkout -b feature/contractor-management
```

#### Коммиты
```bash
# Структура коммитов
git commit -m "feat: add contractor CRUD operations"
git commit -m "fix: resolve contractor validation issue"
git commit -m "docs: update API documentation"
git commit -m "test: add contractor service tests"
```

#### Pull Request
```bash
# Создание PR
git push origin feature/contractor-management
# Создать PR через GitHub UI

# Обновление PR
git add .
git commit -m "fix: address review comments"
git push origin feature/contractor-management
```

### Commit Message Convention

Используем [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### Типы коммитов
- **feat**: новая функция
- **fix**: исправление бага
- **docs**: документация
- **style**: форматирование кода
- **refactor**: рефакторинг
- **test**: тесты
- **chore**: вспомогательные задачи

#### Примеры
```bash
feat(contractor): add contractor search functionality
fix(auth): resolve JWT token validation issue
docs(api): update GraphQL schema documentation
test(service): add contractor service unit tests
```

## CI/CD Pipeline

### GitHub Actions

#### Workflow для Backend
```yaml
# .github/workflows/backend.yml
name: Backend CI/CD

on:
  push:
    branches: [main, develop]
    paths: ['backend/**']
  pull_request:
    branches: [main, develop]
    paths: ['backend/**']

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: fepro_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v4
      
      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          java-version: '21'
          distribution: 'temurin'
      
      - name: Cache Maven dependencies
        uses: actions/cache@v3
        with:
          path: ~/.m2
          key: ${{ runner.os }}-m2-${{ hashFiles('**/pom.xml') }}
      
      - name: Run tests
        run: mvn test
        env:
          SPRING_DATASOURCE_URL: jdbc:postgresql://localhost:5432/fepro_test
          SPRING_DATASOURCE_USERNAME: postgres
          SPRING_DATASOURCE_PASSWORD: postgres
      
      - name: Build application
        run: mvn clean package -DskipTests
      
      - name: Upload coverage reports
        uses: codecov/codecov-action@v3
        with:
          file: backend/target/site/jacoco/jacoco.xml
```

#### Workflow для Frontend
```yaml
# .github/workflows/frontend.yml
name: Frontend CI/CD

on:
  push:
    branches: [main, develop]
    paths: ['frontend/**']
  pull_request:
    branches: [main, develop]
    paths: ['frontend/**']

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install dependencies
        run: npm ci
        working-directory: frontend
      
      - name: Run linting
        run: npm run lint
        working-directory: frontend
      
      - name: Run tests
        run: npm run test:unit
        working-directory: frontend
      
      - name: Build application
        run: npm run build
        working-directory: frontend
      
      - name: Upload coverage reports
        uses: codecov/codecov-action@v3
        with:
          file: frontend/coverage/lcov.info
```

#### Workflow для Docker
```yaml
# .github/workflows/docker.yml
name: Docker Build and Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Build Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: false
          tags: fepro:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
      
      - name: Test Docker image
        run: |
          docker run --rm fepro:latest java -version
          docker run --rm fepro:latest echo "Image test successful"
```

## Code Quality

### Backend (Java)

#### Checkstyle
```xml
<!-- pom.xml -->
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-checkstyle-plugin</artifactId>
    <version>3.3.0</version>
    <configuration>
        <configLocation>checkstyle.xml</configLocation>
        <encoding>UTF-8</encoding>
        <consoleOutput>true</consoleOutput>
        <failsOnError>true</failsOnError>
    </configuration>
</plugin>
```

#### SpotBugs
```xml
<plugin>
    <groupId>com.github.spotbugs</groupId>
    <artifactId>spotbugs-maven-plugin</artifactId>
    <version>4.7.3.0</version>
    <configuration>
        <effort>Max</effort>
        <threshold>Low</threshold>
        <failOnError>true</failOnError>
    </configuration>
</plugin>
```

#### JaCoCo (Code Coverage)
```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.10</version>
    <executions>
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

### Frontend (Vue.js)

#### ESLint
```json
// .eslintrc.js
module.exports = {
  root: true,
  env: {
    node: true,
    browser: true,
    es2022: true
  },
  extends: [
    'plugin:vue/vue3-essential',
    '@vue/eslint-config-typescript',
    '@vue/eslint-config-prettier'
  ],
  rules: {
    'no-console': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    '@typescript-eslint/no-unused-vars': 'error',
    'vue/multi-word-component-names': 'off'
  }
}
```

#### Prettier
```json
// .prettierrc
{
  "semi": false,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100,
  "endOfLine": "lf"
}
```

#### Vitest (Testing)
```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  test: {
    environment: 'jsdom',
    coverage: {
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'src/test/',
        '**/*.d.ts'
      ]
    }
  }
})
```

## Testing Strategy

### Backend Testing

#### Unit Tests
```java
@ExtendWith(MockitoExtension.class)
class ContractorServiceTest {
    
    @Mock
    private ContractorRepository contractorRepository;
    
    @InjectMocks
    private ContractorService contractorService;
    
    @Test
    void shouldCreateContractor() {
        // Given
        ContractorInput input = new ContractorInput("Test Company", "1234567890");
        Contractor expectedContractor = new Contractor("Test Company", "1234567890");
        
        when(contractorRepository.save(any(Contractor.class)))
            .thenReturn(expectedContractor);
        
        // When
        Contractor result = contractorService.createContractor(input);
        
        // Then
        assertThat(result.getName()).isEqualTo("Test Company");
        assertThat(result.getInn()).isEqualTo("1234567890");
        verify(contractorRepository).save(any(Contractor.class));
    }
}
```

#### Integration Tests
```java
@SpringBootTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Testcontainers
class ContractorControllerIntegrationTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16")
            .withDatabaseName("fepro_test")
            .withUsername("test")
            .withPassword("test");
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    void shouldCreateContractor() {
        // Given
        ContractorInput input = new ContractorInput("Test Company", "1234567890");
        
        // When
        ResponseEntity<Contractor> response = restTemplate.postForEntity(
            "/api/contractors", input, Contractor.class);
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody().getName()).isEqualTo("Test Company");
    }
}
```

### Frontend Testing

#### Unit Tests
```typescript
// ContractorService.spec.ts
import { describe, it, expect, vi } from 'vitest'
import { useContractorStore } from '@/stores/contractor'

describe('ContractorService', () => {
  it('should create contractor', async () => {
    const store = useContractorStore()
    const input = { name: 'Test Company', inn: '1234567890' }
    
    vi.spyOn(store, 'createContractor').mockResolvedValue({
      id: '1',
      name: 'Test Company',
      inn: '1234567890'
    })
    
    const result = await store.createContractor(input)
    
    expect(result.name).toBe('Test Company')
    expect(result.inn).toBe('1234567890')
  })
})
```

#### Component Tests
```typescript
// ContractorForm.spec.ts
import { mount } from '@vue/test-utils'
import { describe, it, expect } from 'vitest'
import ContractorForm from '@/components/ContractorForm.vue'

describe('ContractorForm', () => {
  it('should render form fields', () => {
    const wrapper = mount(ContractorForm)
    
    expect(wrapper.find('input[name="name"]').exists()).toBe(true)
    expect(wrapper.find('input[name="inn"]').exists()).toBe(true)
    expect(wrapper.find('input[name="email"]').exists()).toBe(true)
  })
  
  it('should emit submit event', async () => {
    const wrapper = mount(ContractorForm)
    
    await wrapper.find('form').trigger('submit')
    
    expect(wrapper.emitted('submit')).toBeTruthy()
  })
})
```

## Deployment Strategy

### Environments

#### Development
- **Branch**: `develop`
- **URL**: `http://localhost:8082`
- **Database**: `fepro_dev`
- **Auto-deploy**: при push в `develop`

#### Staging
- **Branch**: `main`
- **URL**: `https://staging.fepro.ru`
- **Database**: `fepro_staging`
- **Auto-deploy**: при merge в `main`

#### Production
- **Branch**: `main`
- **URL**: `https://fepro.ru`
- **Database**: `fepro_prod`
- **Manual deploy**: через GitHub Actions

### Deployment Process

#### 1. Development
```bash
# Разработка
git checkout develop
git pull origin develop
git checkout -b feature/new-feature

# Разработка и тестирование
# ...

# Merge в develop
git checkout develop
git merge feature/new-feature
git push origin develop
# Автоматический деплой на dev сервер
```

#### 2. Staging
```bash
# Подготовка к релизу
git checkout main
git pull origin main
git merge develop
git push origin main
# Автоматический деплой на staging сервер
```

#### 3. Production
```bash
# Ручной деплой в production
# Через GitHub Actions UI
# Или через CLI
gh workflow run deploy-production.yml
```

## Monitoring and Logging

### Application Monitoring

#### Backend (Spring Boot Actuator)
```yaml
# application.yml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: always
  metrics:
    export:
      prometheus:
        enabled: true
```

#### Frontend (Vue.js)
```typescript
// main.ts
import { createApp } from 'vue'
import App from './App.vue'

const app = createApp(App)

// Error tracking
app.config.errorHandler = (err, instance, info) => {
  console.error('Vue error:', err, info)
  // Send to monitoring service
}

app.mount('#app')
```

### Logging

#### Backend Logging
```yaml
# application.yml
logging:
  level:
    root: INFO
    com.fepro: DEBUG
  file:
    name: /app/logs/fepro.log
    max-size: 10MB
    max-history: 7
  pattern:
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
```

#### Frontend Logging
```typescript
// utils/logger.ts
export const logger = {
  info: (message: string, data?: any) => {
    console.log(`[INFO] ${message}`, data)
  },
  error: (message: string, error?: Error) => {
    console.error(`[ERROR] ${message}`, error)
    // Send to monitoring service
  },
  warn: (message: string, data?: any) => {
    console.warn(`[WARN] ${message}`, data)
  }
}
```

## Связанные документы

- [003-graphql-api-choice.md](../decisions/003-graphql-api-choice.md) - GraphQL API
- [007-modular-monolith-pattern.md](../decisions/007-modular-monolith-pattern.md) - Архитектура
- [009-jwt-security-approach.md](../decisions/009-jwt-security-approach.md) - Безопасность