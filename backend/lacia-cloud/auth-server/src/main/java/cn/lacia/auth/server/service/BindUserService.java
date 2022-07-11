package cn.lacia.auth.server.service;

import cn.lacia.auth.server.model.RegisterUserVo;
import cn.lacia.common.model.Result;

/**
@date 2022/4/17 - 14:27
@author    lacia
*/
public interface BindUserService{


    /**
     * 注册
     * @return
     */
    Result register(RegisterUserVo registerUserVo);


}
