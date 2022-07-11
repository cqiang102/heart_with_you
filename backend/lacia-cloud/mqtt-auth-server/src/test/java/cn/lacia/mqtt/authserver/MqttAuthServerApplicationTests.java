package cn.lacia.mqtt.authserver;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
//@WebMvcTest(AuthBackendHttpController.class)
class MqttAuthServerApplicationTests {

//    @Autowired
//    private MockMvc mvc;
//
//    @Test
//    public void authenticationAuthorisation() throws Exception {
//        this.mvc.perform(get("/auth/user").param("username", "guest").param("password", "guest"))
//                .andExpect(status().isOk()).andExpect(content().string("allow administrator management"));
//
//        this.mvc.perform(get("/auth/user").param("username", "guest").param("password", "wrong"))
//                .andExpect(status().isOk()).andExpect(content().string("deny"));
//
//        this.mvc.perform(get("/auth/vhost").param("username", "guest").param("vhost", "/"))
//                .andExpect(status().isOk()).andExpect(content().string("allow"));
//
//        this.mvc.perform(get("/auth/resource")
//                .param("username", "guest")
//                .param("vhost", "/")
//                .param("resource", "exchange")
//                .param("name", "amq.topic")
//                .param("permission", "write"))
//                .andExpect(status().isOk()).andExpect(content().string("allow"));
//
//        this.mvc.perform(get("/auth/topic")
//                .param("username", "guest")
//                .param("vhost", "/")
//                .param("resource", "exchange")
//                .param("name", "amq.topic")
//                .param("permission", "write")
//                .param("routing_key", "a.b"))
//                .andExpect(status().isOk()).andExpect(content().string("allow"));
//
//        this.mvc.perform(get("/auth/topic")
//                .param("username", "guest")
//                .param("vhost", "/")
//                .param("resource", "exchange")
//                .param("name", "amq.topic")
//                .param("permission", "write")
//                .param("routing_key", "b.b"))
//                .andExpect(status().isOk()).andExpect(content().string("deny"));
//    }
}
