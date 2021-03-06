package de.hsrm.vegetables.my_food_coop_service.interceptors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@Component
public class RequestLoggerInterceptor implements HandlerInterceptor {

    final Logger logger = LoggerFactory.getLogger(RequestLoggerInterceptor.class);

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, @NonNull Object handler, @Nullable Exception ex) {
        String httpMethod = request.getMethod();
        String requestURI = request.getRequestURI();
        String queryString = request.getQueryString();
        int status = response.getStatus();

        // Don't log OPTIONS calls
        if (httpMethod.equals("OPTIONS")) return;

        StringBuilder sb = new StringBuilder();
        sb.append(httpMethod);
        sb.append("\t||\t");
        sb.append(requestURI);
        if (queryString != null) sb.append(queryString);
        sb.append("\t||\t");
        sb.append(status);

        if (logger.isInfoEnabled()) {
            logger.info(sb.toString());
        }

    }

}