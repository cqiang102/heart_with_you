package cn.lacia.auth.server.exception;

import cn.lacia.common.model.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.support.DefaultMessageSourceResolvable;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.stream.Collectors;

/**
 * @author lacia
 * @date 2022/4/20 - 13:46
 */
@RestControllerAdvice
@Slf4j
public class CommonExceptionHandler {
    @ExceptionHandler(Exception.class)
    public Result handleException(Exception e){
        Result.ResultBuilder resultBuilder = Result.builder().code("120");
        log.info("{} : {}",e,e.getMessage());
        e.printStackTrace();
        if(e instanceof MethodArgumentNotValidException){
            return resultBuilder
                    .message(
                            ((MethodArgumentNotValidException) e).getAllErrors().stream().map(DefaultMessageSourceResolvable::getDefaultMessage).collect(Collectors.joining())
                    ).build();
        }

        return resultBuilder.message(e.getMessage()).build();
    }
}
