package cn.lacia.resources.server.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.format.annotation.DateTimeFormat;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.validation.constraints.NotNull;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
@date 2022/4/22 - 12:34
@author    lacia
*/
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "lacia_app.bind_new")
public class BindNewDto implements Serializable {
    public static BindNewDto getByBindNew(BindNew bindNew){
        BindNewDto bindNewDto = new BindNewDto();
        BeanUtils.copyProperties(bindNew,bindNewDto);
        return bindNewDto;
    }
    /**
     * 主键
     */
    @JsonProperty("new_id")
    private Long newId;

    /**
     * 文字内容
     */
    private String body;

    /**
     * 图片列表
     */
    private String images;

    /**
     * 发布时间
     */
    @JsonProperty("create_time")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @JsonDeserialize(using = LocalDateTimeDeserializer.class)
    @JsonSerialize(using = LocalDateTimeSerializer.class)
    private LocalDateTime createTime;

    /**
     * 收藏数
     */
    @JsonProperty("star_count")
    private Integer starCount;

    /**
     * 点赞数
     */
    @JsonProperty("up_count")
    private Integer upCount;

    /**
     * 评论数
     */
    @JsonProperty("comment_count")
    private Integer commentCount;

    /**
     * 关联用户id
     */
    @JsonProperty("user_id")
    private Long userId;
    /**
     * 关联用户id
     */
    @JsonProperty("nickname")
    private String nickname;
    /**
     * 标签
     */
    @Column(name = "tags")
    private String tags;

    /**
     * 0 所有人可见
     * 1 自己可见
     */
    private Integer view;

    /**
     * 0 未点
     * 1 点了
     */
    private  Integer ifUp;

    private  Integer ifStar;

    private static final long serialVersionUID = 211521900364539741L;
}
