package de.hsrm.vegetables.my_food_coop_service.repositories;

import de.hsrm.vegetables.my_food_coop_service.domain.dto.DisposedDto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.util.List;

@Repository
public interface DisposedRepository extends JpaRepository<DisposedDto, Long> {

    List<DisposedDto> findAllByCreatedOnBetween(OffsetDateTime fromDate, OffsetDateTime toDate);

}
