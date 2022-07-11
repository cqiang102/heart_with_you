import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/models/sketch.dart';
import 'package:flutter_timelock/services/home_provider.dart';
import 'package:flutter_timelock/services/local_provider.dart';

import 'package:flutter_timelock/generated/l10n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/src/provider.dart';
import 'package:scribble/scribble.dart';

import 'edit_news.dart';

class LocalPage extends StatefulWidget {
  const LocalPage({Key? key}) : super(key: key);

  @override
  State<LocalPage> createState() => _LocalPageState();
}

class _LocalPageState extends State<LocalPage> {
  ScribbleNotifier notifier = ScribbleNotifier();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(S.of(context).now),
        ),
        body: RefreshIndicator(
          onRefresh: () async =>
              await context.read<LocalProvider>().refreshData(),
          child: context.watch<LocalProvider>().list.isEmpty
              ? Center(
                  child: TextButton(
                  onPressed: () async =>
                      await context.read<LocalProvider>().refreshData(),
                  child: Text("暂无草稿,点我刷新"),
                ))
              : LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return ListView.separated(
                      itemCount: context.watch<LocalProvider>().list.length + 1,
                      cacheExtent: MediaQuery.of(context).size.height * 1.5,
                      itemBuilder: (_, index) {
                        if (index ==
                            context.watch<LocalProvider>().list.length) {
                          context.read<LocalProvider>().getData();
                          return Center(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("没有更多了"),
                          ));
                        }
                        BindSketch bindSketch =
                            context.watch<LocalProvider>().list[index];
                        print(bindSketch.createTime.toString());
                        print(bindSketch.id.toString());
                        print(bindSketch.sketch.toString());
                        return Slidable(
                          endActionPane: ActionPane(
                            motion: ScrollMotion(),
                            children: [
                              CustomSlidableAction(
                                onPressed: (_) {
                                  context
                                      .read<LocalProvider>()
                                      .delete(bindSketch.id!);
                                },
                                backgroundColor: Colors.redAccent,
                                foregroundColor: primaryColor.shade100,
                                child: Icon(
                                  Icons.delete,
                                  size: 50,
                                ),
                              ),
                              CustomSlidableAction(
                                onPressed: (_) {
                                  context
                                      .read<HomeProvider>()
                                      .editSketch(context, bindSketch.sketch!);
                                },
                                backgroundColor: Colors.blue,
                                foregroundColor: primaryColor.shade100,
                                child: Icon(
                                  Icons.edit,
                                  size: 50,
                                ),
                              ),
                              CustomSlidableAction(
                                onPressed: (_) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              EditNews(null, bindSketch.image!)));
                                },
                                backgroundColor: Colors.green,
                                foregroundColor: primaryColor.shade100,
                                child: Icon(
                                  Icons.share,
                                  size: 50,
                                ),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                child: Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.sketch,
                                      color: primaryColor,
                                      size: 16,
                                    ),
                                    Text(" No.${bindSketch.id.toString()}"),
                                    Spacer(),
                                    Icon(
                                      FontAwesomeIcons.clock,
                                      color: primaryColor,
                                      size: 16,
                                    ),
                                    Text(
                                        " ${getTime(bindSketch.createTime.toString())}"),
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                width: constraints.maxWidth,
                                height: constraints.maxWidth *
                                    (constraints.maxWidth /
                                        constraints.maxHeight),
                                child: Image.memory(bindSketch.image!),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Divider(
                            color: primaryColor,
                          ),
                        );
                      },
                    );
                  },
                ),
        ));
  }
}
