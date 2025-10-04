export interface Contractor {
  id: string
  name: string
  legalName?: string
  inn?: string
  kpp?: string
  email?: string
  phone?: string
  address?: string
  coordinates?: {
    lat: number
    lng: number
  }
  status: ContractorStatus
  createdAt: string
  updatedAt: string
}

export type ContractorStatus = 'active' | 'inactive' | 'pending' | 'blocked'

export interface ContractorContact {
  id: string
  contractorId: string
  name: string
  position?: string
  email?: string
  phone?: string
  isPrimary: boolean
  createdAt: string
  updatedAt: string
}

export interface ContractorHistory {
  id: string
  contractorId: string
  action: string
  description?: string
  userId: string
  createdAt: string
}

export interface CreateContractorInput {
  name: string
  legalName?: string
  inn?: string
  kpp?: string
  email?: string
  phone?: string
  address?: string
  coordinates?: {
    lat: number
    lng: number
  }
}

export interface UpdateContractorInput {
  id: string
  name?: string
  legalName?: string
  inn?: string
  kpp?: string
  email?: string
  phone?: string
  address?: string
  coordinates?: {
    lat: number
    lng: number
  }
  status?: ContractorStatus
}

export interface ContractorFilters {
  search?: string
  status?: ContractorStatus
  region?: string
  limit?: number
  offset?: number
}

export interface ContractorListResponse {
  contractors: Contractor[]
  totalCount: number
  hasNextPage: boolean
}