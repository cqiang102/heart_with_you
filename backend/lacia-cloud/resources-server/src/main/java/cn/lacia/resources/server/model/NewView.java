package cn.lacia.resources.server.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import javax.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
@date 2022/4/22 - 12:53
@author    lacia
*/
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "lacia_app.new_view")
public class NewView implements Serializable {
    @Column(name = "new_id")
    private Long newId;

    @Column(name = "body")
    private String body;

    @Column(name = "images")
    private String images;

    @Column(name = "create_time")
    private LocalDateTime createTime;

    @Column(name = "star_count")
    private Integer starCount;

    @Column(name = "up_count")
    private Integer upCount;

    @Column(name = "comment_count")
    private Integer commentCount;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "tags")
    private String tags;

    @Column(name = "username")
    private Long username;

    @Column(name = "nickname")
    private String nickname;

    private static final long serialVersionUID = 1L;
}