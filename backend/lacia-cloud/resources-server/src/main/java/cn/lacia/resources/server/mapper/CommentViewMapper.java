package cn.lacia.resources.server.mapper;

import cn.lacia.resources.server.model.CommentView;
import org.apache.ibatis.annotations.Mapper;
import tk.mybatis.MyMapper;

/**
@date 2022/4/22 - 12:52
@author    lacia
*/
@Mapper
public interface CommentViewMapper extends MyMapper<CommentView> {
}