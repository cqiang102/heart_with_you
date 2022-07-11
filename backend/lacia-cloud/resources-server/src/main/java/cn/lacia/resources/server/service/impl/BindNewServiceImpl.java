package cn.lacia.resources.server.service.impl;

import cn.lacia.common.exception.CommonException;
import cn.lacia.common.model.BindUser;
import cn.lacia.common.model.Result;
import cn.lacia.resources.server.mapper.BindCommentMapper;
import cn.lacia.resources.server.mapper.BindUserMapper;
import cn.lacia.resources.server.model.BindComment;
import cn.lacia.resources.server.model.BindNew;
import cn.lacia.resources.server.model.BindNewDto;
import cn.lacia.resources.server.service.BindNewService;
import cn.lacia.resources.server.mapper.BindNewMapper;
import cn.lacia.resources.server.util.SnowFlake;
import com.google.common.collect.Maps;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.session.RowBounds;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import tk.mybatis.mapper.entity.Example;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * @author lacia
 * @date 2022/4/22 - 12:34
 */
@Service
@Transactional(rollbackFor = Exception.class)
@Slf4j
public class BindNewServiceImpl implements BindNewService {

    private static final Integer LIMIT_MAX = 50;
    private final BindNewMapper bindNewMapper;
    private final BindUserMapper bindUserMapper;
    private final BindCommentMapper bindCommentMapper;
    private final SnowFlake snowFlake;

    public BindNewServiceImpl(BindNewMapper bindNewMapper, BindUserMapper bindUserMapper,
                              BindCommentMapper bindCommentMapper, SnowFlake snowFlake) {
        this.bindNewMapper = bindNewMapper;
        this.bindUserMapper = bindUserMapper;
        this.bindCommentMapper = bindCommentMapper;
        this.snowFlake = snowFlake;
    }

    @Override
    public void updateView(Long newId, Integer view) {
        BindNew bindNew = new BindNew();
        bindNew.setNewId(newId);
        bindNew.setNewId(getUser());
        bindNew.setView(view);
        Example example = new Example(BindNew.class);
        example.createCriteria()
                .andEqualTo("new_id", bindNew.getNewId())
                .andEqualTo("user_id", getUser());
        int i = bindNewMapper.updateByExampleSelective(bindNew, example);
        log.info("update view : user : {} , new : {} , view : {}", getUser(), newId, view);
        if (i != 1) {
            throw new CommonException("设置失败");
        }
    }

    @Override
    public BindNew getNewById(Long newId) {
        log.info("select new : newId : {}", newId);
        return bindNewMapper.selectByPrimaryKey(newId);
    }

    @Override
    public Result getNewPage(Integer limit, Integer offset, String search) {
        if (LIMIT_MAX < limit) {
            throw new CommonException("分页参数错误");
        }
        int count = bindNewMapper.selectCount(new BindNew(null, null, null,
                null, null, null, null,
                null, null, 0));
        if (offset > count) {
            throw new CommonException("分页参数错误");
        }
        Example example = new Example(BindNew.class);
        Example.Criteria criteria = example.createCriteria();
        if (StringUtils.hasText(search)) {
            criteria.andCondition("MATCH (body) AGAINST ('"+search+"')");
        }
        // 可见范围
        criteria.andEqualTo("view", 0);
        example.orderBy("createTime").desc();

        List<BindNew> bindNews = bindNewMapper.selectByExampleAndRowBounds(example, new RowBounds(offset, limit));
        if (bindNews.isEmpty()) {
            return Result.builder().code("200").message("查询成功").build();
        }
        List<Long> newIdList = bindNews.stream().map(BindNew::getNewId).collect(Collectors.toList());
        Example commentExample = new Example(BindComment.class);
        //  获取点赞收藏信息
        commentExample.createCriteria()
                .andEqualTo("userId", getUser())
                .andIn("body", newIdList);
        List<BindComment> bindComments = bindCommentMapper.selectByExample(commentExample);
        List<BindNewDto> bindNewDtoList;
        List<Long> usernames = bindNews.stream().map(BindNew::getUserId).collect(Collectors.toList());
        Example userExample = new Example(BindUser.class);
        userExample.createCriteria().andIn("username", usernames);
        List<BindUser> bindUsers = bindUserMapper.selectByExample(userExample);

        bindNewDtoList = bindNews.stream().map((bindNew -> {
            BindNewDto dto = BindNewDto.getByBindNew(bindNew);
            //  设置点赞收藏信息
            bindComments.stream().filter(c -> Objects.equals(c.getBody(), String.valueOf(dto.getNewId()))).forEach(c -> {
                if (c.getPid() == 1) {
                    dto.setIfUp(1);
                }
                if (c.getPid() == 2) {
                    dto.setIfStar(1);
                }
            });
            // 获取用户名
            Optional<String> user = bindUsers.stream()
                    .filter(u -> Objects.equals(u.getUsername(), dto.getUserId()))
                    .findFirst().map(BindUser::getNickname);
            user.ifPresent(dto::setNickname);
            return dto;
        })).collect(Collectors.toList());
        HashMap<String, Object> map = Maps.newHashMap();
        map.put("count", count);
        map.put("news", bindNewDtoList);
        log.info("get new page : {}/{} ,count : {},data : {}", limit, offset, count, bindNewDtoList);
        return Result.builder().code("200").message("查询成功")
                .data(map).build();
    }

    @Override
    public void saveNew(BindNew bindNew) {
        bindNew.setCreateTime(LocalDateTime.now());
        bindNew.setStarCount(0);
        bindNew.setUpCount(0);
        bindNew.setCommentCount(0);
        bindNew.setUserId(getUser());
        bindNew.setNewId(snowFlake.nextId());
        int i = bindNewMapper.insertSelective(bindNew);
        log.info("save new : {}", bindNew);
        if (i != 1) {
            throw new CommonException("保存失败");
        }
    }

    @Override
    public void updateOperator(Long newId, Long operator, boolean flag) {
        //  新增点赞记录
        BindComment bindComment = new BindComment();
        bindComment.setUserId(getUser());
        bindComment.setPid(operator);
        bindComment.setBody(String.valueOf(newId));
        if (flag) {
            bindComment.setCommentId(snowFlake.nextId());
            bindComment.setCreateTime(LocalDateTime.now());
            bindCommentMapper.insert(bindComment);
        } else {
            bindCommentMapper.delete(bindComment);
        }
        // 数据加一
        BindNew bindNew = bindNewMapper.selectByPrimaryKey(newId);
        if (operator == 1) {
            if (flag) {
                bindNew.setUpCount(bindNew.getUpCount() + 1);
            } else if (bindNew.getUpCount() > 0) {
                bindNew.setUpCount(bindNew.getUpCount() - 1);
            }
        } else if (operator == 2) {
            if (flag) {
                bindNew.setStarCount(bindNew.getStarCount() + 1);
            } else if (bindNew.getStarCount() > 0) {
                bindNew.setStarCount(bindNew.getStarCount() - 1);
            }
        } else {
            throw new CommonException("非法操作");
        }
        bindNewMapper.updateByPrimaryKeySelective(bindNew);
    }

    @Override
    public Result selectByUsername(Long username) {

        Example example = new Example(BindNew.class);
        Example.Criteria criteria = example.createCriteria();

        // 可见范围
        criteria.andEqualTo("view", 0);
        criteria.andEqualTo("userId", username);
        example.orderBy("createTime").desc();

        List<BindNew> bindNews = bindNewMapper.selectByExample(example);
        if (bindNews.isEmpty()) {
            return Result.builder().code("200").message("查询成功").build();
        }
        List<Long> newIdList = bindNews.stream().map(BindNew::getNewId).collect(Collectors.toList());
        Example commentExample = new Example(BindComment.class);
        //  获取点赞收藏信息
        commentExample.createCriteria()
                .andEqualTo("userId", getUser())
                .andIn("body", newIdList);
        List<BindComment> bindComments = bindCommentMapper.selectByExample(commentExample);
        List<BindNewDto> bindNewDtoList;
//        List<Long> usernames = bindNews.stream().map(BindNew::getUserId).collect(Collectors.toList());
//        Example userExample = new Example(BindUser.class);
//        userExample.createCriteria().andIn("username", usernames);
//        List<BindUser> bindUsers = bindUserMapper.selectByExample(userExample);

        bindNewDtoList = bindNews.stream().map((bindNew -> {
            BindNewDto dto = BindNewDto.getByBindNew(bindNew);
            //  设置点赞收藏信息
            bindComments.stream().filter(c -> Objects.equals(c.getBody(), String.valueOf(dto.getNewId()))).forEach(c -> {
                if (c.getPid() == 1) {
                    dto.setIfUp(1);
                }
                if (c.getPid() == 2) {
                    dto.setIfStar(1);
                }
            });
//            // 获取用户名
//            Optional<String> user = bindUsers.stream()
//                    .filter(u -> Objects.equals(u.getUsername(), dto.getUserId()))
//                    .findFirst().map(BindUser::getNickname);
//            user.ifPresent(dto::setNickname);
            return dto;
        })).collect(Collectors.toList());

        log.info("get new list : ,data : {}", bindNewDtoList);
        return Result.builder().code("200").message("查询成功")
                .data(bindNewDtoList).build();
    }

    @Override
    public Result getStarList() {
        BindComment bindComment = new BindComment();
        bindComment.setPid(2L);
        bindComment.setUserId(getUser());
        List<BindComment> select = bindCommentMapper.select(bindComment);
        List<Long> collect = select.stream().map((c) -> Long.parseLong(c.getBody())).collect(Collectors.toList());
        if(select.isEmpty()){
            throw  new CommonException("没有收藏");
        }
        Example example = new Example(BindNew.class);
        example.createCriteria().andIn("newId",collect);
        List<BindNew> bindNews = bindNewMapper.selectByExample(example);

        if (bindNews.isEmpty()) {
            return Result.builder().code("200").message("查询成功").build();
        }
        List<Long> newIdList = bindNews.stream().map(BindNew::getNewId).collect(Collectors.toList());
        Example commentExample = new Example(BindComment.class);
        //  获取点赞信息
        commentExample.createCriteria()
                .andEqualTo("userId", getUser())
                .andEqualTo("pid",1)
                .andIn("body", newIdList);
        List<BindComment> bindComments = bindCommentMapper.selectByExample(commentExample);
        List<BindNewDto> bindNewDtoList;
        List<Long> usernames = bindNews.stream().map(BindNew::getUserId).collect(Collectors.toList());
        Example userExample = new Example(BindUser.class);
        userExample.createCriteria().andIn("username", usernames);
        List<BindUser> bindUsers = bindUserMapper.selectByExample(userExample);
        bindNewDtoList = bindNews.stream().map((bindNew -> {
            BindNewDto dto = BindNewDto.getByBindNew(bindNew);
            //  设置点赞收藏信息
            bindComments.stream().filter(c -> Objects.equals(c.getBody(), String.valueOf(dto.getNewId()))).forEach(c -> {
                if (c.getPid() == 1) {
                    dto.setIfUp(1);
                }
                dto.setIfStar(1);
            });
            // 获取用户名
            Optional<String> user = bindUsers.stream()
                    .filter(u -> Objects.equals(u.getUsername(), dto.getUserId()))
                    .findFirst().map(BindUser::getNickname);
            user.ifPresent(dto::setNickname);
            return dto;
        })).collect(Collectors.toList());
        return Result.builder().code("200").data(bindNewDtoList).message("ok").build();
    }

    private Long getUser() {
        String name = SecurityContextHolder.getContext().getAuthentication().getName();
        return Long.valueOf(name);
    }
}
