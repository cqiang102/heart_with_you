package cn.lacia.resources.server.controller;

import cn.lacia.common.model.Result;
import cn.lacia.resources.server.model.BindNew;
import cn.lacia.resources.server.service.BindNewService;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.Mapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author lacia
 * @date 2022/4/23 - 23:05
 */
@RestController
@RequestMapping("new")
public class NewController {
    private  final BindNewService bindNewService;
    private final StringRedisTemplate redisTemplate;

    public NewController(BindNewService bindNewService, StringRedisTemplate redisTemplate) {
        this.bindNewService = bindNewService;
        this.redisTemplate = redisTemplate;
    }

    @PostMapping
    public Result news(@RequestBody BindNew bindNew){
        bindNewService.saveNew(bindNew);
        return Result.builder().code("200").message("保存成功").build();
    }
    @GetMapping("/user/{username}")
    public Result newsList(@PathVariable("username") Long username){
        return bindNewService.selectByUsername(username);
    }
    @GetMapping("page/{limit}/{offset}")
    public Result listPage(
            @PathVariable("limit")Integer limit,
            @PathVariable("offset")Integer offset,@RequestParam("search") String search){
        return bindNewService.getNewPage(limit,offset,search);
    }

    @GetMapping("{newId}")
    public Result newItem(@PathVariable("newId")Long newId){
        return Result.builder().code("200").message("查询成功")
                .data(bindNewService.getNewById(newId))
                .build();
    }

    /**
     * 点赞或者收藏
     * @param newId
     * @param status
     * @return
     */
    @PutMapping("operator/{newId}/{status}")
    public Result addOperator(@PathVariable("newId")Long newId,@PathVariable("status")Long status){
        bindNewService.updateOperator(newId,status,true);
        return Result.builder().code("200").message("操作成功")
                .build();
    }

    @GetMapping("star")
    public Result getStarList(){
        return  bindNewService.getStarList();
    }

    /**
     * 取消 点赞或者收藏
     * @param newId
     * @param status
     * @return
     */
    @DeleteMapping("operator/{newId}/{status}")
    public Result delOperator(@PathVariable("newId")Long newId,@PathVariable("status")Long status){
        bindNewService.updateOperator(newId,status,false);
        return Result.builder().code("200").message("操作成功")
                .build();
    }
    @PutMapping("{newId}/{view}")
    public Result updateItem(@PathVariable("newId")Long newId,
                             @PathVariable("view") Integer view){
        bindNewService.updateView(newId,view);
        return Result.builder().code("200").message("设置成功").build();
    }
}
