import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/config/floading.dart';
import 'package:flutter_timelock/pages/body/user_profile.dart';
import 'package:flutter_timelock/services/star_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'comment_sheet.dart';
import 'package:flutter_timelock/services/api_service.dart' as api;

class StarPage extends StatefulWidget {
  @override
  State<StarPage> createState() => _StarPageState();
}

class _StarPageState extends State<StarPage> {
@override
  void initState() {
    // TODO: implement initState
  context.read<StarProvider>().getData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("我的收藏"),
      leading: IconButton(onPressed: (){
        Navigator.pop(context);
      },icon: Icon(Icons.arrow_back,color: primaryColor,),),
      ),
      body: ListView(children:
      context.select((StarProvider u) => u.listData).isEmpty
          ? ([
        Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                "你还没收藏呢",
                style: TextStyle(color: primaryColor),
              ),
            ))
      ])
          : context
          .watch<StarProvider>()
          .listData
          .map((e) => _buildListItem(e))
          .toList()

      ),
    );
  }

  Widget _buildListItem(var item) {
    List<String> images = [
      "0201.png",
      "0202.png",
      "lacia01.jpg",
      "lacia02.png",
      "leimu01.png",
      "leimu02.png",
      "mei01.jpg"
    ];
    print(item["nickname"]);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: Column(
        children: [

          Row(

            children: [
              Icon(
                FontAwesomeIcons.userTag,
                color: primaryColor,
                size: 16,
              ),
              InkWell(
                onTap: (){
                  // TODO 打开个人资料页面
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>UserProfile(item)));
                },
                child: Text(
                  "  ${item["nickname"]}",
                  style: TextStyle(fontSize: 16, color: primaryColor),
                ),
              ),
              Spacer(),
              Icon(
                FontAwesomeIcons.clock,
                color: primaryColor,
                size: 16,
              ),
              Text(
                " ${getTime(item["create_time"])}",
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item["body"],
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.3),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: item["images"] != null
                  ? PhotoView(
                  backgroundDecoration: BoxDecoration(color: Colors.white),
                  imageProvider: NetworkImage(
                    "http://$resourceServer/file/${item["images"]}",
//                      width: double.infinity,
//                      fit: BoxFit.cover,
                    headers: {"Authorization": "Bearer ${api.token}"},
                  ))
                  : Image(
                width: double.infinity,
                fit: BoxFit.cover,
                image: AssetImage(
                  "assets/images/" +
                      images[Random.secure().nextInt(images.length)],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                // TODO 点赞
                IconButton(
                    onPressed: () {
                      FLoading.show(context);
                      context
                          .read<StarProvider>()
                          .operator(item['new_id'], 1, item['ifUp'] == 1 ? 0 : 1);
                    },
                    icon: Icon(
                      FontAwesomeIcons.heart,
                      color: item['ifUp'] == 1 ? primaryColor : Colors.grey,
                      size: 18,
                    )),
                Spacer(
                  flex: 1,
                ),
                Text(
                  "${item["up_count"] ?? 0}",
                  style: TextStyle(fontSize: 12),
                ),
                Spacer(
                  flex: 4,
                ),
                // TODO 评论
                // 打开 b sheet 输入一句话
                IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return CommentSheet(item["new_id"]);
                          });
                    },
                    icon: Icon(FontAwesomeIcons.comment, size: 18)),
                Spacer(
                  flex: 1,
                ),
                Text(
                  "${item["comment_count"] ?? 0}",
                  style: TextStyle(fontSize: 12),
                ),
                Spacer(
                  flex: 4,
                ),
                // TODO 收藏
                IconButton(
                    onPressed: () {
                      FLoading.show(context);
                      context.read<StarProvider>()
                          .operator(
                          item['new_id'], 2, item['ifStar'] == 1 ? 0 : 1);
                    }
    ,
                    icon: Icon(
                      FontAwesomeIcons.star,
                      size: 18,
                      color: item['ifStar'] == 1 ? primaryColor : Colors.grey,
                    )),
                Spacer(
                  flex: 1,
                ),
                Text(
                  "${item["star_count"] ?? 0}",
                  style: TextStyle(fontSize: 12),
                ),
                Spacer(
                  flex: 50,
                ),
                Icon(FontAwesomeIcons.slideshare, size: 18)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Divider(
              color: primaryColor.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
