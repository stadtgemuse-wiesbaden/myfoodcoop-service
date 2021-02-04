package de.hsrm.vegetables.service.controller;

import de.hsrm.vegetables.Stadtgemuese_Backend.api.BalanceApi;
import de.hsrm.vegetables.Stadtgemuese_Backend.model.*;
import de.hsrm.vegetables.service.domain.dto.BalanceDto;
import de.hsrm.vegetables.service.domain.dto.BalanceHistoryItemDto;
import de.hsrm.vegetables.service.domain.dto.PurchaseDto;
import de.hsrm.vegetables.service.exception.ErrorCode;
import de.hsrm.vegetables.service.exception.errors.http.UnauthorizedError;
import de.hsrm.vegetables.service.mapper.BalanceMapper;
import de.hsrm.vegetables.service.mapper.PurchaseMapper;
import de.hsrm.vegetables.service.security.UserPrincipal;
import de.hsrm.vegetables.service.services.BalanceService;
import de.hsrm.vegetables.service.services.PurchaseService;
import de.hsrm.vegetables.service.services.UserService;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@RestController
@RequestMapping("/v2")
@RequiredArgsConstructor(onConstructor = @__({@Autowired}))
public class BalanceController implements BalanceApi {

    @NonNull
    private final BalanceService balanceService;

    @NonNull
    private final UserService userService;

    @NonNull
    private final PurchaseService purchaseService;

    @Override
    @PreAuthorize("hasRole('MEMBER') and (#userId == authentication.principal.id or hasRole('TREASURER'))")
    public ResponseEntity<BalanceResponse> userBalanceGet(String userId) {
        BalanceDto balanceDto = balanceService.getBalance(userService.getUserById(userId)
                .getUsername());
        return ResponseEntity.ok(BalanceMapper.balanceDtoToBalanceResponse(balanceDto));
    }

    @Override
    @PreAuthorize("hasRole('MEMBER') and (#userId == authentication.principal.id or hasRole('TREASURER'))")
    public ResponseEntity<BalanceHistoryResponse> userBalanceHistoryGet(String userId, Integer offset, Integer limit) {
        BalanceDto balanceDto = balanceService.getBalance(userService.getUserById(userId).getUsername());

        //
        // balanceHistoryItems from balance changes
        //

        List<BalanceHistoryItemDto> balanceHistoryItemDtos = balanceService.getBalanceHistoryItems(balanceDto);

        for (var balanceHistoryItem : balanceHistoryItemDtos) {
            if (!balanceDto.getName().equals(balanceHistoryItem.getBalanceDto().getName())) {
                throw new UnauthorizedError("The associated name for that balance history item does not match Header X-Username",
                        ErrorCode.USERNAME_DOES_NOT_MATCH_PURCHASE);
            }
        }

        List<BalanceHistoryItem> balanceHistoryItems1 = balanceHistoryItemDtos.stream()
                .map(BalanceMapper::balanceHistoryItemDtoToBalanceHistoryItem)
                .collect(Collectors.toList());

        //
        // balanceHistoryItems from purchases
        //

        List<PurchaseDto> purchaseDtos = purchaseService.getPurchases(balanceDto);

        for (var purchaseDto : purchaseDtos) {
            if (!balanceDto.getName().equals(purchaseDto.getBalanceDto().getName())) {
                throw new UnauthorizedError("The associated name for that balance history item does not match Header X-Username",
                        ErrorCode.USERNAME_DOES_NOT_MATCH_PURCHASE);
            }
        }

        List<BalanceHistoryItem> balanceHistoryItems2 = purchaseDtos.stream()
                .map(PurchaseMapper::purchaseDtoToBalanceHistoryItems)
                .flatMap(List::stream)
                .collect(Collectors.toList());

        //
        // Create response
        //

        Pagination pagination = new Pagination();
        pagination.setOffset(offset);
        pagination.setLimit(limit);
        pagination.setTotal(balanceHistoryItemDtos.size());

        List<BalanceHistoryItem> balanceHistoryItems = Stream
                .concat(balanceHistoryItems1.stream(), balanceHistoryItems2.stream())
                .collect(Collectors.toList());

        System.out.println("###");
        System.out.println("###");
        System.out.println("###");
        System.out.println(balanceHistoryItems);

        BalanceHistoryResponse balanceHistoryResponse = new BalanceHistoryResponse();
        balanceHistoryResponse.setBalanceHistoryItems(balanceHistoryItems);
        balanceHistoryResponse.setPagination(pagination);

        return ResponseEntity.ok(balanceHistoryResponse);
    }


    @Override
    @PreAuthorize("hasRole('MEMBER') and #userId == authentication.principal.id")
    public ResponseEntity<BalanceResponse> balancePatch(String userId, BalancePatchRequest request) {
        UserPrincipal userPrincipal = getUserPrincipalFromSecurityContext();

        BalanceDto balanceDto = balanceService.upsert(userPrincipal.getUsername(), request.getBalance());

        return ResponseEntity.ok(BalanceMapper.balanceDtoToBalanceResponse(balanceDto));
    }

    @Override
    @PreAuthorize("hasRole('MEMBER') and #userId == authentication.principal.id")
    public ResponseEntity<BalanceResponse> balanceTopup(String userId, BalanceAmountRequest request) {
        UserPrincipal userPrincipal = getUserPrincipalFromSecurityContext();

        BalanceDto balanceDto = balanceService.topup(userPrincipal.getUsername(), request.getAmount());

        userBalanceHistoryGet(userId, 0, 0);

        return ResponseEntity.ok(BalanceMapper.balanceDtoToBalanceResponse(balanceDto));
    }

    @Override
    @PreAuthorize("hasRole('MEMBER') and #userId == authentication.principal.id")
    public ResponseEntity<BalanceResponse> balanceWithdraw(String userId, BalanceAmountRequest request) {
        UserPrincipal userPrincipal = getUserPrincipalFromSecurityContext();

        BalanceDto balanceDto = balanceService.withdraw(userPrincipal.getUsername(), request.getAmount());

        return ResponseEntity.ok(BalanceMapper.balanceDtoToBalanceResponse(balanceDto));
    }

    private UserPrincipal getUserPrincipalFromSecurityContext() {
        return (UserPrincipal) SecurityContextHolder
                .getContext()
                .getAuthentication()
                .getPrincipal();
    }

}
