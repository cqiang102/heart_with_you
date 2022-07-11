package cn.lacia.resources.server.controller;

import cn.lacia.common.model.Result;
import cn.lacia.resources.server.service.BindCommentService;
import cn.lacia.resources.server.service.CommentViewService;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author lacia
 * @date 2022/5/4 - 23:19
 */
@RestController
@RequestMapping("comment")
public class CommentController {

    private final BindCommentService bindCommentService;
    private final CommentViewService commentViewService;

    public CommentController(BindCommentService bindCommentService, CommentViewService commentViewService) {
        this.bindCommentService = bindCommentService;
        this.commentViewService = commentViewService;
    }

    // 根据 new id 查询
    @GetMapping("{newId}")
    public Result getComments(@PathVariable("newId")Long newId){
        return commentViewService.selectListByNewId(newId);
    }
    // 新增
    @PostMapping("{newId}")
    public Result save(@PathVariable("newId")Long newId,@RequestParam("body") String body){
        return bindCommentService.save(newId,body);
    }
    // 删除
    @DeleteMapping("{newId}")
    public Result save(@PathVariable("newId")Long newId){
        return bindCommentService.delete(newId);
    }
}
