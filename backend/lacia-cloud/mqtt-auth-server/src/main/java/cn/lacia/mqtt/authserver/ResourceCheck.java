package cn.lacia.mqtt.authserver;

/**
 * @author lacia
 * @date 2022/4/13 - 22:27
 */
public class ResourceCheck extends BaseCheck {

    private String resource, name, permission;

    public String getResource() {
        return resource;
    }

    public void setResource(String resource) {
        this.resource = resource;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPermission() {
        return permission;
    }

    public void setPermission(String permission) {
        this.permission = permission;
    }

    @Override
    public String toString() {
        return "ResourceCheck{" +
                "resource='" + resource + '\'' +
                ", name='" + name + '\'' +
                ", permission='" + permission + '\'' +
                "} " + super.toString();
    }
}
