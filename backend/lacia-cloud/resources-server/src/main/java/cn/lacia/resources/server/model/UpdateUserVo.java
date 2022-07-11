package cn.lacia.resources.server.model;

import lombok.Data;
import org.hibernate.validator.constraints.Length;

/**
 * @author lacia
 * @date 2022/5/8 - 9:34
 */
@Data
public class UpdateUserVo {

    private String nickname;

    private String email;

    @Length(min = 8,max = 18,message = "密码长度不符")
    private String password;

    @Length(min = 8,max = 18,message = "密码长度不符")
    private String old;
}
