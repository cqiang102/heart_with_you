import 'package:flutter/material.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/config/floading.dart';
import 'package:flutter_timelock/services/comment_provider.dart';
import 'package:provider/src/provider.dart';

class CommentSheet extends StatefulWidget {
  late int newId;

  CommentSheet(this.newId);

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  @override
  void initState() {
    context.read<CommentProvider>().getData(widget.newId);
    super.initState();
  }

  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(microseconds: 500),
      padding: MediaQuery.of(context).viewInsets,
      child: BottomSheet(onClosing: () {
        print("123");
      }, builder: (_) {
        return LayoutBuilder(builder: (_, box) {
          return SizedBox(
            height: box.maxHeight * 0.8,
            child: Column(
              children: [
                Expanded(
                  child: context.watch<CommentProvider>().listData.isEmpty
                      ? Center(
                          child: TextButton(
                            onPressed: () {

                              context
                                  .read<CommentProvider>()
                                  .getData(widget.newId);
                            },
                            child: Text("暂无评论,点我刷新"),
                          ),
                        )
                      : ListView.builder(
                          itemCount: context
                                  .watch<CommentProvider>().listData.length + 1,
                          itemBuilder: (_, index) {
                            if (context
                                    .watch<CommentProvider>().listData
                                    .length ==
                                index) {
                              return Center(
                                child: Text("就这么多了"),
                              );
                            }
                            var item = context.watch<CommentProvider>().listData[index];
                            return ListTile(
                              leading: Text(
                                "${item['nickname']} : ",
                                style: TextStyle(color: primaryColor),
                              ),
                              title: Text(
                                "${item['body']}",
                                maxLines: 3,
                              ),
                              subtitle: Row(
                                children: [
                                  Spacer(),
                                  Text(getTime(item['create_time'])),
                                ],
                              ),
                            );
                          }),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: TextField(
                    controller: textEditingController,
                    onChanged: (str) =>
                        context.read<CommentProvider>().setSendBody(str),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50)),
                      hintText: "说点啥...",
                      hintStyle: TextStyle(fontSize: 14),
                      prefixIcon: Icon(
                        Icons.message,
                        size: 18,
                      ),
                      suffixIcon: context.watch<CommentProvider>().body.isEmpty
                          ? Icon(Icons.send)
                          : InkWell(
                              onTap: () {
                                FLoading.show(context);
                                textEditingController.clear();
                                context
                                    .read<CommentProvider>()
                                    .addComment(widget.newId, context);
                              },
                              child: Icon(
                                Icons.send,
                                color: Colors.green,
                              )),
                    ),
                  ),
                )
              ],
            ),
//                                  child: Center(
//                                    child: TextButton(
//                                      onPressed: () {
//                                        Navigator.pop(context);
//                                      },
//                                      child: Text("关闭"),
//                                    ),
//                                  ),
          );
        });
      }),
    );
  }
}
