package cn.lacia.resources.server.service;

import cn.lacia.common.model.BindUser;
import cn.lacia.common.model.Result;
import cn.lacia.resources.server.model.UpdateUserVo;

/**
@date 2022/4/17 - 14:27
@author    lacia
*/
public interface BindUserService {


    BindUser selectByUsername(Long username);

    Result saveBackground(String image);

    Result getFollowUser();

    Result getFollowedUser();

    Result getFriends();

    void updateUser(UpdateUserVo updateUserVo);
}
