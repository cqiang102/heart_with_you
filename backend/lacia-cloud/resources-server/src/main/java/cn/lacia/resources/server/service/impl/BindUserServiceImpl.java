package cn.lacia.resources.server.service.impl;


import cn.lacia.common.exception.CommonException;
import cn.lacia.common.model.BindUser;
import cn.lacia.common.model.Result;
import cn.lacia.resources.server.mapper.BindMessageMapper;
import cn.lacia.resources.server.mapper.BindUserMapper;
import cn.lacia.resources.server.model.BindMessage;
import cn.lacia.resources.server.model.MessageType;
import cn.lacia.resources.server.model.UpdateUserVo;
import cn.lacia.resources.server.service.BindUserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import tk.mybatis.mapper.entity.Example;

import java.util.List;
import java.util.stream.Collectors;

/**
 * @author lacia
 * @date 2022/4/17 - 14:27
 */
@Service
@Slf4j
public class BindUserServiceImpl implements BindUserService {
    private final BindUserMapper bindUserMapper;
    private final BindMessageMapper bindMessageMapper;
    private final  PasswordEncoder passwordEncoder;

    public BindUserServiceImpl(BindUserMapper bindUserMapper, BindMessageMapper bindMessageMapper,
                               PasswordEncoder passwordEncoder) {
        this.bindUserMapper = bindUserMapper;
        this.bindMessageMapper = bindMessageMapper;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public BindUser selectByUsername(Long username) {
        BindUser bindUser = new BindUser();
        bindUser.setUsername(username);
        return bindUserMapper.selectOne(bindUser);
    }

    @Override
    public Result saveBackground(String image) {
        Example example = new Example(BindUser.class);
        example.createCriteria().andEqualTo("username", getUser());
        BindUser bindUser = new BindUser();
        bindUser.setBackgroundUrl(image);
        bindUserMapper.updateByExampleSelective(bindUser, example);
        return Result.builder().code("200").message("设置成功").build();
    }

    @Override
    public Result getFollowUser() {
        BindMessage bindMessage = new BindMessage();
        bindMessage.setFromId(getUser());
        bindMessage.setType(MessageType.FOLLOW.getValue());
        List<BindMessage> bindMessages = bindMessageMapper.select(bindMessage);
        if (bindMessages.isEmpty()) {
            throw new CommonException("未关注ta人");
        }
        List<Long> collect = bindMessages.stream().map(BindMessage::getToId).collect(Collectors.toList());
        Example example = new Example(BindUser.class);
        example.createCriteria().andIn("username", collect);
        List<BindUser> bindUsers = bindUserMapper.selectByExample(example);

        return Result.builder().code("200").message("ok").data(bindUsers).build();
    }

    @Override
    public Result getFollowedUser() {
        BindMessage bindMessage = new BindMessage();
        bindMessage.setToId(getUser());
        bindMessage.setType(MessageType.FOLLOW.getValue());
        List<BindMessage> bindMessages = bindMessageMapper.select(bindMessage);
        if (bindMessages.isEmpty()) {
            throw new CommonException("无人关注");
        }
        List<Long> collect = bindMessages.stream().map(BindMessage::getFromId).collect(Collectors.toList());
        Example example = new Example(BindUser.class);
        example.createCriteria().andIn("username", collect);
        List<BindUser> bindUsers = bindUserMapper.selectByExample(example);

        return Result.builder().code("200").message("ok").data(bindUsers).build();
    }

    @Override
    public Result getFriends() {
        BindMessage bindMessage = new BindMessage();
        bindMessage.setFromId(getUser());
        bindMessage.setType(MessageType.FOLLOW.getValue());
        List<BindMessage> bindMessages = bindMessageMapper.select(bindMessage);
        if (bindMessages.isEmpty()) {
            throw new CommonException("未关注他人");
        }
        bindMessage = new BindMessage();
        bindMessage.setToId(getUser());
        bindMessage.setType(MessageType.FOLLOW.getValue());
        Example bindMessageExample = new Example(BindMessage.class);
        bindMessageExample.createCriteria()
                .andEqualTo("toId", getUser())
                .andEqualTo("type", MessageType.FOLLOW.getValue())
                .andIn("fromId", bindMessages.stream().map(BindMessage::getToId).collect(Collectors.toList()));
        List<BindMessage> friends = bindMessageMapper.selectByExample(bindMessageExample);
        if (friends.isEmpty()) {
            throw new CommonException("没有好友");
        }
        List<Long> collect = friends.stream().map(BindMessage::getFromId).collect(Collectors.toList());
        Example example = new Example(BindUser.class);
        example.createCriteria().andIn("username", collect);
        List<BindUser> bindUsers = bindUserMapper.selectByExample(example);

        return Result.builder().code("200").message("ok").data(bindUsers).build();
    }

    @Override
    public void updateUser(UpdateUserVo updateUserVo) {
        if(updateUserVo.getPassword() != null && updateUserVo.getOld() == null){
            throw new CommonException("原密码不能为空");
        }

        BindUser bindUser = selectByUsername(getUser());
        if(bindUser == null){
            throw new CommonException("登录状态异常");
        }
        if (updateUserVo.getOld() != null && ! passwordEncoder.matches(updateUserVo.getOld(),bindUser.getPassword())) {
            throw  new CommonException("原密码错误");
        }
        bindUser.setPassword(passwordEncoder.encode(updateUserVo.getPassword()));
        if(StringUtils.hasText(updateUserVo.getEmail())){
            bindUser.setEmail(updateUserVo.getEmail());
        }
        if(StringUtils.hasText(updateUserVo.getNickname())){
            bindUser.setNickname(updateUserVo.getNickname());
        }
        bindUserMapper.updateByPrimaryKeySelective(bindUser);

    }

    private Long getUser() {
        String name = SecurityContextHolder.getContext().getAuthentication().getName();
        return Long.valueOf(name);
    }
}
