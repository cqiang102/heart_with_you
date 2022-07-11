import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/config/floading.dart';
import 'package:flutter_timelock/pages/body/user_profile.dart';
import 'package:flutter_timelock/services/new_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_timelock/generated/l10n.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_timelock/services/api_service.dart' as api;

import 'comment_sheet.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage>
    with AutomaticKeepAliveClientMixin {
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              S.of(context).history,
            ),
            Expanded(
              child: TextField(
                focusNode: focusNode,
                controller:
                    context.select((NewProvider p) => p.textEditingController),
                onEditingComplete: () {
                  focusNode.unfocus();
                  context.read<NewProvider>().search();
                },
                onChanged: (str) => context.read<NewProvider>().updateStr(str),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "请输入搜索内容",
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 16),
                  suffixIcon: InkWell(
                    onTap: () async{
                      focusNode.unfocus();
                      FLoading.show(context);
                       context.read<NewProvider>().search();
                    },
                    child: Icon(
                      Icons.search,
                      color: primaryColor,
                    ),
                  ),
//                    suffix: IconButton(
//                      onPressed: () {},
//                      icon: Icon(
//                        Icons.search,
//                        color: primaryColor,
//                      ),
//                    ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xfffafafa),
        elevation: 0,
      ),
      body: context.watch<NewProvider>().listData.isEmpty
          ? Center(
              child: TextButton(
                  onPressed: () {
                    context.read<NewProvider>().refreshData();
                  },
                  child: Text("暂无内容，重新加载")),
            )
          : RefreshIndicator(
              onRefresh: () async {
                focusNode.unfocus();
                await context.read<NewProvider>().refreshData();
              },
              child: ListView.builder(
                  itemCount:
                      context.select((NewProvider p) => p.listData).length + 1,
                  cacheExtent: MediaQuery.of(context).size.height * 1.5,
                  itemBuilder: (_, index) {
                    print("index $index");
                    if (index == context.watch<NewProvider>().listData.length) {
                      /// TODO 异步加载数据
                      /// TODO 使用 provider
                      context.read<NewProvider>().getData();
                      return Center(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("没有更多了"),
                      ));
                    }
                    return _buildListItem(index);
                  }),
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  _buildListItem(int index) {
    List<String> images = [
      "0201.png",
      "0202.png",
      "lacia01.jpg",
      "lacia02.png",
      "leimu01.png",
      "leimu02.png",
      "mei01.jpg"
    ];
    var item = context.watch<NewProvider>().listData[index];
    print(item["nickname"]);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>UserProfile({
                    "username":item['user_id'],
                    "nickname":item['nickname']
                  })));
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
                          .read<NewProvider>()
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
                      context.read<NewProvider>().operator(
                          item['new_id'], 2, item['ifStar'] == 1 ? 0 : 1);
                    },
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
