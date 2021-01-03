package de.hsrm.vegetables.service.domain.dto;

import lombok.Data;
import org.hibernate.annotations.GenericGenerator;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import javax.persistence.*;
import java.time.OffsetDateTime;
import java.util.List;

@Entity
@EntityListeners(AuditingEntityListener.class)
@Data
public class PurchaseDto {

    @Id
    @GeneratedValue(generator = "uuid")
    @GenericGenerator(name = "uuid", strategy = "uuid2")
    private String id;

    @Column
    private OffsetDateTime createdOn;

    @Column(nullable = false)
    private Float totalPrice;

    @OneToMany
    private List<PurchasedItemDto> purchasedItems;

    @ManyToOne
    // Tie this purchase to a balance and thus to a user
    private BalanceDto balanceDto;

    @PrePersist
    public void setCreationDateTime() {
        this.createdOn = OffsetDateTime.now();
    }
}