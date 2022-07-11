import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/config/floading.dart';
import 'package:flutter_timelock/models/sketch.dart';
import 'package:flutter_timelock/services/api_service.dart' as api;
import 'package:flutter_timelock/services/db_service.dart' as db;

import 'package:scribble/scribble.dart';
class EditNews extends StatefulWidget {
  final Sketch? sketch;
  final Uint8List image;

  EditNews(this.sketch,this.image, {
    Key? key,
  }) : super(key: key);

  @override
  State<EditNews> createState() => _EditNewsState();
}

class _EditNewsState extends State<EditNews> {
  String string = "";

  bool view = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: Text("你的内容将会丢失"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("取消")),
                      if(widget.sketch != null)TextButton(
                          onPressed: () async{
                            FLoading.show(context);
                            await db.bindSketchProvider.save(BindSketch.name(
                                sketch: widget.sketch,
                                image: widget.image.buffer.asUint8List(),
                                createTime: DateTime.now()));
                            FLoading.hide();
                            Navigator.of(context).pop(true);
                          },
                          child: Text("保存草稿")),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text("确定")),
                    ],
                  );
                }).then((value) {
              if (value != null && value) {
                Navigator.of(context).pop();
              }
            });
          },
          icon: Icon(
            Icons.arrow_back,
            color: primaryColor,
          ),
        ),
        title: Text("发布"),
        actions: [
          IconButton(
            onPressed: () async {
              // TODO api send
              if(string.isNotEmpty){
                FLoading.show(context);
                String? imageFilename = await api.uploadImage(widget.image);
                // 提交数据
                await api.saveNew(string,view,imageFilename!);
                Navigator.of(context).pop();
                FLoading.hide();
              }
              // 上传图片

            },
            icon: Icon(
              Icons.check,
              color: primaryColor,
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              minLines: 5,
              maxLines: 10,
              onChanged: (str) => string = str,
              decoration: InputDecoration(
                hintText: "请输入内容",
                border: OutlineInputBorder(
                  ///设置边框四个角的弧度
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  ///用来配置边框的样式
                  borderSide: BorderSide(
                    ///设置边框的颜色
                    color: Colors.red,
                    ///设置边框的粗细
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),
//          Padding(
//            padding: const EdgeInsets.all(8.0),
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.end,
//              children: [
//                Text("私密"),
//                Switch(value: view, onChanged: (value) =>
//                    setState(() {
//                      view = value;
//                    })),
//              ],),
//          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.memory(widget.image),
          ),
        ],
      ),
    );
  }
}
