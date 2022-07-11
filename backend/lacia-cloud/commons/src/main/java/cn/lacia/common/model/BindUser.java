package cn.lacia.common.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Table;
import java.io.Serializable;
import java.time.LocalDateTime;


/**
 * @date 2022/4/17 - 14:27
 * @author lacia
 * 用户表
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "lacia_app.bind_user")
public class BindUser implements Serializable {
    /**
     * 主键
     */
    @Id
    @Column(name = "id")
    private Long id;

    /**
     * 登录账号
     */
    @Column(name = "username")
    private Long username;

    /**
     * 密码
     */
    @Column(name = "`password`")
    @JsonIgnore
    private String password;

    /**
     * 邮箱
     */
    @Column(name = "email")
    private String email;

    /**
     * 昵称
     */
    @Column(name = "nickname")
    private String nickname;
    /**
     * 背景
     */
    @Column(name = "background_url")
    @JsonProperty("background_url")
    private String backgroundUrl;

    /**
     * 注册时间
     */
    @Column(name = "create_time")
    @JsonProperty("create_time")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @JsonDeserialize(using = LocalDateTimeDeserializer.class)
    @JsonSerialize(using = LocalDateTimeSerializer.class)
    private LocalDateTime createTime;

    private static final long serialVersionUID = 2102072850353160627L;
}
