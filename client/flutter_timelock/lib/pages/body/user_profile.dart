import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/config/floading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_timelock/services/api_service.dart' as api;
import 'package:flutter_timelock/services/db_service.dart' as db;
import 'package:flutter_timelock/services/user_profile_provider.dart';

import 'comment_sheet.dart';

class UserProfile extends StatefulWidget {
  var item;

  UserProfile(this.item);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
//  const UserProfile({Key? key}) : super(key: key);

  @override
  void initState() {
    context.read<UserProfileProvider>().setUsername(widget.item['username']);
    context.read<UserProfileProvider>().getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<dynamic, dynamic> bindUser =
    context.select((UserProfileProvider u) => u.bindUser);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item['nickname']),
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: primaryColor,
            )),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${getDay(bindUser['create_time'] ?? "")}",
                style: TextStyle(color: primaryColor),
              ),
            ),
          ),
          if (!(db.prefs.getString(loginUsername) ==
              widget.item['username'].toString()))
            context.select((UserProfileProvider u) => u.followFlag)
                ? IconButton(
                onPressed: () {
                  FLoading.show(context);
                  context.read<UserProfileProvider>().follow(false);
                },
                icon: Icon(
                  Icons.close,
                  size: 25,
                  color: Colors.red,
                ))
                : IconButton(
                onPressed: () {
                  FLoading.show(context);
                  context.read<UserProfileProvider>().follow(true);
                },
                icon: Icon(
                  Icons.add,
                  size: 25,
                  color: Colors.green,
                )),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            flexibleSpace: FlexibleSpaceBar(
                background: bindUser['background_url'] != null
                    ? Image.network(
                  "http://$resourceServer/file/${bindUser['background_url']}",
                  fit: BoxFit.cover,
                  headers: {"Authorization": "Bearer ${api.token}"},
                )
                    : Center(
                  child: Text(
                    "空空如也",
                    style: TextStyle(color: primaryColor),
                  ),
                )),
            floating: true,
            expandedHeight: 250,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
                context
                    .select((UserProfileProvider u) => u.listData)
                    .isEmpty
                    ? ([
                  Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Text(
                          "ta 很懒，暂无动态",
                          style: TextStyle(color: primaryColor),
                        ),
                      ))
                ])
                    : context
                    .watch<UserProfileProvider>()
                    .listData
                    .map((e) => _buildListItem(e))
                    .toList()
                  ..insert(0, Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text("动态...", style: TextStyle(
                        fontSize: 18,
                        color: primaryColor),),
                  ))),
          ),
        ],
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
                maxHeight: MediaQuery
                    .of(context)
                    .size
                    .height * 0.3),
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
                          .read<UserProfileProvider>()
                          .operator(
                          item['new_id'], 1, item['ifUp'] == 1 ? 0 : 1);
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
                      context
                          .read<UserProfileProvider>()
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

  getDay(String createTime) {
    DateTime? create = DateTime.tryParse(createTime);
    if (create == null) {
      return "";
    }
    DateTime now = DateTime.now();
    Duration difference = now.difference(create);
    return "${difference.inDays} 天前加入";
  }
}
