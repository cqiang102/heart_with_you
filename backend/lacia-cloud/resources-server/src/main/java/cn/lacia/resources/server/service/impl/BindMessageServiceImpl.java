package cn.lacia.resources.server.service.impl;

import cn.lacia.common.exception.CommonException;
import cn.lacia.resources.server.config.MqttConfig;
import cn.lacia.resources.server.model.BindMessage;
import cn.lacia.resources.server.model.MessageType;
import cn.lacia.resources.server.service.BindMessageService;
import cn.lacia.resources.server.mapper.BindMessageMapper;
import cn.lacia.resources.server.util.SnowFlake;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.Lists;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tk.mybatis.mapper.entity.Example;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

/**
 * @author lacia
 * @date 2022/4/22 - 12:34
 */
@Service
@Slf4j
@Transactional(rollbackFor = Exception.class)
public class BindMessageServiceImpl implements BindMessageService {

    private final BindMessageMapper bindMessageMapper;
    private final SnowFlake snowFlake;
    private final MqttConfig.MqttGateway mqttGateway;
    public static final int FOLLOW_MAX = 50;


    public BindMessageServiceImpl(BindMessageMapper bindMessageMapper, SnowFlake snowFlake,
                                  MqttConfig.MqttGateway mqttGateway) {
        this.bindMessageMapper = bindMessageMapper;
        this.snowFlake = snowFlake;
        this.mqttGateway = mqttGateway;
    }


    @Override
    public BindMessage saveMessage(BindMessage bindMessage) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String name = authentication.getName();
        // 验证
        if (!name.equals(String.valueOf(bindMessage.getFromId()))) {
            throw new CommonException("非法消息");
        }
        if (bindMessage.getMessageId() == null) {
            bindMessage.setMessageId(snowFlake.nextId());
        }
        bindMessage.setCreateTime(LocalDateTime.now());
        int insert = bindMessageMapper.insertSelective(bindMessage);
        if (insert == 0) {
            throw new CommonException("消息重复发送");
        }
        String msg;
        try {
            msg = new ObjectMapper().writeValueAsString(bindMessage);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
            throw new CommonException("消息格式错误");
        }
        mqttGateway.sendToUser(msg, String.valueOf(bindMessage.getToId()));
        // get 自己也发一条
        mqttGateway.sendToUser(msg, String.valueOf(bindMessage.getFromId()));
        log.info("send msg : {}", msg);

        return bindMessage;
    }

    @Override
    public boolean selectFollowStatus(Long username) {
        Long user = getUser();
        Example example = new Example(BindMessage.class);
        example.createCriteria()
                .andEqualTo("fromId", user)
                .andEqualTo("toId", username)
                .andEqualTo("type", MessageType.FOLLOW.getValue());
        BindMessage bindMessage = bindMessageMapper.selectOneByExample(example);
        log.info("FollowStatus : {}", bindMessage);
        return bindMessage != null;
    }

    @Override
    public List<BindMessage> selectFollowList() {
        Long user = getUser();
        Example example = new Example(BindMessage.class);
        example.createCriteria()
                .andEqualTo("fromId", user)
                .andEqualTo("type", MessageType.FOLLOW.getValue());
        log.info("FollowList : {}", user);
        return bindMessageMapper.selectByExample(example);
    }

    @Override
    public void deleteFollow(Long username) {
        Example example = new Example(BindMessage.class);
        example.createCriteria()
                .andEqualTo("fromId", getUser())
                .andEqualTo("toId", username)
                .andEqualTo("type", MessageType.FOLLOW.getValue());
        bindMessageMapper.deleteByExample(example);
        log.info("deleteFollow : {}", username);

    }


    @Override
    public void follow(Long username) {
        Long user = getUser();
        Example example = new Example(BindMessage.class);
        example.createCriteria()
                .andEqualTo("fromId", user)
                .andEqualTo("type", MessageType.FOLLOW.getValue());
        int count = bindMessageMapper.selectCountByExample(example);
        if (count > FOLLOW_MAX) {
            throw new CommonException("关注数量达到上限");
        }
        BindMessage bindMessage = new BindMessage();
        bindMessage.setMessageId(snowFlake.nextId());
        bindMessage.setCreateTime(LocalDateTime.now());
        bindMessage.setToId(username);
        bindMessage.setFromId(user);
        bindMessage.setType(MessageType.FOLLOW.getValue());
        bindMessage.setBody("关注了你");
        bindMessageMapper.insertSelective(bindMessage);
        // 发送消息
        String msg = null;
        try {
            msg = new ObjectMapper().writeValueAsString(bindMessage);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
            throw new CommonException("关注异常");
        }
        mqttGateway.sendToUser(msg, String.valueOf(username));
        log.info("follow : {}", msg);
    }

    @Override
    public List<BindMessage> historyMessage(Long username) {
        Example example = new Example(BindMessage.class);
        LocalDate localDateNow = LocalDate.now();
        String now = localDateNow.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        String historyDate = localDateNow.minusDays(3).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        example.createCriteria()
                .andEqualTo("fromId", getUser())
                .andEqualTo("toId", username)
                .andBetween("createTime", historyDate, now)
                .andIn("type",
                        Arrays.asList(MessageType.TEXT.getValue(),
                                MessageType.IMAGE.getValue(),
                                MessageType.VOICE.getValue(),
                                MessageType.VOIDE.getValue(),
                                MessageType.FILE.getValue())
                );
        example.orderBy("createTime");
        example.setOrderByClause("DESC");
        List<BindMessage> bindMessages = new LinkedList<>(bindMessageMapper.selectByExample(example));
        example = new Example(BindMessage.class);
        example.createCriteria()
                .andEqualTo("fromId", username)
                .andEqualTo("toId", getUser())
                .andBetween("createTime", historyDate, now)
                .andIn("type",
                        Arrays.asList(MessageType.TEXT.getValue(),
                                MessageType.IMAGE.getValue(),
                                MessageType.VOICE.getValue(),
                                MessageType.VOIDE.getValue(),
                                MessageType.FILE.getValue())
                );
        example.orderBy("createTime");
        example.setOrderByClause("DESC");
        bindMessages.addAll(bindMessageMapper.selectByExample(example));
        bindMessages.sort((o1, o2) -> {
            LocalDateTime createTime = o1.getCreateTime();
            return createTime.compareTo(o2.getCreateTime());
        });
        return bindMessages;
    }

    private Long getUser() {
        String name = SecurityContextHolder.getContext().getAuthentication().getName();
        return Long.valueOf(name);
    }
}
