package cn.lacia.resources.server.config;

import cn.lacia.common.model.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * @author lacia
 * @date 2022/4/20 - 13:46
 */
@RestControllerAdvice
@Slf4j
public class CommonExceptionHandler {
    @ExceptionHandler(Exception.class)
    public Result handleException(Exception e){
        log.info("{} : {}",e,e.getMessage());
        e.printStackTrace();
        Result.ResultBuilder builder = Result.builder().code("120");
        if(e instanceof NumberFormatException){
            return builder
                    .message(
                            "参数类型错误").build();
        }
        return builder.message(e.getMessage()).build();
    }
}
