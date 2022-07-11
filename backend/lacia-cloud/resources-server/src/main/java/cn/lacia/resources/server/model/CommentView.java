package cn.lacia.resources.server.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import javax.persistence.*;

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
@date 2022/4/22 - 12:52
@author    lacia
*/
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "lacia_app.comment_view")
public class CommentView implements Serializable {
    @Column(name = "comment_id")
    @JsonProperty("comment_id")
    private Long commentId;

    @Column(name = "user_id")
    @JsonProperty("user_id")
    private Long userId;

    @Column(name = "pid")
    private Long pid;

    @Column(name = "body")
    private String body;

    @Column(name = "create_time")
    @JsonProperty("create_time")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @JsonDeserialize(using = LocalDateTimeDeserializer.class)
    @JsonSerialize(using = LocalDateTimeSerializer.class)
    private LocalDateTime createTime;

    @Column(name = "username")
    private Long username;

    @Column(name = "nickname")
    private String nickname;

    private static final long serialVersionUID = 1L;
}
