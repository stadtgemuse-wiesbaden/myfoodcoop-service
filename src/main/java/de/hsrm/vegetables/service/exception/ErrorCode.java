package de.hsrm.vegetables.service.exception;

public enum ErrorCode {

    // 400
    MISSING_SERVLET_REQUEST_PARAMETER(400001),
    SERVLET_REQUEST_BINDING_EXCEPTION(400002),
    TYPE_MISMATCH(400003),
    MESSAGE_NOT_READABLE(400004),
    METHOD_ARGUMENT_NOT_VALID(400005),
    MISSING_SERVLET_REQUEST_PART(400006),
    BIND_EXCEPTION(400007),
    NO_FRACTIONAL_QUANTITY(400008),
    ITEM_IS_DELETED(400009),

    // 404
    NO_HANDLER_FOUND(404001),
    NO_BALANCE_FOUND(404002),
    NO_STOCK_ITEM_FOUND(404003),

    // 405
    METHOD_NOT_ALLOWED(405001),

    // 406
    NOT_ACCEPTABLE(406001),

    // 415
    UNSUPPORTED_MEDIA_TYPE(415001),

    // 500
    INTERNAL_EXCEPTION(500001),
    MISSING_PATH_VARIABLE(500002),
    CONVERSION_NOT_SUPPORTED(500003),
    MESSAGE_NOT_WRITABLE(500004),
    EXAMPLE_EXCEPTION(500005),

    // 503
    ASYNC_REQUEST_TIMEOUT(503001);

    private int code;

    ErrorCode(int code) {
        this.code = code;
    }

    public int getValue() {
        return code;
    }
}
