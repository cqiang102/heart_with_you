package cn.lacia.auth.server.model;

import lombok.Data;
import org.hibernate.validator.constraints.Length;

import javax.validation.constraints.Email;
import javax.validation.constraints.NotNull;

/**
 * @author lacia
 * @date 2022/4/19 - 22:02
 */
@Data
public class RegisterUserVo {

    @NotNull(message = "昵称不能为空")
    private String nickname;

    @Email(message = "邮箱格式不正确")
    private String email;
    @NotNull(message = "密码不能为空")
    @Length(min = 8,max = 18,message = "密码长度不符")
    private String password;
}
