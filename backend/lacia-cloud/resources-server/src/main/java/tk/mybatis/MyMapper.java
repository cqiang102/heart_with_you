package tk.mybatis;

import tk.mybatis.mapper.common.Mapper;
import tk.mybatis.mapper.common.MySqlMapper;

/**
 * @author lacia
 * @date 2022/4/22 - 11:32
 */
public interface MyMapper<T> extends Mapper<T>, MySqlMapper<T> {
}
