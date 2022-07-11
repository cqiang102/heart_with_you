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
@Table(name = "lacia_app.bind_message")
public class BindMessage implements Serializable {
    @Id
    @Column(name = "message_id")
    @JsonProperty("message_id")
    private Long messageId;

    /**
     * 发送用户 id
     */
    @NotNull(message = "发送用户不能为空")
    @JsonProperty("from_id")
    @Column(name = "from_id")
    private Long fromId;

    /**
     * 接收用户 id
     */
    @Column(name = "to_id")
    @JsonProperty("to_id")
    @NotNull(message = "接收用户不能为空")
    private Long toId;

    /**
     * 类型 0 文字 1 图片 2 语音 3 视频 4 文件 5 关注 6 被关注
     */
    @Column(name = "`type`")
    @NotNull(message = "类型不能为空")
    private Integer type;

    /**
     * 消息主题
     */
    @Column(name = "body")
    @NotNull(message = "内容不能为空")
    private String body;

    /**
     * 发送时间
     */
    @Column(name = "create_time")
    @JsonProperty("create_time")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @JsonDeserialize(using = LocalDateTimeDeserializer.class)
    @JsonSerialize(using = LocalDateTimeSerializer.class)
    private LocalDateTime createTime;

    private static final long serialVersionUID = -890384164743632513L;
}
