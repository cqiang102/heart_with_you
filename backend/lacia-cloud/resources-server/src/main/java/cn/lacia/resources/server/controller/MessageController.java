package cn.lacia.resources.server.controller;

import cn.lacia.common.exception.CommonException;
import cn.lacia.common.model.Result;
import cn.lacia.resources.server.config.MqttConfig;
import cn.lacia.resources.server.model.BindMessage;
import cn.lacia.resources.server.service.BindMessageService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;

/**
 * @author lacia
 * @date 2022/4/22 - 10:14
 */
@RestController
@RequestMapping("msg")
@Slf4j
public class MessageController {
    private final BindMessageService messageService;

    public MessageController(BindMessageService messageService) {
        this.messageService = messageService;
    }

    /**
     * 发送消息
     * @param bindMessage
     * @return
     * @throws JsonProcessingException
     */
    @PostMapping
    public Result sendMessage(@RequestBody @Validated BindMessage bindMessage) throws JsonProcessingException {
        messageService.saveMessage(bindMessage);
        return Result.builder().code("200").message("发送成功").build();
    }

    /**
     * 获取历史消息
     * 最近三天
     */
    @GetMapping("{username}")
    public Result historyMessage(@PathVariable("username") Long username){
        return Result.builder().code("200").message("查询成功")
                .data(messageService.historyMessage(username)).build();
    }
    /**
     * 关注
     * 新增关注消息
     * 限制最大关注数量
     */
    @PostMapping("follow/{username}")
    public Result followUser(@PathVariable("username") Long username){
        messageService.follow(username);
        return Result.builder().code("200").message("关注成功").build();
    }
    /**
     * 取消关注
     * 删除关注关系
     *  last  发送取消消息
     */
    @DeleteMapping("follow/{username}")
    public Result unFollowUser(@PathVariable("username") Long username){
        messageService.deleteFollow(username);
        return Result.builder().code("200").message("取消成功").build();
    }
    /**
     * 查询自己的关注
     */
    @GetMapping("follow")
    public Result myFollow(){
        return Result.builder()
                .code("200")
                .message("查询成功")
                .data(messageService.selectFollowList())
                .build();
    }
    /**
     * 查询是否关注
     */
    @GetMapping("follow/{username}")
    public Result followStatus(@PathVariable("username") Long username){

        return Result.builder()
                .code("200")
                .message("查询成功")
                .data(messageService.selectFollowStatus(username))
                .build();
    }

}
