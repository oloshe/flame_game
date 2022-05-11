import 'dart:convert';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:game/common.dart';
import 'package:game/common/base/coord.dart';
import 'package:game/games/game.dart';
import 'package:game/pages/map_editor/map_editor.dart';
import 'package:game/pages/map_editor/map_editor_provider.dart';
import 'package:game/widgets/button.dart';
import 'package:game/widgets/modal.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class EditorFooter extends StatefulWidget {
  const EditorFooter({Key? key}) : super(key: key);

  @override
  State<EditorFooter> createState() => _EditorFooterState();
}

class _EditorFooterState extends State<EditorFooter> {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xff21252b),
      child: SafeArea(
        bottom: false,
        left: false,
        right: false,
        child: Column(
          children: [
            const Divider(
              color: Color(0xff333841),
              height: 2,
            ),
            SafeArea(
              bottom: false,
              left: true,
              right: true,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 5,
                  bottom: 4,
                  left: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                MyIconButton(
                                  onTap: showAddLayerModal,
                                  color: Colors.blue,
                                  icon: Icons.add,
                                  tooltip: 'addLayer'.langWatch,
                                ),
                                MyIconButton(
                                  onTap: showEditLayerNameModal,
                                  color: const Color(0xffafb1b3),
                                  icon: Icons.edit,
                                  tooltip: 'renameLayer'.langWatch,
                                ),
                                MyIconButton(
                                  onTap: showDeleteLayerModal,
                                  color: Colors.red[400],
                                  icon: Icons.delete_forever,
                                  tooltip: 'deleteLayer'.langWatch,
                                ),
                                MyIconButton(
                                  onTap: context.editor.fillCurrLayer,
                                  color: Colors.green,
                                  icon: Icons.format_color_fill,
                                  tooltip: 'fillLayer'.langWatch,
                                ),
                                Selector<MapEditorProvider, bool?>(
                                    selector: (_, p) => p.currLayerVisible,
                                    builder: (context, visible, _) {
                                      if (visible == null) {
                                        return const SizedBox.shrink();
                                      }
                                      return MyIconButton(
                                        onTap: context.editor.setCurrVisibility,
                                        color: visible
                                            ? Colors.lightBlue
                                            : Colors.grey,
                                        icon: visible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        tooltip: 'visibleLayer'.langWatch,
                                      );
                                    }),
                              ],
                            ),
                          ),
                          Selector<MapEditorProvider, Tuple2<Coord?, int?>>(
                            selector: (c, p) => Tuple2(
                              p.currCell,
                              p.currTileId,
                            ),
                            builder: (context, t, child) {
                              final pos = t.item1;
                              final id = t.item2;
                              var texts = [];
                              if (pos != null) {
                                texts.add(pos.toString());
                              }
                              if (id != null) {
                                texts.add('ID: $id');
                              }
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: texts.isEmpty ? 0 : 10,
                                ),
                                child: Text(
                                  texts.join('  '),
                                  style: const TextStyle(
                                    color: Color(0xffd9b777),
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    NormalButton(
                      text: 'cancelSelect'.langWatch,
                      onTap: () {
                        context.editor.setTileId(null);
                      },
                    ),
                    const SizedBox(width: 10),
                    NormalButton(
                      text: 'resize'.langWatch,
                      onTap: () {
                        showModifySize(context);
                      },
                    ),
                    const SizedBox(width: 10),
                    MainButton(
                      text: 'preview'.langWatch,
                      icon: const Icon(
                        Icons.save,
                        size: 15,
                        color: Colors.white,
                      ),
                      gap: 2,
                      onTap: () {
                        final model = context.editor;
                        final json = jsonEncode(model.rMap);
                        Clipboard.setData(ClipboardData(text: json));
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return GameWidget(
                                game: MyGame(
                                  mapData: model.rMap,
                                ),
                                initialActiveOverlays: const ["backBtn"],
                                overlayBuilderMap: {
                                  "backBtn": (context, game) {
                                    return Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 20,
                                          top: 20,
                                        ),
                                        child: SizedBox(
                                          child: NormalButton(
                                            text: 'back'.lang,
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
            const Divider(
              color: Color(0xff333841),
              height: 2,
            ),
          ],
        ),
      ),
    );
  }

  void showModifySize(BuildContext context) {
    final model = context.editor;

    String inputW = model.width.toString();
    String inputH = model.height.toString();

    Widget _buildModifySizeContent() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Builder(builder: (context) {
          const inputBorder = OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff5c5b62)),
          );
          const inputDecor = InputDecoration(
            isCollapsed: true,
            contentPadding: EdgeInsets.all(10),
            fillColor: Color(0xff0f0f0f),
            filled: true,
            border: inputBorder,
            focusedBorder: inputBorder,
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          );
          return Row(
            children: [
              SizedBox(
                width: 30,
                child: Text('width'.lang),
              ),
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  onChanged: (val) => inputW = val,
                  initialValue: inputW,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xffa0a7b4),
                    fontSize: 12,
                  ),
                  decoration: inputDecor.copyWith(hintText: inputW),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 30,
                child: Text('height'.lang),
              ),
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: (val) => inputH = val,
                  initialValue: inputH,
                  style: const TextStyle(
                    color: Color(0xffa0a7b4),
                    fontSize: 12,
                  ),
                  decoration: inputDecor.copyWith(hintText: inputH),
                ),
              ),
            ],
          );
        }),
      );
    }

    Modal.showModal(
      context: context,
      title: "修改大小",
      builder: (context) => _buildModifySizeContent(),
      onConfirm: (fail) {
        int? w = int.tryParse(inputW);
        int? h = int.tryParse(inputH);
        if (w != null && h != null) {
          if (w < MapEditor.minWidth) {
            Fluttertoast.showToast(
              msg: 'widthMin'.lang.args({'width': MapEditor.minWidth}),
            );
            fail();
            return;
          }
          if (h < MapEditor.minHeight) {
            Fluttertoast.showToast(
              msg: 'heightMin'.lang.args({'height': MapEditor.minHeight}),
            );
            fail();
            return;
          }
          model.setSize(w, h);
          Fluttertoast.showToast(msg: 'modifySuccess'.lang);
        } else {
          Fluttertoast.showToast(msg: 'formatError'.lang);
          fail();
        }
      },
    );
  }

  /// 添加图层
  void showAddLayerModal() {
    Modal.showInputModal(
      title: 'createLayer'.lang,
      confirmText: 'create'.lang,
      initialValue: 'newLayer'.lang,
      maxLength: 20,
      onConfirm: (str) {
        if (str.trim().isEmpty) {
          Fluttertoast.showToast(msg: 'emptyInput'.lang);
          return false;
        }
        context.editor.addLayer(str.trim());
        return true;
      },
    );
  }

  /// 修改图层名字
  void showEditLayerNameModal() {
    var curName = context.editor.currLayerName;
    Modal.showInputModal(
      title: 'modifyLayerName'.lang,
      confirmText: 'done'.lang,
      initialValue: curName,
      maxLength: 20,
      onConfirm: (str) {
        final newName = str.trim();
        if (newName.isEmpty) {
          Fluttertoast.showToast(msg: 'emptyInput'.lang);
          return false;
        }
        if (curName == newName) {
          return true;
        }
        context.editor.renameLayer(curName, newName);
        Fluttertoast.showToast(msg: 'modifySuccess'.lang);
        return true;
      },
    );
  }

  /// 删除图层
  void showDeleteLayerModal() {
    final curName = context.editor.currLayerName ?? '';
    Modal.showModal(
      title: 'deleteLayerTitle'.lang,
      width: 250,
      builder: (context) {
        return Text('deleteLayerConfirm'.lang.args({
          'layer': curName,
        }));
      },
      onConfirm: (fail) {
        context.editor.deleteLayer(curName);
      },
    );
  }
}
