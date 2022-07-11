package cn.lacia.resources.server.controller;

import cn.lacia.common.exception.CommonException;
import cn.lacia.common.model.Result;
import cn.lacia.resources.server.config.MinioProperties;
import cn.lacia.resources.server.util.SnowFlake;
import io.minio.GetObjectArgs;
import io.minio.GetObjectResponse;
import io.minio.GetObjectTagsArgs;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import io.minio.errors.ErrorResponseException;
import io.minio.errors.InsufficientDataException;
import io.minio.errors.InternalException;
import io.minio.errors.InvalidResponseException;
import io.minio.errors.ServerException;
import io.minio.errors.XmlParserException;
import io.minio.messages.Tags;
import lombok.extern.slf4j.Slf4j;
import okhttp3.Headers;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * @author lacia
 * @date 2022/4/22 - 13:02
 */
@Controller
@RequestMapping("file")
@Slf4j
public class FileController {


    public static final String FILE_DIRECT = "TimeLock/";
    public static final String ORIGINAL_FILENAME_TAG = "originalFilename";
    private final MinioClient minioClient;

    private final MinioProperties minioProperties;
    private final SnowFlake snowFlake;

    public FileController(MinioClient minioClient, MinioProperties minioProperties, SnowFlake snowFlake) {
        this.minioClient = minioClient;
        this.minioProperties = minioProperties;
        this.snowFlake = snowFlake;
    }

    /**
     * 上传文件
     *
     * @param files
     * @return
     */
    @PostMapping
    @ResponseBody
    public Result uploadFile(@RequestParam("file") MultipartFile[] files) {
        if (files == null || files.length == 0) {
            throw new CommonException("未选择文件");
        }
        List<String> uploadFilenames = new ArrayList<>(files.length);
        StringBuilder stringBuffer = new StringBuilder();
        for (MultipartFile file : files) {
            try (InputStream inputStream = file.getInputStream()) {
                String originalFilename = file.getOriginalFilename();
                assert originalFilename != null;
                originalFilename = originalFilename.replaceAll("[&=]", "");
                String[] split = originalFilename.split("\\.");
                log.info("upload : {}", originalFilename);
                // 清空
                stringBuffer.delete(0, stringBuffer.length());
                // 构建名字
                stringBuffer.append("file").append(snowFlake.nextId()).append(".")
                        .append(split[1]);
                uploadFilenames.add(stringBuffer.toString());
                stringBuffer.insert(0, FILE_DIRECT);
                String filename = stringBuffer.toString();
                minioClient.putObject(PutObjectArgs.builder()
                        .tags(Collections.singletonMap(ORIGINAL_FILENAME_TAG, originalFilename))
                        .bucket(minioProperties.getBucketName())
                        .object(filename).stream(inputStream, file.getSize(), -1).contentType(file.getContentType())
                        .build());

            } catch (IOException | XmlParserException | ServerException | NoSuchAlgorithmException | InsufficientDataException | InvalidKeyException | InvalidResponseException | ErrorResponseException | InternalException e) {
                e.printStackTrace();
                throw new CommonException("文件上传失败");
            }


        }
        return Result.builder().code("200").data(uploadFilenames).message("上传成功").build();
    }

    /**
     * 下载文件
     *
     * @param filename
     * @return
     * @throws IOException
     * @throws InvalidKeyException
     * @throws InvalidResponseException
     * @throws InsufficientDataException
     * @throws NoSuchAlgorithmException
     * @throws ServerException
     * @throws InternalException
     * @throws XmlParserException
     * @throws ErrorResponseException
     */
    @GetMapping("{filename}")
    public ResponseEntity<InputStreamResource> get(@PathVariable("filename") String filename) throws IOException,
            InvalidKeyException,
            InvalidResponseException, InsufficientDataException, NoSuchAlgorithmException, ServerException,
            InternalException, XmlParserException, ErrorResponseException {
        GetObjectResponse object =
                minioClient.getObject(GetObjectArgs.builder().bucket(minioProperties.getBucketName())
                        .object(
                                FILE_DIRECT + filename).build());
        Tags objectTags = minioClient.getObjectTags(GetObjectTagsArgs.builder()
                .bucket(minioProperties.getBucketName())
                .object(FILE_DIRECT + filename)
                .build());
        log.info("get file : {} , tags : {}", object.object(), objectTags.get());
        Headers pairs = object.headers();
        HttpHeaders headers = new HttpHeaders();
        headers.add("Cache-Control", "no-cache, no-store, must-revalidate");
//        headers.add("Content-Disposition", "attachment; filename=" + objectTags.get().get(ORIGINAL_FILENAME_TAG));
        headers.add("Pragma", "no-cache");
        headers.add("Expires", "0");
        headers.add("Last-Modified", LocalDateTime.now().toString());
        headers.add("ETag", String.valueOf(System.currentTimeMillis()));
        pairs.toMultimap().forEach(headers::addAll);

        return ResponseEntity.ok()
                .headers(headers)
                .contentType(getMediaType(filename)).body(new InputStreamResource(object));
    }
    private  MediaType getMediaType(String filename){
        if(filename.toLowerCase().endsWith("png")){
            return  MediaType.IMAGE_PNG;
        }
        if(filename.toLowerCase().endsWith("jpg") || filename.toLowerCase().endsWith("jpeg")){
            return  MediaType.IMAGE_JPEG;
        }
        if(filename.toLowerCase().endsWith("gif")){
            return  MediaType.IMAGE_GIF;
        }
        return MediaType.APPLICATION_OCTET_STREAM;
    }
}

