package cn.lacia.resources.server.model;

import lombok.Getter;

/**
 * @author lacia
 * @date 2022/4/23 - 12:43
 */
@Getter
public enum MessageType {
    /**
     * 文字消息
     */
    TEXT(0),
    /**
     * 图片消息
     */
    IMAGE(1),
    /**
     * 语音消息
     */
    VOICE(2),
    /**
     * 视频消息
     */
    VOIDE(3),
    /**
     * 文件消息
     */
    FILE(4),
    /**
     * 关注消息
     */
    FOLLOW(5),
    /**
     * 被关注
     */
    FOLLOWED(6);

    /**
     * 数据库状态
     */
    final int value;

    MessageType(int value){
        this.value=value;
    }
}
