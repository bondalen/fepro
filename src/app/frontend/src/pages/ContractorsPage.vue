<template>
  <div class="contractors-page fepro-page">
    <div class="fepro-container">
      <!-- Page Header -->
      <div class="row items-center justify-between q-mb-lg">
        <div>
          <h1 class="text-h4 q-mb-none">Контрагенты</h1>
          <p class="text-grey-7 q-mt-sm">Управление контрагентами и партнерами</p>
        </div>
        <q-btn
          color="primary"
          icon="add"
          label="Добавить контрагента"
          @click="showAddDialog = true"
        />
      </div>

      <!-- Filters -->
      <q-card class="q-mb-lg">
        <q-card-section>
          <div class="row q-gutter-md">
            <q-input
              v-model="filters.search"
              label="Поиск"
              outlined
              dense
              class="col-12 col-md-4"
              @input="debouncedSearch"
            >
              <template v-slot:prepend>
                <q-icon name="search" />
              </template>
            </q-input>

            <q-select
              v-model="filters.status"
              label="Статус"
              outlined
              dense
              clearable
              :options="statusOptions"
              class="col-12 col-md-3"
              @update:model-value="loadContractors"
            />

            <q-btn
              color="primary"
              outline
              icon="filter_list"
              label="Фильтры"
              @click="showFilters = !showFilters"
              class="col-auto"
            />
          </div>
        </q-card-section>
      </q-card>

      <!-- Contractors Table -->
      <q-card>
        <q-table
          :rows="contractors"
          :columns="columns"
          :loading="loading"
          row-key="id"
          :pagination="pagination"
          @request="loadContractors"
          binary-state-sort
        >
          <template v-slot:body-cell-status="props">
            <q-td :props="props">
              <q-badge
                :color="getStatusColor(props.value)"
                :label="getStatusLabel(props.value)"
              />
            </q-td>
          </template>

          <template v-slot:body-cell-actions="props">
            <q-td :props="props">
              <q-btn
                flat
                round
                color="primary"
                icon="visibility"
                @click="viewContractor(props.row)"
                class="q-mr-xs"
              >
                <q-tooltip>Просмотр</q-tooltip>
              </q-btn>
              <q-btn
                flat
                round
                color="secondary"
                icon="edit"
                @click="editContractor(props.row)"
                class="q-mr-xs"
              >
                <q-tooltip>Редактировать</q-tooltip>
              </q-btn>
              <q-btn
                flat
                round
                color="negative"
                icon="delete"
                @click="deleteContractor(props.row)"
              >
                <q-tooltip>Удалить</q-tooltip>
              </q-btn>
            </q-td>
          </template>
        </q-table>
      </q-card>

      <!-- Add/Edit Dialog -->
      <q-dialog v-model="showAddDialog" persistent>
        <q-card style="min-width: 500px">
          <q-card-section>
            <div class="text-h6">
              {{ editingContractor ? 'Редактировать контрагента' : 'Добавить контрагента' }}
            </div>
          </q-card-section>

          <q-card-section>
            <q-form @submit="saveContractor">
              <q-input
                v-model="contractorForm.name"
                label="Название *"
                outlined
                :rules="[val => !!val || 'Обязательное поле']"
                class="q-mb-md"
              />

              <q-input
                v-model="contractorForm.legalName"
                label="Юридическое название"
                outlined
                class="q-mb-md"
              />

              <div class="row q-gutter-md">
                <q-input
                  v-model="contractorForm.inn"
                  label="ИНН"
                  outlined
                  class="col"
                  mask="##########"
                />
                <q-input
                  v-model="contractorForm.kpp"
                  label="КПП"
                  outlined
                  class="col"
                  mask="#########"
                />
              </div>

              <div class="row q-gutter-md q-mt-md">
                <q-input
                  v-model="contractorForm.email"
                  label="Email"
                  outlined
                  type="email"
                  class="col"
                />
                <q-input
                  v-model="contractorForm.phone"
                  label="Телефон"
                  outlined
                  class="col"
                />
              </div>

              <q-input
                v-model="contractorForm.address"
                label="Адрес"
                outlined
                type="textarea"
                rows="2"
                class="q-mt-md"
              />
            </q-form>
          </q-card-section>

          <q-card-actions align="right">
            <q-btn flat label="Отмена" @click="closeDialog" />
            <q-btn
              color="primary"
              label="Сохранить"
              @click="saveContractor"
              :loading="saving"
            />
          </q-card-actions>
        </q-card>
      </q-dialog>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive } from 'vue'
import { useRouter } from 'vue-router'
import type { Contractor, ContractorFilters, CreateContractorInput } from '@/types/contractor'

const router = useRouter()

// State
const contractors = ref<Contractor[]>([])
const loading = ref(false)
const saving = ref(false)
const showAddDialog = ref(false)
const showFilters = ref(false)
const editingContractor = ref<Contractor | null>(null)

const filters = reactive<ContractorFilters>({
  search: '',
  status: undefined,
  limit: 10,
  offset: 0
})

const contractorForm = reactive<CreateContractorInput>({
  name: '',
  legalName: '',
  inn: '',
  kpp: '',
  email: '',
  phone: '',
  address: ''
})

const pagination = ref({
  sortBy: 'createdAt',
  descending: true,
  page: 1,
  rowsPerPage: 10,
  rowsNumber: 0
})

// Options
const statusOptions = [
  { label: 'Активный', value: 'active' },
  { label: 'Неактивный', value: 'inactive' },
  { label: 'Ожидает', value: 'pending' },
  { label: 'Заблокирован', value: 'blocked' }
]

// Table columns
const columns = [
  {
    name: 'name',
    required: true,
    label: 'Название',
    align: 'left',
    field: 'name',
    sortable: true
  },
  {
    name: 'inn',
    label: 'ИНН',
    align: 'left',
    field: 'inn',
    sortable: true
  },
  {
    name: 'email',
    label: 'Email',
    align: 'left',
    field: 'email'
  },
  {
    name: 'phone',
    label: 'Телефон',
    align: 'left',
    field: 'phone'
  },
  {
    name: 'status',
    label: 'Статус',
    align: 'center',
    field: 'status',
    sortable: true
  },
  {
    name: 'actions',
    label: 'Действия',
    align: 'center',
    field: 'actions'
  }
]

// Methods
const loadContractors = async () => {
  loading.value = true
  try {
    // TODO: Implement actual API call
    // Mock data for now
    contractors.value = [
      {
        id: '1',
        name: 'ООО "Рога и Копыта"',
        legalName: 'Общество с ограниченной ответственностью "Рога и Копыта"',
        inn: '1234567890',
        kpp: '123456789',
        email: 'info@rogakopita.ru',
        phone: '+7 (495) 123-45-67',
        address: 'г. Москва, ул. Примерная, д. 1',
        status: 'active',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      }
    ]
    pagination.value.rowsNumber = contractors.value.length
  } catch (error) {
    console.error('Error loading contractors:', error)
  } finally {
    loading.value = false
  }
}

const debouncedSearch = (() => {
  let timeout: NodeJS.Timeout
  return () => {
    clearTimeout(timeout)
    timeout = setTimeout(() => {
      loadContractors()
    }, 500)
  }
})()

const getStatusColor = (status: string) => {
  const colors = {
    active: 'positive',
    inactive: 'grey',
    pending: 'warning',
    blocked: 'negative'
  }
  return colors[status as keyof typeof colors] || 'grey'
}

const getStatusLabel = (status: string) => {
  const labels = {
    active: 'Активный',
    inactive: 'Неактивный',
    pending: 'Ожидает',
    blocked: 'Заблокирован'
  }
  return labels[status as keyof typeof labels] || status
}

const viewContractor = (contractor: Contractor) => {
  router.push(`/contractors/${contractor.id}`)
}

const editContractor = (contractor: Contractor) => {
  editingContractor.value = contractor
  Object.assign(contractorForm, contractor)
  showAddDialog.value = true
}

const deleteContractor = (contractor: Contractor) => {
  // TODO: Implement delete confirmation and API call
  console.log('Delete contractor:', contractor)
}

const saveContractor = async () => {
  saving.value = true
  try {
    // TODO: Implement actual API call
    console.log('Save contractor:', contractorForm)
    closeDialog()
    await loadContractors()
  } catch (error) {
    console.error('Error saving contractor:', error)
  } finally {
    saving.value = false
  }
}

const closeDialog = () => {
  showAddDialog.value = false
  editingContractor.value = null
  Object.assign(contractorForm, {
    name: '',
    legalName: '',
    inn: '',
    kpp: '',
    email: '',
    phone: '',
    address: ''
  })
}

onMounted(() => {
  loadContractors()
})
</script>

<style lang="sass" scoped>
.contractors-page
  padding: 24px 0
</style>