import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'

export interface User {
  id: string
  username: string
  email: string
  firstName?: string
  lastName?: string
  role: string
  isActive: boolean
  createdAt: string
  updatedAt: string
}

export interface LoginCredentials {
  username: string
  password: string
}

export const useAuthStore = defineStore('auth', () => {
  const router = useRouter()
  
  // State
  const user = ref<User | null>(null)
  const token = ref<string | null>(null)
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  // Getters
  const isAuthenticated = computed(() => !!user.value && !!token.value)
  const userRole = computed(() => user.value?.role || 'USER')
  const isAdmin = computed(() => user.value?.role === 'ADMIN')

  // Actions
  const initialize = () => {
    const savedToken = localStorage.getItem('auth-token')
    const savedUser = localStorage.getItem('auth-user')
    
    if (savedToken && savedUser) {
      try {
        token.value = savedToken
        user.value = JSON.parse(savedUser)
      } catch (error) {
        console.error('Error parsing saved user data:', error)
        logout()
      }
    }
  }

  const login = async (credentials: LoginCredentials) => {
    isLoading.value = true
    error.value = null
    
    try {
      // TODO: Implement actual login API call
      // const response = await apolloClient.mutate({
      //   mutation: LOGIN_MUTATION,
      //   variables: credentials
      // })
      
      // Mock login for now
      if (credentials.username === 'admin' && credentials.password === 'admin') {
        const mockUser: User = {
          id: '1',
          username: 'admin',
          email: 'admin@fepro.app',
          firstName: 'Администратор',
          lastName: 'Системы',
          role: 'ADMIN',
          isActive: true,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString()
        }
        
        const mockToken = 'mock-jwt-token'
        
        user.value = mockUser
        token.value = mockToken
        
        // Save to localStorage
        localStorage.setItem('auth-token', mockToken)
        localStorage.setItem('auth-user', JSON.stringify(mockUser))
        
        router.push('/')
      } else {
        throw new Error('Неверные учетные данные')
      }
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Ошибка входа в систему'
      throw err
    } finally {
      isLoading.value = false
    }
  }

  const logout = () => {
    user.value = null
    token.value = null
    error.value = null
    
    localStorage.removeItem('auth-token')
    localStorage.removeItem('auth-user')
    
    router.push('/login')
  }

  const updateUser = (userData: Partial<User>) => {
    if (user.value) {
      user.value = { ...user.value, ...userData }
      localStorage.setItem('auth-user', JSON.stringify(user.value))
    }
  }

  const clearError = () => {
    error.value = null
  }

  return {
    // State
    user,
    token,
    isLoading,
    error,
    
    // Getters
    isAuthenticated,
    userRole,
    isAdmin,
    
    // Actions
    initialize,
    login,
    logout,
    updateUser,
    clearError
  }
})