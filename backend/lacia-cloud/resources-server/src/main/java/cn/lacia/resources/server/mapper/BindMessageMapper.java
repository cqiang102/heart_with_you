package cn.lacia.resources.server.mapper;

import cn.lacia.resources.server.model.BindMessage;
import org.apache.ibatis.annotations.Mapper;
import tk.mybatis.MyMapper;

/**
@date 2022/4/22 - 12:34
@author    lacia
*/
@Mapper
public interface BindMessageMapper extends MyMapper<BindMessage> {
}