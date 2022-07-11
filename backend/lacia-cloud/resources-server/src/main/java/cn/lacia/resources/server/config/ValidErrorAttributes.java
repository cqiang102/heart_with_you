package cn.lacia.resources.server.config;

import org.springframework.boot.web.error.ErrorAttributeOptions;
import org.springframework.boot.web.servlet.error.DefaultErrorAttributes;
import org.springframework.stereotype.Component;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.context.request.WebRequest;

import java.util.Map;

/**
 * @author lacia
 * @date 2022/4/28 - 22:59
 */
@Component
public class ValidErrorAttributes extends DefaultErrorAttributes {
    @Override
    public Map<String, Object> getErrorAttributes(WebRequest webRequest, ErrorAttributeOptions options) {
        Map<String, Object> errorAttributes = super.getErrorAttributes(webRequest, options);
        Throwable error = getError(webRequest);
        if (error instanceof MethodArgumentNotValidException){
            MethodArgumentNotValidException methodArgumentNotValidException = (MethodArgumentNotValidException) error;
            BindingResult bindingResult = methodArgumentNotValidException.getBindingResult();
            errorAttributes.put("message", bindingResult.getFieldError().getDefaultMessage());
        }
        return errorAttributes;
    }
}
