package de.hsrm.vegetables.my_food_coop_service.services;

import de.hsrm.vegetables.my_food_coop_service.domain.dto.PurchaseDto;
import de.hsrm.vegetables.my_food_coop_service.domain.dto.PurchasedItemDto;
import de.hsrm.vegetables.my_food_coop_service.domain.dto.StockDto;
import de.hsrm.vegetables.my_food_coop_service.domain.dto.UserDto;
import de.hsrm.vegetables.my_food_coop_service.exception.ErrorCode;
import de.hsrm.vegetables.my_food_coop_service.exception.errors.http.InternalError;
import de.hsrm.vegetables.my_food_coop_service.exception.errors.http.NotFoundError;
import de.hsrm.vegetables.my_food_coop_service.model.BalanceChangeType;
import de.hsrm.vegetables.my_food_coop_service.model.CartItem;
import de.hsrm.vegetables.my_food_coop_service.repositories.PurchaseRepository;
import de.hsrm.vegetables.my_food_coop_service.repositories.PurchasedItemRepository;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor(onConstructor = @__({@Autowired}))
public class PurchaseService {

    @NonNull
    private final PurchaseRepository purchaseRepository;

    @NonNull
    private final PurchasedItemRepository purchasedItemRepository;

    @NonNull
    private final BalanceHistoryService balanceHistoryService;


    /**
     * Purchase items
     *
     * @param userDto    The user who purchased the items
     * @param stockItems The StockDto that were purchased
     * @param cartItems  The amounts of the items purchased
     * @return The completed purchase
     */
    public PurchaseDto purchaseItems(UserDto userDto, List<StockDto> stockItems, List<CartItem> cartItems, Float totalPrice, Float totalVat) {
        List<PurchasedItemDto> purchasedItems = cartItems
                .stream()
                .map(item -> {
                    Optional<StockDto> associatedStockDto = stockItems
                            .stream()
                            .filter(stockItem -> stockItem.getId()
                                    .equals(item.getId()))
                            .findFirst();

                    if (associatedStockDto.isEmpty()) {
                        throw new InternalError("No matching stock item was found in stockItems", ErrorCode.STOCK_DTO_NOT_FOUND);
                    }

                    PurchasedItemDto purchasedItemDto = new PurchasedItemDto();
                    purchasedItemDto.setAmount(item.getAmount());
                    purchasedItemDto.setPricePerUnit(associatedStockDto.get()
                            .getPricePerUnit());
                    purchasedItemDto.setStockDto(associatedStockDto.get());
                    purchasedItemDto.setUnitType(associatedStockDto.get()
                            .getUnitType());
                    purchasedItemDto.setVat(associatedStockDto.get()
                            .getVat());

                    return purchasedItemDto;
                })
                .map(purchasedItemRepository::save)
                .collect(Collectors.toList());

        PurchaseDto purchaseDto = new PurchaseDto();
        purchaseDto.setTotalPrice(totalPrice);
        purchaseDto.setPurchasedItems(purchasedItems);
        purchaseDto.setUserDto(userDto);
        purchaseDto.setTotalVat(totalVat);

        PurchaseDto savedPurchaseDto = purchaseRepository.save(purchaseDto);

        balanceHistoryService.saveBalanceChange(userDto, purchaseDto.getCreatedOn(),
                savedPurchaseDto, BalanceChangeType.PURCHASE, purchaseDto.getTotalPrice());

        return savedPurchaseDto;
    }

    /**
     * Find a page of purchases by name.
     * Returns a page with all elements if offset is null.
     *
     * @param userDto The user who purchased the items
     * @param offset  Pagination offset (first element in returned page)
     * @param limit   Pagination limit (number of elements in returned page)
     * @return A list of purchases made by the given user
     */
    public Page<PurchaseDto> getPurchases(UserDto userDto, Integer offset, Integer limit) {
        Pageable pageable = (offset == null) ? Pageable.unpaged() : PageRequest.of(offset / limit, limit);
        return purchaseRepository.findAllByUserDto(userDto, pageable);
    }

    /**
     * Find one purchase by id
     *
     * @param id Unique id of the purchase
     * @return The whole purchase
     */
    public PurchaseDto getPurchase(String id) {
        PurchaseDto purchaseDto = purchaseRepository.findById(id);

        if (purchaseDto == null) {
            throw new NotFoundError("No purchase with id " + id + " was found", ErrorCode.NO_PURCHASE_FOUND);
        }

        return purchaseDto;
    }

    /**
     * Find all purchases between fromDate and toDate
     *
     * @param fromDateConverted start of time window of the purchase list
     * @param toDateConverted   end of time window of the purchase list
     * @return A list of purchases in the given time
     */
    public List<PurchaseDto> findAllByCreatedOnBetween(OffsetDateTime fromDateConverted, OffsetDateTime toDateConverted) {
        return purchaseRepository.findAllByCreatedOnBetween(fromDateConverted, toDateConverted);
    }
}
