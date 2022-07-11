package cn.lacia.resources.server.controller;

import cn.lacia.common.model.Result;
import com.google.common.collect.Maps;
import org.springframework.data.geo.Circle;
import org.springframework.data.geo.Distance;
import org.springframework.data.geo.GeoResult;
import org.springframework.data.geo.GeoResults;
import org.springframework.data.geo.Metrics;
import org.springframework.data.geo.Point;
import org.springframework.data.redis.connection.RedisGeoCommands;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Objects;
import java.util.Optional;

/**
 * @author lacia
 * @date 2022/4/24 - 15:42
 */
@RestController
@RequestMapping("map")
public class AddressController {
    private final StringRedisTemplate stringRedisTemplate;

    public AddressController(StringRedisTemplate stringRedisTemplate) {
        this.stringRedisTemplate = stringRedisTemplate;
    }

//    @PostMapping
//    public Result updateAddress(@RequestParam("city")String city, @RequestParam("longitude") double longitude,@RequestParam("latitude") double latitude) {
//        String name = SecurityContextHolder.getContext().getAuthentication().getName();
//        Long remove = stringRedisTemplate.opsForGeo().remove(city, name);
//        Long add = stringRedisTemplate.opsForGeo().add(city, new Point(longitude, latitude), name);
//        return Result.builder().code("200").message("上传成功")
//                .data(add)
//                .build();
//    }

    @PostMapping
    public Result getNearbyUser(@RequestParam("city")String city, @RequestParam("longitude") double longitude,@RequestParam("latitude") double latitude) {
        Result.ResultBuilder builder = Result.builder();
        builder.code("200");
        builder.message("附近空无一人");
        String name = SecurityContextHolder.getContext().getAuthentication().getName();
        Long remove = stringRedisTemplate.opsForGeo().remove(city, name);
        Long add = stringRedisTemplate.opsForGeo().add(city, new Point(longitude, latitude), name);

        Circle circle = new Circle(new Point(longitude, latitude), new Distance(100, Metrics.KILOMETERS));
        GeoResults<RedisGeoCommands.GeoLocation<String>> radius = stringRedisTemplate.opsForGeo().radius(
                city,
                circle,
                RedisGeoCommands.GeoRadiusCommandArgs.newGeoRadiusArgs().sortAscending().includeDistance()
        );
        if(radius != null && ! radius.getContent().isEmpty()){
            Optional<GeoResult<RedisGeoCommands.GeoLocation<String>>> first = radius.getContent().stream()
                    .filter(
                    temp -> !Objects.equals(name,temp.getContent().getName())
            ).findFirst();
            if (first.isPresent()){
                GeoResult<RedisGeoCommands.GeoLocation<String>> geoLocationGeoResult = first.get();
                builder.message("匹配成功");

                String searchName = geoLocationGeoResult.getContent().getName();
                Distance distance = geoLocationGeoResult.getDistance();
                HashMap<String, Object> map = Maps.newHashMap();
                map.put("user",searchName);
                map.put("distance",distance.getValue());
                map.put("unit",distance.getUnit());
                builder.data(map);
            }
        }
        return builder.build();
    }
}
