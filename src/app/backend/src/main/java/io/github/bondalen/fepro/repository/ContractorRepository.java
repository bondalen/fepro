package io.github.bondalen.fepro.repository;

import io.github.bondalen.fepro.model.Contractor;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * Репозиторий для работы с контрагентами
 */
@Repository
public interface ContractorRepository extends ReactiveCrudRepository<Contractor, UUID> {

    /**
     * Поиск контрагентов по имени (case-insensitive)
     */
    @Query("SELECT * FROM contractors WHERE LOWER(name) LIKE LOWER(CONCAT('%', :search, '%')) ORDER BY created_at DESC")
    Flux<Contractor> findByNameContainingIgnoreCase(String search);

    /**
     * Поиск контрагентов по статусу
     */
    Flux<Contractor> findByStatus(Contractor.ContractorStatus status);

    /**
     * Поиск контрагента по ИНН
     */
    Mono<Contractor> findByInn(String inn);

    /**
     * Поиск контрагента по email
     */
    Mono<Contractor> findByEmail(String email);

    /**
     * Проверка существования контрагента с указанным ИНН
     */
    @Query("SELECT COUNT(*) > 0 FROM contractors WHERE inn = :inn")
    Mono<Boolean> existsByInn(String inn);

    /**
     * Проверка существования контрагента с указанным email
     */
    @Query("SELECT COUNT(*) > 0 FROM contractors WHERE email = :email")
    Mono<Boolean> existsByEmail(String email);

    /**
     * Получение активных контрагентов
     */
    @Query("SELECT * FROM contractors WHERE status = 'ACTIVE' ORDER BY name ASC")
    Flux<Contractor> findActiveContractors();

    /**
     * Поиск контрагентов с пагинацией
     */
    @Query("SELECT * FROM contractors ORDER BY :sortBy :sortDirection LIMIT :limit OFFSET :offset")
    Flux<Contractor> findWithPagination(String sortBy, String sortDirection, int limit, int offset);

    /**
     * Подсчет общего количества контрагентов
     */
    @Query("SELECT COUNT(*) FROM contractors")
    Mono<Long> countAll();

    /**
     * Поиск контрагентов в радиусе (PostGIS)
     */
    @Query("SELECT * FROM contractors WHERE ST_DWithin(coordinates::geometry, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326), :radius)")
    Flux<Contractor> findNearby(double lat, double lng, double radius);
}