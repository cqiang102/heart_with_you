package cn.lacia.common.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * @author lacia
 * @date 2022/4/17 - 19:43
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Result {
    private String code;
    private String message;
    private Object data;
}
