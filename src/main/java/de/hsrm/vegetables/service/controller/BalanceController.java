package de.hsrm.vegetables.service.controller;

import de.hsrm.vegetables.Stadtgemuese_Backend.api.BalanceApi;
import de.hsrm.vegetables.Stadtgemuese_Backend.model.BalanceAmountRequest;
import de.hsrm.vegetables.Stadtgemuese_Backend.model.BalancePatchRequest;
import de.hsrm.vegetables.Stadtgemuese_Backend.model.BalanceResponse;
import de.hsrm.vegetables.service.domain.dto.UserDto;
import de.hsrm.vegetables.service.mapper.Mapper;
import de.hsrm.vegetables.service.security.UserPrincipal;
import de.hsrm.vegetables.service.services.UserService;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/v2")
@RequiredArgsConstructor(onConstructor = @__({@Autowired}))
public class BalanceController implements BalanceApi {

    @NonNull
    private final UserService userService;

    @Override
    @PreAuthorize("hasRole('MEMBER') and (#userId == authentication.principal.id or hasRole('TREASURER'))")
    public ResponseEntity<BalanceResponse> userBalanceGet(String userId) {
        UserDto userDto = userService.getUserById(userId);
        return ResponseEntity.ok(Mapper.userDtoToBalanceResponse(userDto));
    }

    @Override
    @PreAuthorize("hasRole('MEMBER') and #userId == authentication.principal.id")
    public ResponseEntity<BalanceResponse> balancePatch(String userId, BalancePatchRequest request) {
        UserPrincipal userPrincipal = getUserPrincipalFromSecurityContext();

        UserDto userDto = userService.getUserById(userPrincipal.getId());
        userDto = userService.setBalance(userDto, request.getBalance());

        return ResponseEntity.ok(Mapper.userDtoToBalanceResponse(userDto));
    }

    @Override
    @PreAuthorize("hasRole('MEMBER') and #userId == authentication.principal.id")
    public ResponseEntity<BalanceResponse> balanceTopup(String userId, BalanceAmountRequest request) {
        UserPrincipal userPrincipal = getUserPrincipalFromSecurityContext();

        UserDto userDto = userService.getUserById(userPrincipal.getId());
        userDto = userService.topup(userDto, request.getAmount());

        return ResponseEntity.ok(Mapper.userDtoToBalanceResponse(userDto));
    }

    @Override
    @PreAuthorize("hasRole('MEMBER') and #userId == authentication.principal.id")
    public ResponseEntity<BalanceResponse> balanceWithdraw(String userId, BalanceAmountRequest request) {
        UserPrincipal userPrincipal = getUserPrincipalFromSecurityContext();

        UserDto userDto = userService.getUserById(userPrincipal.getId());
        userDto = userService.withdraw(userDto, request.getAmount());

        return ResponseEntity.ok(Mapper.userDtoToBalanceResponse(userDto));
    }

    private UserPrincipal getUserPrincipalFromSecurityContext() {
        return (UserPrincipal) SecurityContextHolder
                .getContext()
                .getAuthentication()
                .getPrincipal();
    }

}
