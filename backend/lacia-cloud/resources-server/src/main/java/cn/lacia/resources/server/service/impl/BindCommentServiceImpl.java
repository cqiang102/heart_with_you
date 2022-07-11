package cn.lacia.resources.server.service.impl;

import cn.lacia.common.model.Result;
import cn.lacia.resources.server.mapper.BindNewMapper;
import cn.lacia.resources.server.model.BindComment;
import cn.lacia.resources.server.model.BindNew;
import cn.lacia.resources.server.service.BindCommentService;
import cn.lacia.resources.server.mapper.BindCommentMapper;
import cn.lacia.resources.server.util.SnowFlake;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
@date 2022/4/22 - 12:52
@author    lacia
*/
@Service
public class BindCommentServiceImpl implements BindCommentService{

    private final BindCommentMapper bindCommentMapper;
    private final BindNewMapper bindNewMapper;
    private final SnowFlake snowFlake;

    public BindCommentServiceImpl(BindCommentMapper bindCommentMapper, BindNewMapper bindNewMapper, SnowFlake snowFlake) {
        this.bindCommentMapper = bindCommentMapper;
        this.bindNewMapper = bindNewMapper;
        this.snowFlake = snowFlake;
    }

    @Override
    public Result save(Long newId, String body) {
        BindComment bindComment = new BindComment();
        bindComment.setCommentId(snowFlake.nextId());
        bindComment.setBody(body);
        bindComment.setPid(newId);
        bindComment.setCreateTime(LocalDateTime.now());
        bindComment.setUserId(getUser());
        bindCommentMapper.insertSelective(bindComment);
        BindNew bindNew = bindNewMapper.selectByPrimaryKey(newId);
        bindNew.setCommentCount(bindNew.getCommentCount()+1);
        bindNewMapper.updateByPrimaryKeySelective(bindNew);
        return Result.builder().code("200").message("评论成功").build();
    }



    @Override
    public Result delete(Long commentId) {
        bindCommentMapper.deleteByPrimaryKey(commentId);
        return Result.builder().code("200").message("删除成功").build();
    }
    private Long getUser() {
        String name = SecurityContextHolder.getContext().getAuthentication().getName();
        return Long.valueOf(name);
    }
}
