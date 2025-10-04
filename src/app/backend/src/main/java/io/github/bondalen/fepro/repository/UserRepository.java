package io.github.bondalen.fepro.repository;

import io.github.bondalen.fepro.model.User;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * Репозиторий для работы с пользователями
 */
@Repository
public interface UserRepository extends ReactiveCrudRepository<User, UUID> {

    /**
     * Поиск пользователя по имени пользователя
     */
    Mono<User> findByUsername(String username);

    /**
     * Поиск пользователя по email
     */
    Mono<User> findByEmail(String email);

    /**
     * Проверка существования пользователя с указанным именем пользователя
     */
    @Query("SELECT COUNT(*) > 0 FROM users WHERE username = :username")
    Mono<Boolean> existsByUsername(String username);

    /**
     * Проверка существования пользователя с указанным email
     */
    @Query("SELECT COUNT(*) > 0 FROM users WHERE email = :email")
    Mono<Boolean> existsByEmail(String email);

    /**
     * Поиск активного пользователя по имени пользователя
     */
    @Query("SELECT * FROM users WHERE username = :username AND is_active = true")
    Mono<User> findActiveByUsername(String username);

    /**
     * Поиск активного пользователя по email
     */
    @Query("SELECT * FROM users WHERE email = :email AND is_active = true")
    Mono<User> findActiveByEmail(String email);
}