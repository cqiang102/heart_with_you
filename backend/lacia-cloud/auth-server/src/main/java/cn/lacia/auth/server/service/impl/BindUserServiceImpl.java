package cn.lacia.auth.server.service.impl;

import cn.lacia.common.exception.CommonException;
import cn.lacia.common.model.BindUser;
import cn.lacia.auth.server.model.RegisterUserVo;
import cn.lacia.common.model.Result;
import cn.lacia.auth.server.util.SnowFlake;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import cn.lacia.auth.server.mapper.BindUserMapper;
import cn.lacia.auth.server.service.BindUserService;

import java.time.LocalDateTime;

/**
 * @author lacia
 * @date 2022/4/17 - 14:27
 */
@Service
@Slf4j
public class BindUserServiceImpl implements BindUserService {

    private final BindUserMapper bindUserMapper;
    private final PasswordEncoder passwordEncoder;
    private final SnowFlake snowFlake;

    public BindUserServiceImpl(BindUserMapper bindUserMapper, PasswordEncoder passwordEncoder,
                               SnowFlake snowFlake) {
        this.bindUserMapper = bindUserMapper;
        this.passwordEncoder = passwordEncoder;
        this.snowFlake = snowFlake;
    }


    @Override
    public Result register(RegisterUserVo registerUserVo) {
        BindUser bindUser = new BindUser();
        bindUser.setId(snowFlake.nextId());
        bindUser.setUsername(snowFlake.nextId());
        bindUser.setPassword(passwordEncoder.encode(registerUserVo.getPassword()));
        bindUser.setNickname(registerUserVo.getNickname());
        bindUser.setEmail(registerUserVo.getEmail());
        bindUser.setCreateTime(LocalDateTime.now());
        int insert = bindUserMapper.insert(bindUser);
        log.info("注册 Service : data {} ,return {}",bindUser,insert);
        if(insert != 1){
            throw new CommonException("注册失败");
        }
        return Result.builder().code("200").message("注册成功").data(bindUser).build();
    }
}
