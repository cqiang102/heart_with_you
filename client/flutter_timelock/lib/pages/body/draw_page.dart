import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:flutter_timelock/config/common_const.dart';
import 'package:flutter_timelock/config/floading.dart';
import 'package:flutter_timelock/models/sketch.dart';
import 'package:flutter_timelock/pages/body/edit_news.dart';
import 'package:flutter_timelock/services/draw_provider.dart';
import 'package:flutter_timelock/services/profile_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scribble/scribble.dart';
import 'package:flutter_timelock/services/db_service.dart' as db;
import 'package:flutter_timelock/services/api_service.dart' as api;

import 'package:provider/provider.dart';

class DrawPage extends StatefulWidget {
  const DrawPage({Key? key}) : super(key: key);

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("未来"),
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double drawWidth = constraints.maxWidth;
              double drawHeight = constraints.maxWidth *
                  (constraints.maxWidth / constraints.maxHeight);
              return SizedBox(
                width: drawWidth,
                height: constraints.maxHeight,
                child: Stack(
                  children: [
                    Positioned(
                      top: (constraints.maxHeight - drawHeight) / 2,
                      child: SingleChildScrollView(
                        child: Container(
                          color: Colors.white,
                          width: drawWidth,
                          height: drawHeight,
                          child: Scribble(
                            notifier: context.select(
                                (DrawProvider drawProvider) =>
                                    drawProvider.notifier),
                            drawPen: true,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: AnimatedContainer(
                        width: drawWidth,
                        height: (constraints.maxHeight - drawHeight) / 2,
                        color: context.select((DrawProvider drawProvider) =>
                            drawProvider.backgroundColor),
                        duration: const Duration(seconds: 5),
                      ),
                    ),
                    Positioned(
                      child: AnimatedContainer(
                        color: context.select((DrawProvider drawProvider) =>
                            drawProvider.backgroundColor),
                        duration: const Duration(seconds: 5),
                        width: drawWidth,
                        height: (constraints.maxHeight - drawHeight) / 2,
                      ),
                      bottom: 0,
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildColorToolbar(context),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _saveImage(BuildContext context) async {
    ScribbleNotifier notifier = context.read<DrawProvider>().notifier;

    final image = await notifier.renderImage();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("此刻"),
        content: Image.memory(image.buffer.asUint8List()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "取消",
                style: TextStyle(color: Colors.redAccent),
              )),
          TextButton(
              onPressed: () async {
                FLoading.show(context);

                String? imageFilename =
                    await api.uploadImage(image.buffer.asUint8List());
                await api.saveBackground(imageFilename!);

                Navigator.pop(context);
                context.read<ProfileProvider>().updateUser();

              },
              child: Text("设为背景")),
          TextButton(
              onPressed: () async{
                // 保存数据库
                FLoading.show(context);

                db.bindSketchProvider.save(BindSketch.name(
                    sketch: notifier.currentSketch,
                    createTime: DateTime.now(),
                    image: image.buffer.asUint8List()));
                FLoading.hide();

                Navigator.pop(context);
              },
              child: const Text("保存草稿")),
          TextButton(
              onPressed: () async {
                Navigator.pop(context);

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EditNews(notifier.currentSketch,
                            image.buffer.asUint8List())));
              },
              child: const Text("发布")),
        ],
      ),
    );
  }

  Future<void> _colorSelect(
      BuildContext context, List<Color> recentColors) async {
    Color color = await showColorPickerDialog(
      context,
      recentColors.first,
      title: const Text("选择画笔颜色"),
      opacitySubheading: const Text("透明度"),
      recentColorsSubheading:
          recentColors.isNotEmpty ? const Text("最近使用") : null,
      recentColors: recentColors,
      maxRecentColors: 10,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.primary: false,
        ColorPickerType.accent: true,
      },
      actionButtons: const ColorPickerActionButtons(
        dialogActionButtons: true,
        dialogCancelButtonType: ColorPickerActionButtonType.text,
        dialogOkButtonType: ColorPickerActionButtonType.text,
        dialogActionIcons: false,
      ),
      opacityTrackHeight: 18,
      copyPasteBehavior:
          const ColorPickerCopyPasteBehavior(editFieldCopyButton: false),
      enableShadesSelection: true,
      enableOpacity: true,
      showColorCode: true,
      colorCodeHasColor: true,
      showRecentColors: true,
      enableTonalPalette: true,
    );
    context.read<DrawProvider>().updateRecentColors(color);
  }

  Widget _buildColorToolbar(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return StateNotifierBuilder<ScribbleState>(
      stateNotifier:
          context.select((DrawProvider drawProvider) => drawProvider.notifier),
      builder: (context, state, _) => AnimatedContainer(
        width: context.select((DrawProvider provider) => provider.showTool)
            ? width
            : 60,
        duration: const Duration(microseconds: 1000),
        child: context.select((DrawProvider provider) => provider.showTool)
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildToolButton(),
                    _buildDivider(18),
                    _buildUndoButton(context),
                    _buildDivider(18),
                    _buildRedoButton(context),
                    _buildDivider(18),
                    _buildEraserButton(context, isSelected: state is Erasing),
                    _buildDivider(18),
                    _buildSaveButton(context),
                    _buildDivider(18),
                    _buildColorSelectButton(
                        context,
                        context.select(
                            (DrawProvider provider) => provider.recentColors)),
                    _buildDivider(18),
                    _buildPenSizeSelectButton(context),
                    _buildDivider(18),
                    _buildDivider(18),
                    _buildClearButton(context),
                    _buildDivider(18),
                    _buildPointerModeSwitcher(context,
                        penMode: state.allowedPointersMode ==
                            ScribblePointerMode.penOnly),
                  ],
                ),
              )
            : _buildToolButton(),
      ),
    );
  }

  _buildDivider(double size) {
    return SizedBox(
      width: size,
      height: size,
    );
  }

  _buildToolButton() {
    return FloatingActionButton.small(
      heroTag: "ToolButton",
      tooltip: "工具",
      onPressed: () => context.read<DrawProvider>().updateShowTool(),
      disabledElevation: 0,
      backgroundColor: primaryColor,
      child: Icon(FontAwesomeIcons.tools),
    );
  }

  Widget _buildPointerModeSwitcher(BuildContext context,
      {required bool penMode}) {
    return FloatingActionButton.small(
      heroTag: "PointerModeSwitcher",
      onPressed: () =>
          context.read<DrawProvider>().notifier.setAllowedPointersMode(
                penMode ? ScribblePointerMode.all : ScribblePointerMode.penOnly,
              ),
      tooltip: "绘图 " + (penMode ? "关闭" : "开启"),
      child: AnimatedSwitcher(
        duration: kThemeAnimationDuration,
        child: !penMode
            ? const Icon(
                Icons.touch_app,
                key: ValueKey(true),
              )
            : const Icon(
                Icons.do_not_touch,
                key: ValueKey(false),
              ),
      ),
    );
  }

  Widget _buildEraserButton(BuildContext context, {required bool isSelected}) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: FloatingActionButton.small(
        heroTag: "EraserButton",
        tooltip: "橡皮擦",
        backgroundColor: const Color(0xFFF7FBFF),
        elevation: isSelected ? 10 : 2,
        shape: !isSelected
            ? const CircleBorder()
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
        child: const Icon(Icons.remove, color: Colors.blueGrey),
        onPressed: context
            .select((DrawProvider drawProvider) => drawProvider.notifier)
            .setEraser,
      ),
    );
  }

  Widget _buildUndoButton(
    BuildContext context,
  ) {
    return FloatingActionButton.small(
      heroTag: "UndoButton",
      tooltip: "撤销",
      onPressed: context
              .select((DrawProvider drawProvider) => drawProvider.notifier)
              .canUndo
          ? context
              .select((DrawProvider drawProvider) => drawProvider.notifier)
              .undo
          : null,
      disabledElevation: 0,
      backgroundColor: context
              .select((DrawProvider drawProvider) => drawProvider.notifier)
              .canUndo
          ? Colors.blueGrey
          : Colors.grey,
      child: const Icon(
        Icons.undo_rounded,
        color: Colors.white,
      ),
    );
  }

  Widget _buildRedoButton(
    BuildContext context,
  ) {
    return FloatingActionButton.small(
      tooltip: "重置",
      heroTag: "RedoButton",
      onPressed: context
              .select((DrawProvider drawProvider) => drawProvider.notifier)
              .canRedo
          ? context
              .select((DrawProvider drawProvider) => drawProvider.notifier)
              .redo
          : null,
      disabledElevation: 0,
      backgroundColor: context
              .select((DrawProvider drawProvider) => drawProvider.notifier)
              .canRedo
          ? Colors.blueGrey
          : Colors.grey,
      child: const Icon(
        Icons.redo_rounded,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
  ) {
    return FloatingActionButton.small(
      tooltip: "保存",
      onPressed: () => _saveImage(context),
      disabledElevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(
        Icons.save,
        color: Colors.white,
      ),
    );
  }

  Widget _buildColorSelectButton(
      BuildContext context, List<Color> recentColors) {
    return FloatingActionButton.small(
      heroTag: "ColorSelectButton",
      tooltip: "颜色",
      onPressed: () => _colorSelect(context, recentColors),
      disabledElevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(
        Icons.palette,
        color: Colors.white,
      ),
    );
  }

  Widget _buildPenSizeSelectButton(
    BuildContext context,
  ) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return FloatingActionButton.small(
      heroTag: "PenSizeSelectButton",
      tooltip: "画笔尺寸",
      onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("画笔"),
              content: SizedBox(
                width: width * 0.8,
                height: height * 0.1,
                child: Slider(
                  min: 0,
                  max: 20,
                  label: context
                      .select(
                          (DrawProvider drawProvider) => drawProvider.penSize)
                      .toString(),
                  divisions: 40,
                  onChanged: (value) =>
                      context.read<DrawProvider>().updatePenSize(value),
                  value: context.select(
                      (DrawProvider drawProvider) => drawProvider.penSize),
                ),
              ),
            );
          }),
      disabledElevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(
        FontAwesomeIcons.pencilAlt,
        color: Colors.white,
      ),
    );
  }

  Widget _buildClearButton(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: "ClearButton",
      tooltip: "清除",
      onPressed: () => context.read<DrawProvider>().clear(),
      disabledElevation: 0,
      backgroundColor: Colors.blueGrey,
      child: const Icon(Icons.clear),
    );
  }
}
