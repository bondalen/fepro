package io.github.bondalen.fepro.controller;

import io.github.bondalen.fepro.model.Contractor;
import io.github.bondalen.fepro.service.ContractorService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.graphql.data.method.annotation.SchemaMapping;
import org.springframework.stereotype.Controller;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * GraphQL контроллер для работы с контрагентами
 */
@Slf4j
@Controller
@RequiredArgsConstructor
public class ContractorController {

    private final ContractorService contractorService;

    /**
     * Получение всех контрагентов
     */
    @QueryMapping
    public Flux<Contractor> contractors() {
        log.debug("GraphQL: Getting all contractors");
        return contractorService.getAllContractors();
    }

    /**
     * Получение контрагента по ID
     */
    @QueryMapping
    public Mono<Contractor> contractor(@Argument String id) {
        log.debug("GraphQL: Getting contractor by ID: {}", id);
        return contractorService.getContractorById(UUID.fromString(id));
    }

    /**
     * Получение контрагентов по статусу
     */
    @QueryMapping
    public Flux<Contractor> contractorsByStatus(@Argument Contractor.ContractorStatus status) {
        log.debug("GraphQL: Getting contractors by status: {}", status);
        return contractorService.getContractorsByStatus(status);
    }

    /**
     * Поиск контрагентов по имени
     */
    @QueryMapping
    public Flux<Contractor> searchContractors(@Argument String name) {
        log.debug("GraphQL: Searching contractors by name: {}", name);
        return contractorService.searchContractorsByName(name);
    }

    /**
     * Получение контрагентов в радиусе
     */
    @QueryMapping
    public Flux<Contractor> nearbyContractors(
            @Argument double lat,
            @Argument double lng,
            @Argument double radius) {
        log.debug("GraphQL: Getting contractors near location: lat={}, lng={}, radius={}", lat, lng, radius);
        return contractorService.getNearbyContractors(lat, lng, radius);
    }

    /**
     * Создание нового контрагента
     */
    @MutationMapping
    public Mono<Contractor> createContractor(@Argument CreateContractorInput input) {
        log.debug("GraphQL: Creating contractor: {}", input.getName());
        
        Contractor contractor = Contractor.builder()
                .name(input.getName())
                .legalName(input.getLegalName())
                .inn(input.getInn())
                .kpp(input.getKpp())
                .email(input.getEmail())
                .phone(input.getPhone())
                .address(input.getAddress())
                .coordinates(input.getCoordinates())
                .status(input.getStatus() != null ? input.getStatus() : Contractor.ContractorStatus.ACTIVE)
                .build();
        
        return contractorService.createContractor(contractor);
    }

    /**
     * Обновление контрагента
     */
    @MutationMapping
    public Mono<Contractor> updateContractor(@Argument UpdateContractorInput input) {
        log.debug("GraphQL: Updating contractor with ID: {}", input.getId());
        
        Contractor contractor = Contractor.builder()
                .id(UUID.fromString(input.getId()))
                .name(input.getName())
                .legalName(input.getLegalName())
                .inn(input.getInn())
                .kpp(input.getKpp())
                .email(input.getEmail())
                .phone(input.getPhone())
                .address(input.getAddress())
                .coordinates(input.getCoordinates())
                .status(input.getStatus())
                .build();
        
        return contractorService.updateContractor(UUID.fromString(input.getId()), contractor);
    }

    /**
     * Удаление контрагента
     */
    @MutationMapping
    public Mono<Boolean> deleteContractor(@Argument String id) {
        log.debug("GraphQL: Deleting contractor with ID: {}", id);
        return contractorService.deleteContractor(UUID.fromString(id))
                .then(Mono.just(true))
                .onErrorReturn(false);
    }

    /**
     * Маппинг для поля coordinates
     */
    @SchemaMapping(typeName = "Contractor", field = "coordinates")
    public Mono<String> coordinates(Contractor contractor) {
        return Mono.just(contractor.getCoordinates());
    }

    /**
     * Входные данные для создания контрагента
     */
    public static class CreateContractorInput {
        private String name;
        private String legalName;
        private String inn;
        private String kpp;
        private String email;
        private String phone;
        private String address;
        private String coordinates;
        private Contractor.ContractorStatus status;

        // Getters and setters
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        
        public String getLegalName() { return legalName; }
        public void setLegalName(String legalName) { this.legalName = legalName; }
        
        public String getInn() { return inn; }
        public void setInn(String inn) { this.inn = inn; }
        
        public String getKpp() { return kpp; }
        public void setKpp(String kpp) { this.kpp = kpp; }
        
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        
        public String getPhone() { return phone; }
        public void setPhone(String phone) { this.phone = phone; }
        
        public String getAddress() { return address; }
        public void setAddress(String address) { this.address = address; }
        
        public String getCoordinates() { return coordinates; }
        public void setCoordinates(String coordinates) { this.coordinates = coordinates; }
        
        public Contractor.ContractorStatus getStatus() { return status; }
        public void setStatus(Contractor.ContractorStatus status) { this.status = status; }
    }

    /**
     * Входные данные для обновления контрагента
     */
    public static class UpdateContractorInput {
        private String id;
        private String name;
        private String legalName;
        private String inn;
        private String kpp;
        private String email;
        private String phone;
        private String address;
        private String coordinates;
        private Contractor.ContractorStatus status;

        // Getters and setters
        public String getId() { return id; }
        public void setId(String id) { this.id = id; }
        
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        
        public String getLegalName() { return legalName; }
        public void setLegalName(String legalName) { this.legalName = legalName; }
        
        public String getInn() { return inn; }
        public void setInn(String inn) { this.inn = inn; }
        
        public String getKpp() { return kpp; }
        public void setKpp(String kpp) { this.kpp = kpp; }
        
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        
        public String getPhone() { return phone; }
        public void setPhone(String phone) { this.phone = phone; }
        
        public String getAddress() { return address; }
        public void setAddress(String address) { this.address = address; }
        
        public String getCoordinates() { return coordinates; }
        public void setCoordinates(String coordinates) { this.coordinates = coordinates; }
        
        public Contractor.ContractorStatus getStatus() { return status; }
        public void setStatus(Contractor.ContractorStatus status) { this.status = status; }
    }
}