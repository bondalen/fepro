<template>
  <div id="app">
    <router-view />
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

onMounted(() => {
  // Инициализация приложения
  authStore.initialize()
})
</script>

<style lang="sass">
// Импорт Quasar переменных
@import 'quasar/src/css/variables.sass'

// Глобальные стили
#app
  font-family: 'Roboto', sans-serif
  -webkit-font-smoothing: antialiased
  -moz-osx-font-smoothing: grayscale

// Кастомные стили для FEPRO
.fepro-container
  max-width: 1200px
  margin: 0 auto
  padding: 0 16px

.fepro-page
  padding: 24px 0

.fepro-card
  border-radius: 8px
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1)

.fepro-button
  border-radius: 6px
  text-transform: none
  font-weight: 500

.fepro-input
  border-radius: 6px

// Адаптивность
@media (max-width: 768px)
  .fepro-container
    padding: 0 8px
  
  .fepro-page
    padding: 16px 0
</style>