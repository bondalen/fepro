<template>
  <div class="not-found-page fepro-page">
    <div class="fepro-container">
      <div class="text-center">
        <q-icon name="error_outline" size="5rem" color="grey-5" />
        <h1 class="text-h3 q-mt-lg q-mb-md">404</h1>
        <p class="text-h6 text-grey-7 q-mb-lg">Страница не найдена</p>
        <q-btn
          color="primary"
          label="На главную"
          @click="$router.push('/')"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// 404 Not Found page
</script>