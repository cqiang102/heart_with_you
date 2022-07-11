package cn.lacia.auth.server.model;

import cn.lacia.common.model.BindUser;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

/**
 * @author lacia
 * @date 2022/4/17 - 14:59
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@JsonTypeInfo(use = JsonTypeInfo.Id.NONE)
public class BindUserDetails implements UserDetails , Serializable {

    private boolean enabled = true;
    private boolean accountNonExpired =true;
    private boolean credentialsNonExpired = true;
    private boolean accountNonLocked = true;
    private Set<SimpleGrantedAuthority> authorities = new HashSet<>();

    private static final long serialVersionUID = 7572650868437767577L;


    private Long id;
    private String username;
    @JsonIgnore
    private String password;
    private String nickname;
    @JsonProperty("background_url")
    private String backgroundUrl;

    @JsonProperty("create_time")
    @JsonDeserialize(using = LocalDateTimeDeserializer.class)
    @JsonSerialize(using = LocalDateTimeSerializer.class)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
    private String email;

    public BindUserDetails(BindUser bindUser){
        this.username = String.valueOf(bindUser.getUsername());
        this.id = bindUser.getId();
        this.password = bindUser.getPassword();
        this.nickname = bindUser.getNickname();
        this.backgroundUrl = bindUser.getBackgroundUrl();
        this.createTime = bindUser.getCreateTime();
        this.email = bindUser.getEmail();
        this.authorities.add(new SimpleGrantedAuthority("user"));
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return this.password;
    }

    @Override
    public String getUsername() {
        return this.username;
    }

    @Override
    public boolean isAccountNonExpired() {
        return this.accountNonExpired;
    }

    @Override
    public boolean isAccountNonLocked() {
        return this.accountNonLocked;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return this.credentialsNonExpired;
    }

    @Override
    public boolean isEnabled() {
        return this.enabled;
    }
}
