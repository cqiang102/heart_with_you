package cn.lacia.auth.server.service.impl;

import cn.lacia.auth.server.mapper.BindUserMapper;
import cn.lacia.common.model.BindUser;
import cn.lacia.auth.server.model.BindUserDetails;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import javax.security.auth.login.AccountNotFoundException;

/**
 * @author lacia
 * @date 2022/4/17 - 14:58
 */
@Service("userDetailsServiceImpl")
@Slf4j
public class UserDetailsServiceImpl implements UserDetailsService {
    private final BindUserMapper bindUserMapper;

    public UserDetailsServiceImpl(BindUserMapper bindUserMapper) {
        this.bindUserMapper = bindUserMapper;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        BindUser bindUser = new BindUser();
        try {
            Long aLong = Long.parseLong(username);
            bindUser.setUsername(aLong);
            log.info("使用账号登录 {}",username);
        } catch (NumberFormatException e) {
           log.info("使用邮箱登录 {}",username);
            bindUser.setEmail(username);
        }
        bindUser = bindUserMapper.selectOne(bindUser);
        if (bindUser == null) {
            throw new UsernameNotFoundException("账号不存在");
        }
        return new BindUserDetails(bindUser);
    }
}
