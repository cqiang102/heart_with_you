package cn.lacia.resources.server.service;

import cn.lacia.resources.server.model.BindMessage;

import java.util.List;

/**
@date 2022/4/22 - 12:34
@author    lacia
*/
public interface BindMessageService{

    BindMessage saveMessage(BindMessage bindMessage);


    boolean selectFollowStatus(Long username);

    List<BindMessage> selectFollowList();

    void deleteFollow(Long username);

    void follow(Long username);

    List<BindMessage> historyMessage(Long username);
}
