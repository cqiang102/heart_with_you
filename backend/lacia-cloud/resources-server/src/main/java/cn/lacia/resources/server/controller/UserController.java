package cn.lacia.resources.server.controller;

import cn.lacia.common.model.Result;
import cn.lacia.resources.server.model.UpdateUserVo;
import cn.lacia.resources.server.service.BindUserService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.sql.ResultSet;

/**
 * @author lacia
 * @date 2022/4/22 - 22:27
 */
@RestController
@RequestMapping("user")
public class UserController {
    private final BindUserService bindUserService;

    public UserController(BindUserService bindUserService) {
        this.bindUserService = bindUserService;
    }

    /**
     * 更新昵称 邮箱 密码
     * @return
     */
    @PostMapping
    public Result updateUser(@Validated  @RequestBody UpdateUserVo updateUserVo){
        bindUserService.updateUser(updateUserVo);
        return Result.builder().code("200").message("ok").build();
    }
    /**
     * 获取用户资料
     * @param username
     * @return
     */
    @GetMapping("{username}")
    public Result userprofile(@PathVariable("username" )Long username){
        return Result.builder().code("200").message("查询成功").data(bindUserService.selectByUsername(username)).build();
    }

    @GetMapping("follow")
    public Result getFollowUser(){
     return bindUserService.getFollowUser();
    }
    @GetMapping("followed")
    public Result getFollowedUser(){
        return bindUserService.getFollowedUser();
    }
    @GetMapping("friends")
    public Result getFriends(){
        return bindUserService.getFriends();
    }
    /**
     * 修改背景
     * @return
     */
    @PutMapping
    public Result saveBackground(@RequestParam("image")String image){
        return bindUserService.saveBackground(image);
    }



}
