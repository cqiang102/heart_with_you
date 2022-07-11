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
@ConfigurationProperties(prefix = "minio")
public class MinioProperties {

    private String endpoint;

    private String accessKey;

    private String secretKey;

    private String bucketName;
}
