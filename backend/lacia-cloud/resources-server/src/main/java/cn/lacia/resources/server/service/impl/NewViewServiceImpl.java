package cn.lacia.resources.server.service.impl;

import cn.lacia.resources.server.service.NewViewService;
import cn.lacia.resources.server.mapper.NewViewMapper;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;

/**
@date 2022/4/22 - 12:53
@author    lacia
*/
@Service
public class NewViewServiceImpl implements NewViewService{

    @Resource
    private NewViewMapper newViewMapper;

}
