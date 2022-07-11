package cn.lacia.resources.server.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * @author: root
 * @date: 2021/11/18 20:23
 */
@Data
@Component
@ConfigurationProperties(prefix = "mqtt")
public class MqttProperties {

    private String host;

    private String clientInId;

    private String clientOutId;
    private String topic;
    private int qosLevel;
    private String username;
    private String password;
    private int timeout;
    private int keepalive;
}
