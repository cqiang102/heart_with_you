package cn.lacia.resources.server.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import javax.persistence.*;
import javax.validation.constraints.NotNull;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;

/**
@date 2022/4/22 - 12:34
@author    lacia
*/
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "lacia_app.bind_new")
public class BindNew implements Serializable {
    /**
     * 主键
     */
    @Id
    @Column(name = "new_id")
    @JsonProperty("new_id")
    private Long newId;

    /**
     * 文字内容
     */
    @Column(name = "body")
    @NotNull(message = "内容不能为空")
    private String body;

    /**
     * 图片列表
     */
    @Column(name = "images")
    @NotNull(message = "图片不能为空")
    private String images;

    /**
     * 发布时间
     */
    @Column(name = "create_time")
    @JsonProperty("create_time")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @JsonDeserialize(using = LocalDateTimeDeserializer.class)
    @JsonSerialize(using = LocalDateTimeSerializer.class)
    private LocalDateTime createTime;

    /**
     * 收藏数
     */
    @Column(name = "star_count")
    @JsonProperty("star_count")
    private Integer starCount;

    /**
     * 点赞数
     */
    @Column(name = "up_count")
    @JsonProperty("up_count")
    private Integer upCount;

    /**
     * 评论数
     */
    @Column(name = "comment_count")
    @JsonProperty("comment_count")
    private Integer commentCount;

    /**
     * 关联用户id
     */
    @Column(name = "user_id")
    @JsonProperty("user_id")
    private Long userId;

    /**
     * 标签
     */
    @Column(name = "tags")
    private String tags;

    /**
     * 0 所有人可见
     * 1 自己可见
     */
    @Column(name = "view")
    @NotNull(message = "是否可见不能为空")
    private Integer view;

    private static final long serialVersionUID = -8049692722829430060L;
}
