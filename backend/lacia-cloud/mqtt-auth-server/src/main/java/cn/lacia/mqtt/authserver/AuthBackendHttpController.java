package cn.lacia.mqtt.authserver;

import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import static java.util.Arrays.asList;
import static org.springframework.util.StringUtils.collectionToDelimitedString;

/**
 * @author lacia
 * @date 2022/4/13 - 22:24
 * A basic controller that implements all RabbitMQ authN/authZ interface operations.
 */
@RestController
@RequestMapping(path = "/auth", method = {RequestMethod.GET, RequestMethod.POST})
@Slf4j
public class AuthBackendHttpController {


    @RequestMapping("user")
    public String user(@RequestParam("username") String username,
                       @RequestParam("password") String password) {


        log.info("Successfully authenticated user {}", username);
        return "allow";

//            return "deny";

    }

    @RequestMapping("vhost")
    public String vhost(VirtualHostCheck check) {
        log.info("Checking vhost access with {}", check);
        return "allow";
    }

    @RequestMapping("resource")
    public String resource(ResourceCheck check) {
        log.info("Checking resource access with {}", check);
        // todo 权限管理
        // user 只可读取
        return "allow";
    }

    @RequestMapping("topic")
    public String topic(TopicCheck check) {
//        boolean result = check.getRouting_key().startsWith("a");
        log.info("Checking topic access with {}", check);
//        return result ?
//                "allow"
//                : "deny";
        return "allow";

    }
}
