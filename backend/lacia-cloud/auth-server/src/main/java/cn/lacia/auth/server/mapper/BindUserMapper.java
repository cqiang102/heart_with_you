package cn.lacia.auth.server.mapper;

import cn.lacia.common.model.BindUser;
import org.apache.ibatis.annotations.Mapper;
import tk.mybatis.MyMapper;

/**
@date 2022/4/17 - 14:27
@author    lacia
*/
@Mapper
public interface BindUserMapper extends MyMapper<BindUser> {
}
