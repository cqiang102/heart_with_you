package cn.lacia.mqtt.authserver;

/**
 * @author lacia
 * @date 2022/4/13 - 22:28
 */
public class TopicCheck extends ResourceCheck {

    private String routing_key;

    public String getRouting_key() {
        return routing_key;
    }

    public void setRouting_key(String routing_key) {
        this.routing_key = routing_key;
    }

    @Override
    public String toString() {
        return "TopicCheck{" +
                "routing_key='" + routing_key + '\'' +
                "} " + super.toString();
    }
}
