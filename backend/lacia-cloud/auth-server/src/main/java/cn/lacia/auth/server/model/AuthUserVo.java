package cn.lacia.auth.server.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * @author lacia
 * @date 2022/4/18 - 21:42
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class AuthUserVo {
    private String username;
    private String password;
    private String clientId;
    private String clientSecret;
}
