package cn.lacia.resources.server.service.impl;

import cn.lacia.common.model.Result;
import cn.lacia.resources.server.model.BindComment;
import cn.lacia.resources.server.model.CommentView;
import cn.lacia.resources.server.service.CommentViewService;
import cn.lacia.resources.server.mapper.CommentViewMapper;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;

/**
@date 2022/4/22 - 12:52
@author    lacia
*/
@Service
public class CommentViewServiceImpl implements CommentViewService{

    private final CommentViewMapper commentViewMapper;

    public CommentViewServiceImpl(CommentViewMapper commentViewMapper) {
        this.commentViewMapper = commentViewMapper;
    }
    @Override
    public Result selectListByNewId(Long newId) {
        CommentView bindCommentView = new CommentView();
        bindCommentView.setPid(newId);
        List<CommentView> select = commentViewMapper.select(bindCommentView);
        Collections.reverse(select);
        return Result.builder().code("200").message("查询成功").data(select).build();
    }
}
