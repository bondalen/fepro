<template>
  <div class="login-page">
    <div class="login-container">
      <div class="login-card">
        <div class="login-header">
          <q-icon name="business" size="3rem" color="primary" />
          <h2 class="text-h4 text-center q-mt-md">FEPRO</h2>
          <p class="text-subtitle1 text-center text-grey-7 q-mb-lg">
            Federation Professionals
          </p>
        </div>

        <q-form @submit="handleLogin" class="login-form">
          <q-input
            v-model="credentials.username"
            label="Имя пользователя"
            outlined
            class="q-mb-md"
            :rules="[val => !!val || 'Введите имя пользователя']"
            :disable="authStore.isLoading"
          >
            <template v-slot:prepend>
              <q-icon name="person" />
            </template>
          </q-input>

          <q-input
            v-model="credentials.password"
            label="Пароль"
            type="password"
            outlined
            class="q-mb-lg"
            :rules="[val => !!val || 'Введите пароль']"
            :disable="authStore.isLoading"
          >
            <template v-slot:prepend>
              <q-icon name="lock" />
            </template>
          </q-input>

          <q-btn
            type="submit"
            color="primary"
            size="lg"
            class="full-width q-mb-md"
            :loading="authStore.isLoading"
            :disable="authStore.isLoading"
          >
            Войти
          </q-btn>
        </q-form>

        <div class="login-footer">
          <q-separator class="q-mb-md" />
          <div class="text-center text-caption text-grey-6">
            Демо доступ: admin / admin
          </div>
        </div>

        <!-- Error Alert -->
        <q-banner
          v-if="authStore.error"
          class="bg-negative text-white q-mt-md"
          rounded
        >
          <template v-slot:avatar>
            <q-icon name="error" />
          </template>
          {{ authStore.error }}
        </q-banner>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import type { LoginCredentials } from '@/stores/auth'

const authStore = useAuthStore()

const credentials = ref<LoginCredentials>({
  username: '',
  password: ''
})

const handleLogin = async () => {
  try {
    await authStore.login(credentials.value)
  } catch (error) {
    // Error is handled by the store
    console.error('Login error:', error)
  }
}

onMounted(() => {
  authStore.clearError()
})
</script>

<style lang="sass" scoped>
.login-page
  min-height: 100vh
  display: flex
  align-items: center
  justify-content: center
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%)
  padding: 16px

.login-container
  width: 100%
  max-width: 400px

.login-card
  background: white
  border-radius: 12px
  padding: 32px
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1)

.login-header
  text-align: center
  margin-bottom: 32px

.login-form
  margin-bottom: 24px

.login-footer
  margin-top: 24px
</style>