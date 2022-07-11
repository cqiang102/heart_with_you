package cn.lacia.resources.server.service;

import cn.lacia.common.model.Result;

/**
@date 2022/4/22 - 12:52
@author    lacia
*/
public interface BindCommentService{


        Result save(Long newId, String body);


    Result delete(Long newId);
}
