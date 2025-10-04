package io.github.bondalen.fepro.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Модель контрагента
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table("contractors")
public class Contractor {

    @Id
    private UUID id;

    @Column("name")
    private String name;

    @Column("legal_name")
    private String legalName;

    @Column("inn")
    private String inn;

    @Column("kpp")
    private String kpp;

    @Column("email")
    private String email;

    @Column("phone")
    private String phone;

    @Column("address")
    private String address;

    @Column("coordinates")
    private String coordinates; // JSON string for PostGIS geometry

    @Column("status")
    private ContractorStatus status;

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    /**
     * Статусы контрагента
     */
    public enum ContractorStatus {
        ACTIVE("Активный"),
        INACTIVE("Неактивный"),
        PENDING("Ожидает"),
        BLOCKED("Заблокирован");

        private final String description;

        ContractorStatus(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }
    }
}