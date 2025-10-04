<template>
  <q-layout view="lHh Lpr lFf">
    <!-- Header -->
    <q-header elevated class="bg-primary text-white">
      <q-toolbar>
        <q-toolbar-title class="text-h6">
          <q-icon name="business" class="q-mr-sm" />
          FEPRO
        </q-toolbar-title>
        
        <q-space />
        
        <q-btn
          flat
          round
          dense
          icon="notifications"
          class="q-mr-sm"
        >
          <q-badge color="red" floating>3</q-badge>
        </q-btn>
        
        <q-btn-dropdown
          flat
          round
          dense
          :label="authStore.user?.firstName || authStore.user?.username"
          icon="account_circle"
        >
          <q-list>
            <q-item clickable v-close-popup @click="goToSettings">
              <q-item-section avatar>
                <q-icon name="settings" />
              </q-item-section>
              <q-item-section>Настройки</q-item-section>
            </q-item>
            
            <q-separator />
            
            <q-item clickable v-close-popup @click="authStore.logout">
              <q-item-section avatar>
                <q-icon name="logout" />
              </q-item-section>
              <q-item-section>Выйти</q-item-section>
            </q-item>
          </q-list>
        </q-btn-dropdown>
      </q-toolbar>
    </q-header>

    <!-- Navigation Drawer -->
    <q-drawer
      v-model="leftDrawerOpen"
      show-if-above
      bordered
      class="bg-grey-1"
    >
      <q-list>
        <q-item-label header class="text-grey-8">
          Навигация
        </q-item-label>
        
        <q-item
          clickable
          v-ripple
          :active="$route.name === 'home'"
          active-class="text-primary"
          @click="$router.push('/')"
        >
          <q-item-section avatar>
            <q-icon name="dashboard" />
          </q-item-section>
          <q-item-section>Главная</q-item-section>
        </q-item>
        
        <q-item
          clickable
          v-ripple
          :active="$route.name === 'contractors'"
          active-class="text-primary"
          @click="$router.push('/contractors')"
        >
          <q-item-section avatar>
            <q-icon name="business" />
          </q-item-section>
          <q-item-section>Контрагенты</q-item-section>
        </q-item>
        
        <q-item
          clickable
          v-ripple
          :active="$route.name === 'documents'"
          active-class="text-primary"
          @click="$router.push('/documents')"
        >
          <q-item-section avatar>
            <q-icon name="description" />
          </q-item-section>
          <q-item-section>Документы</q-item-section>
        </q-item>
        
        <q-item
          clickable
          v-ripple
          :active="$route.name === 'analytics'"
          active-class="text-primary"
          @click="$router.push('/analytics')"
        >
          <q-item-section avatar>
            <q-icon name="analytics" />
          </q-item-section>
          <q-item-section>Аналитика</q-item-section>
        </q-item>
      </q-list>
    </q-drawer>

    <!-- Main Content -->
    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const leftDrawerOpen = ref(false)

const goToSettings = () => {
  router.push('/settings')
}
</script>

<style lang="sass" scoped>
.q-layout
  min-height: 100vh
</style>