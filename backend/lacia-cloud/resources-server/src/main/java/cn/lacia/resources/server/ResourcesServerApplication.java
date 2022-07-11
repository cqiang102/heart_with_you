package cn.lacia.resources.server;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.AuthenticatedPrincipal;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.core.OAuth2AuthenticatedPrincipal;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import tk.mybatis.spring.annotation.MapperScan;

/**
 * @author lacia
 * @date 2022/4/16 - 10:15
 */
@SpringBootApplication
@Slf4j
@RestController
@MapperScan("cn.lacia.resources.server.mapper")
@EnableTransactionManagement
public class ResourcesServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ResourcesServerApplication.class, args);
    }


    @GetMapping("test")
    public ResponseEntity<String[]> test() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        System.out.println(authentication.getPrincipal());
        log.info("resources test");
        return ResponseEntity.ok(new String[]{"test1","test2"});
    }
}
