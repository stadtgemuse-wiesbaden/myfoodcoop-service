package de.hsrm.vegetables.service.mapper;

import de.hsrm.vegetables.Stadtgemuese_Backend.model.*;
import de.hsrm.vegetables.service.domain.dto.BalanceHistoryItemDto;
import de.hsrm.vegetables.service.domain.dto.PurchaseDto;
import de.hsrm.vegetables.service.domain.dto.PurchasedItemDto;
import de.hsrm.vegetables.service.services.StockService;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class PurchaseMapper {

    private PurchaseMapper() {
    }

    public static PurchaseHistoryItem purchaseDtoToPurchaseHistoryItem(PurchaseDto purchaseDto) {
        PurchaseHistoryItem purchaseHistoryItem = new PurchaseHistoryItem();
        purchaseHistoryItem.setId(purchaseDto.getId());
        purchaseHistoryItem.setTotalPrice(purchaseDto.getTotalPrice());
        purchaseHistoryItem.setCreatedOn(purchaseDto.getCreatedOn());
        purchaseHistoryItem.setItems(purchaseDto.getPurchasedItems()
                .stream()
                .map(PurchaseMapper::purchasedItemDtoToPurchaseItem)
                .collect(Collectors.toList()));
        purchaseHistoryItem.setTotalPrice(purchaseDto.getTotalPrice());
        purchaseHistoryItem.setTotalVat(purchaseDto.getTotalVat());
        purchaseHistoryItem.setVatDetails(getVatDetails(purchaseDto));
        return purchaseHistoryItem;
    }

    public static PurchaseItem purchasedItemDtoToPurchaseItem(PurchasedItemDto purchasedItemDto) {
        PurchaseItem purchaseItem = new PurchaseItem();
        purchaseItem.setId(purchasedItemDto.getStockDto()
                .getId());
        purchaseItem.setName(purchasedItemDto.getStockDto()
                .getName());
        purchaseItem.setAmount(purchasedItemDto.getAmount());
        purchaseItem.setPricePerUnit(purchasedItemDto.getPricePerUnit());
        purchaseItem.setUnitType(purchasedItemDto.getUnitType());
        purchaseItem.setVat(purchasedItemDto.getVat());

        return purchaseItem;
    }

    private static List<VatDetailItem> getVatDetails(PurchaseDto purchaseDto) {
        // Get all distinct vat rates
        ArrayList<Float> distinctVatRates = new ArrayList<>();
        purchaseDto.getPurchasedItems()
                .forEach(purchasedItemDto -> {
                    if (!distinctVatRates.contains(purchasedItemDto.getVat())) {
                        distinctVatRates.add(purchasedItemDto.getVat());
                    }
                });

        return distinctVatRates.stream()
                .map(vat -> {
                    // Get all purchased items with specific vat
                    List<PurchasedItemDto> purchasedItemsWithVat = purchaseDto.getPurchasedItems()
                            .stream()
                            .filter(purchasedItemDto -> purchasedItemDto.getVat()
                                    .equals(vat))
                            .collect(Collectors.toList());

                    // Calculate vat amount for these items
                    Float amount = purchasedItemsWithVat.stream()
                            .map(purchasedItemDto -> {
                                float vatForItem = ((purchasedItemDto.getAmount() * purchasedItemDto.getPricePerUnit())
                                        / (1f + purchasedItemDto.getVat()) * purchasedItemDto.getVat());
                                return StockService.round(vatForItem, 2);
                            })
                            .reduce(0f, Float::sum);

                    VatDetailItem vatDetailItem = new VatDetailItem();
                    vatDetailItem.setVat(vat);
                    vatDetailItem.setAmount(StockService.round(amount, 2));
                    return vatDetailItem;
                })
                .collect(Collectors.toList());
    }

    public static List<BalanceHistoryItem> purchaseDtoToBalanceHistoryItems(PurchaseDto purchaseDto) {
        OffsetDateTime createdOn = purchaseDto.getCreatedOn();

        return purchaseDto.getPurchasedItems()
                .stream()
                .map(purchasedItemDto -> {
                    BalanceHistoryItem balanceHistoryItem = new BalanceHistoryItem();

                    balanceHistoryItem.setId(purchasedItemDto.getStockDto()
                            .getId());
                    balanceHistoryItem.setCreatedOn(createdOn);
                    balanceHistoryItem.setBalanceChangeType(BalanceChangeType.PURCHASE);
                    balanceHistoryItem.setAmount(purchasedItemDto.getAmount());

                    return balanceHistoryItem;
                })
                .collect(Collectors.toList());
    }
}
