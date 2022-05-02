import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:game/common.dart';
import 'package:game/pages/map_editor/map_painter.dart';
import 'package:game/pages/map_editor/tile_painter.dart';
import 'package:game/widgets/button.dart';
import 'package:game/widgets/modal.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class MapEditor extends StatelessWidget {
  static const int len = 48;
  static const double len2 = 48.0;
  static const minWidth = 10;
  static const minHeight = 10;

  /// 编辑器的精灵缓存
  /// TODO：退出编辑器n秒后清理缓存
  static final Map<int, Sprite> spriteCached = {};

  const MapEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MapEditorProvider())
      ],
      builder: (context, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: ColoredBox(
            color: const Color(0xff282c34),
            child: FutureBuilder<void>(
              future: loadAllSprite(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Column(
                    children: [
                      Expanded(
                        child: SafeArea(
                          right: true,
                          left: false,
                          bottom: false,
                          child: Row(
                            children: [
                              _buildGrid(context),
                              const VerticalDivider(
                                color: Color(0xff333841),
                                width: 2,
                              ),
                              _buildHeader(context),
                            ],
                          ),
                        ),
                      ),
                      const Footer(),
                    ],
                  );
                } else {
                  return SizedBox.expand(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: Color(0xff6797bb),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'editorLoading'.lang,
                            style: const TextStyle(color: Color(0xff6797bb)),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  /// 地图
  Widget _buildGrid(BuildContext context) {
    final insets = MediaQuery.of(context).viewPadding;
    return Expanded(
      child: InteractiveViewer(
        constrained: false,
        maxScale: 5,
        minScale: 0.2,
        boundaryMargin: EdgeInsets.only(
          left: math.max(insets.left, 50),
          top: math.max(insets.top, 50),
          right: 50,
          bottom: 50,
        ),
        child: GestureDetector(
          onTapUp: (details) {
            // print(details.localPosition);
            final x = details.localPosition.dx ~/ len;
            final y = details.localPosition.dy ~/ len;
            context.read<MapEditorProvider>().paintCell(x, y);
          },
          onDoubleTapDown: (details) {},
          child: Selector<MapEditorProvider, Tuple3<int, int, UniqueKey>>(
            selector: (_, p) {
              return Tuple3(p.width, p.height, p.layersVersion);
            },
            builder: (context, _, child) {
              final rMap = context.read<MapEditorProvider>().rMap;
              final size = Size(
                rMap.width * len2,
                rMap.height * len2,
              );
              return SizedBox.fromSize(
                size: size,
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: MapPainter(rMap),
                    size: size,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    const inputBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xffaab2bf)),
    );
    return SizedBox(
      width: 300,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Builder(builder: (context) {
                String inputW =
                    context.read<MapEditorProvider>().width.toString();
                String inputH =
                    context.read<MapEditorProvider>().height.toString();
                return Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        onChanged: (val) => inputW = val,
                        initialValue: inputW,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xffa0a7b4)),
                        decoration: const InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.all(5),
                            fillColor: Color(0xff2c313c),
                            filled: true,
                            border: inputBorder,
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            )).copyWith(hintText: 'width'.langWatch),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('X', style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (val) => inputH = val,
                        initialValue: inputH,
                        style: const TextStyle(color: Color(0xffa0a7b4)),
                        decoration: const InputDecoration(
                            filled: true,
                            isCollapsed: true,
                            contentPadding: EdgeInsets.all(5),
                            fillColor: Color(0xff2c313c),
                            border: inputBorder,
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            )).copyWith(hintText: 'height'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: MainButton(
                      text: 'modify'.langWatch,
                      onTap: () {
                        int? w = int.tryParse(inputW);
                        int? h = int.tryParse(inputH);
                        if (w != null && h != null) {
                          if (w < minWidth) {
                            Fluttertoast.showToast(
                              msg: 'widthMin'.lang.args('width', minWidth),
                            );
                            return;
                          }
                          if (h < minHeight) {
                            Fluttertoast.showToast(
                              msg: 'heightMin'.lang.args('height', minHeight),
                            );
                            return;
                          }
                          context.read<MapEditorProvider>().setSize(w, h);
                          Fluttertoast.showToast(msg: 'modifySuccess'.lang);
                        } else {
                          Fluttertoast.showToast(msg: 'formatError'.lang);
                        }
                      },
                    )),
                  ],
                );
              }),
            ),
            const SizedBox(height: 5),
            const SizedBox(height: 5),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _buildTileSet(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTileSet() {
    final list = R.getAllTiles();
    Widget func(MapEntry<int, RTileData> e) {
      return Builder(builder: (context) {
        return InkWell(
          onTap: () {
            context.read<MapEditorProvider>().setTileId(e.key);
          },
          child: Selector<MapEditorProvider, bool>(
            selector: (_, p) => p.currTileId == e.key,
            builder: (context, isSelected, child) {
              return RepaintBoundary(
                child: CustomPaint(
                  painter: TilePainter(isSelected, spriteCached[e.key]),
                  size: const Size.square(len2 + 2),
                ),
              );
            },
          ),
        );
      });
    }

    return Wrap(
      children: list.map(func).toList(growable: false),
    );
  }

  Future<void> loadAllSprite() async {
    final list = R.getAllTiles();
    for (var item in list) {
      final sprite = await item.value.getSprite();
      spriteCached[item.key] = sprite;
    }
  }
}

class Footer extends StatefulWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xff21252b),
      child: SafeArea(
        bottom: true,
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
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                    ),
                    child: Selector<MapEditorProvider,
                        Tuple2<int, Iterable<String>>>(
                      selector: (_, p) => Tuple2(
                        p.rMap.layers.length,
                        p.rMap.layers.keys,
                      ),
                      builder: (_, __, ___) {
                        final tabs = context
                            .read<MapEditorProvider>()
                            .rMap
                            .layers
                            .keys
                            .toList(growable: false);
                        return _LayerTab(tabs);
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: showAddLayerModal,
                    child: const Icon(Icons.add),
                  ),
                  TextButton(
                    onPressed: showEditLayerNameModal,
                    child: const Icon(
                      Icons.edit,
                      color: Color(0xffafb1b3),
                    ),
                  ),
                  TextButton(
                    onPressed: showDeleteLayerModal,
                    child: const Icon(
                      Icons.delete_forever,
                      color: Color(0xffc75450),
                    ),
                  ),
                  const VerticalDivider(
                    color: Color(0xff333841),
                    width: 1,
                  ),
                ],
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

  /// 添加图层
  void showAddLayerModal() {
    Modal.showInputModal(
      title: 'createLayer'.lang,
      confirmText: 'create'.lang,
      initialValue: 'newLayer'.lang,
      onConfirm: (str) {
        if (str.trim().isEmpty) {
          Fluttertoast.showToast(msg: 'emptyInput'.lang);
          return false;
        }
        context.read<MapEditorProvider>().addLayer(str.trim());
        return true;
      },
    );
  }

  /// 修改图层名字
  void showEditLayerNameModal() {
    var curName = context.read<MapEditorProvider>().currLayerName;
    Modal.showInputModal(
      title: 'modifyLayerName'.lang,
      confirmText: 'done'.lang,
      initialValue: curName,
      onConfirm: (str) {
        final newName = str.trim();
        if (newName.isEmpty) {
          Fluttertoast.showToast(msg: 'emptyInput'.lang);
          return false;
        }
        if (curName == newName) {
          return true;
        }
        context.read<MapEditorProvider>().renameLayer(curName, newName);
        Fluttertoast.showToast(msg: 'modifySuccess'.lang);
        return true;
      },
    );
  }

  /// 删除图层
  void showDeleteLayerModal() {
    final curName = context.read<MapEditorProvider>().currLayerName ?? '';
    Modal.showModal(
      title: 'deleteLayer'.lang,
      width: 250,
      builder: (context) {
        return Text('deleteLayerConfirm'.lang.args('layer', curName));
      },
      onConfirm: (fail) {
        context.read<MapEditorProvider>().deleteLayer(curName);
      },
    );
  }
}

class _LayerTab extends StatelessWidget {
  final List<String> tabs;
  const _LayerTab(this.tabs, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) {
      return const SizedBox();
    }
    return DefaultTabController(
      length: tabs.length,
      child: TabBar(
        tabs: tabs.map((e) => Text(e)).toList(growable: false),
        indicator: const BoxDecoration(color: Color(0xff3d424b)),
        isScrollable: true,
        labelColor: Colors.blueGrey,
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 4,
        ),
        onTap: (index) {
          context.read<MapEditorProvider>().setCurrLayerName(tabs[index]);
        },
      ),
    );
  }
}

class MapEditorProvider with ChangeNotifier {
  int currTileId = -1;
  late RMap rMap;
  int get width => rMap.width;
  int get height => rMap.height;

  /// 标记层级版本用于更新
  UniqueKey layersVersion = UniqueKey();

  String? currLayerName;

  MapEditorProvider() {
    final layerName = 'layer1'.lang;
    const w = 50;
    const h = 50;
    rMap = RMap(width: w, height: h, layers: {
      layerName: _createLayer(1, w, h),
    });
    currLayerName = layerName;
  }

  setCurrLayerName(String name) {
    if (currLayerName != name) {
      currLayerName = name;
      notifyListeners();
    }
  }

  setTileId(int id) {
    if (currTileId != id) {
      currTileId = id;
    } else {
      currTileId = -1;
    }
    notifyListeners();
  }

  setSize(int w, int h) {
    if (width != w || height != h) {
      rMap.apply(w, h);
      notifyListeners();
    }
  }

  addLayer(String name) {
    if (rMap.layers.length > 10) {
      Fluttertoast.showToast(msg: 'layerMax'.lang);
      return;
    }
    final sureName = _checkLayerNameNoRepeat(name);
    rMap.layers[sureName] = _createLayer(rMap.layers.length + 1, width, height);
    currLayerName ??= sureName; // 如果没有层就默认选中该层
    _updateLayer();
    Fluttertoast.showToast(msg: 'layerAdded'.lang);
  }

  _updateLayer() {
    layersVersion = UniqueKey();
    notifyListeners();
  }

  void deleteLayer(String name) {
    if (rMap.layers.containsKey(name)) {
      rMap.layers.remove(name);
      Fluttertoast.showToast(msg: 'layerDeleted'.lang);
      if (currLayerName == name) {
        if (rMap.layers.isNotEmpty) {
          final newCurrName = rMap.layers.keys.toList(growable: false)[0];
          currLayerName = newCurrName;
        } else {
          currLayerName = null;
        }
      }
      _updateLayer();
    }
  }

  /// 确保名字不重复
  String _checkLayerNameNoRepeat(String name) {
    var sureName = name;
    var index = 1;

    /// 确保名字不重复
    while (rMap.layers.containsKey(sureName)) {
      sureName = "$name$index";
      index += 1;
    }
    return sureName;
  }

  /// 重命名图层
  renameLayer(String? oldName, String newName) {
    if (rMap.layers.containsKey(oldName)) {
      final sureName = _checkLayerNameNoRepeat(newName);
      final tempData = rMap.layers.remove(oldName);
      assert(tempData != null);
      rMap.layers[sureName] = tempData!;
      if (currLayerName == oldName) {
        currLayerName = sureName;
      }
      _updateLayer();
    }
  }

  RMapLayerData _createLayer(int index, int w, int h) {
    return RMapLayerData(
      index: index,
      fill: null,
      obj: false,
      matrix: List.generate(
        h,
        (_) => List.generate(w, (_) => RMapGlobal.emptyTile),
      ),
    );
  }

  paintCell(int x, int y) {
    if (currTileId != -1) {
      if (currLayerName != null) {
        if (rMap.layers.containsKey(currLayerName)) {
          rMap.layers[currLayerName]!.matrix[y][x] = currTileId;
          layersVersion = UniqueKey();
          notifyListeners();
        }
      }
    }
  }
}
