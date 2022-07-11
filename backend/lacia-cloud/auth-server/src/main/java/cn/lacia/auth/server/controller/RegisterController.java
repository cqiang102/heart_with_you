package cn.lacia.auth.server.controller;

import cn.lacia.auth.server.model.RegisterUserVo;
import cn.lacia.auth.server.service.BindUserService;
import cn.lacia.common.model.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author lacia
 * @date 2022/4/17 - 16:47
 */
@RestController
@Slf4j
@RequestMapping(value = "api")
public class RegisterController {
    private final BindUserService bindUserService;


    public RegisterController(BindUserService bindUserService) {
        this.bindUserService = bindUserService;
    }

    @PostMapping("register")
    public Result register(@RequestBody @Validated RegisterUserVo registerUserVo){
        log.info("注册接口 : {}",registerUserVo);
        return bindUserService.register(registerUserVo);
    }
}
