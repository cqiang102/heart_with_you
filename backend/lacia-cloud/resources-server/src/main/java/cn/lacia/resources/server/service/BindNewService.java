package cn.lacia.resources.server.service;

import cn.lacia.common.model.Result;
import cn.lacia.resources.server.model.BindNew;

/**
@date 2022/4/22 - 12:34
@author    lacia
*/
public interface BindNewService{


        void updateView(Long newId, Integer view);

        BindNew getNewById(Long newId);

    Result getNewPage(Integer limit, Integer offset,String search);

    void saveNew(BindNew bindNew);

    void updateOperator(Long newId,Long operator,boolean flag);

    Result selectByUsername(Long username);

    Result getStarList();

}
