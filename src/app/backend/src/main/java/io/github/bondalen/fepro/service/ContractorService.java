package io.github.bondalen.fepro.service;

import io.github.bondalen.fepro.model.Contractor;
import io.github.bondalen.fepro.repository.ContractorRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Сервис для работы с контрагентами
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ContractorService {

    private final ContractorRepository contractorRepository;

    /**
     * Получение всех контрагентов
     */
    public Flux<Contractor> getAllContractors() {
        log.debug("Getting all contractors");
        return contractorRepository.findAll();
    }

    /**
     * Получение контрагента по ID
     */
    public Mono<Contractor> getContractorById(UUID id) {
        log.debug("Getting contractor by ID: {}", id);
        return contractorRepository.findById(id);
    }

    /**
     * Создание нового контрагента
     */
    public Mono<Contractor> createContractor(Contractor contractor) {
        log.debug("Creating contractor: {}", contractor.getName());
        
        contractor.setId(UUID.randomUUID());
        contractor.setCreatedAt(LocalDateTime.now());
        contractor.setUpdatedAt(LocalDateTime.now());
        
        if (contractor.getStatus() == null) {
            contractor.setStatus(Contractor.ContractorStatus.ACTIVE);
        }
        
        return contractorRepository.save(contractor);
    }

    /**
     * Обновление контрагента
     */
    public Mono<Contractor> updateContractor(UUID id, Contractor contractor) {
        log.debug("Updating contractor with ID: {}", id);
        
        return contractorRepository.findById(id)
            .flatMap(existingContractor -> {
                existingContractor.setName(contractor.getName());
                existingContractor.setLegalName(contractor.getLegalName());
                existingContractor.setInn(contractor.getInn());
                existingContractor.setKpp(contractor.getKpp());
                existingContractor.setEmail(contractor.getEmail());
                existingContractor.setPhone(contractor.getPhone());
                existingContractor.setAddress(contractor.getAddress());
                existingContractor.setCoordinates(contractor.getCoordinates());
                existingContractor.setStatus(contractor.getStatus());
                existingContractor.setUpdatedAt(LocalDateTime.now());
                
                return contractorRepository.save(existingContractor);
            });
    }

    /**
     * Удаление контрагента
     */
    public Mono<Void> deleteContractor(UUID id) {
        log.debug("Deleting contractor with ID: {}", id);
        return contractorRepository.deleteById(id);
    }

    /**
     * Поиск контрагентов по имени
     */
    public Flux<Contractor> searchContractorsByName(String name) {
        log.debug("Searching contractors by name: {}", name);
        return contractorRepository.findByNameContainingIgnoreCase(name);
    }

    /**
     * Получение контрагентов по статусу
     */
    public Flux<Contractor> getContractorsByStatus(Contractor.ContractorStatus status) {
        log.debug("Getting contractors by status: {}", status);
        return contractorRepository.findByStatus(status);
    }

    /**
     * Получение активных контрагентов
     */
    public Flux<Contractor> getActiveContractors() {
        log.debug("Getting active contractors");
        return contractorRepository.findActiveContractors();
    }

    /**
     * Проверка существования контрагента с указанным ИНН
     */
    public Mono<Boolean> existsByInn(String inn) {
        log.debug("Checking if contractor exists by INN: {}", inn);
        return contractorRepository.existsByInn(inn);
    }

    /**
     * Проверка существования контрагента с указанным email
     */
    public Mono<Boolean> existsByEmail(String email) {
        log.debug("Checking if contractor exists by email: {}", email);
        return contractorRepository.existsByEmail(email);
    }

    /**
     * Получение контрагентов в радиусе
     */
    public Flux<Contractor> getNearbyContractors(double lat, double lng, double radius) {
        log.debug("Getting contractors near location: lat={}, lng={}, radius={}", lat, lng, radius);
        return contractorRepository.findNearby(lat, lng, radius);
    }
}