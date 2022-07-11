package cn.lacia.auth.server.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * @author lacia
 * @date 2022/4/20 - 17:02
 */
@Controller
public class RootController {
    @GetMapping("loginPage")
    public String loginPage(){
        return "login_page";
    }
    @GetMapping("registerPage")
    public String registerPage(){
        return "register_page";
    }

}
