import 'dart:convert';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:game/common.dart';
import 'package:game/common/provider_helper.dart';
import 'package:game/game.dart';
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
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildGrid(context),
                                    const _LayerTool(),
                                  ],
                                ),
                              ),
                              const _SidePanel(),
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
        // child: MapRenderWidget(context.read<MapEditorProvider>()),
        child: GestureDetector(
          onTapUp: (details) {
            final x = details.localPosition.dx ~/ len;
            final y = details.localPosition.dy ~/ len;
            context.read<MapEditorProvider>().paintCell(x, y);
          },
          onDoubleTapDown: (details) {},
          child: Selector<MapEditorProvider, Tuple2<Coord, int>>(
            selector: (_, p) {
              /// 宽高发生变化
              return Tuple2(Coord(p.width, p.height), p.rMap.layers.length);
            },
            builder: (context, _, child) {
              final model = context.read<MapEditorProvider>();
              final rMap = model.rMap;
              final width = rMap.width;
              final height = rMap.height;
              final size = Size(width * len2, height * len2);
              return SizedBox.fromSize(
                size: size,
                child: Stack(
                  children: [
                    // 网格
                    RepaintBoundary(
                      child: CustomPaint(
                        painter: MapGridPainter(width, height),
                        willChange: false,
                      ),
                    ),
                    // 每个图层
                    for (var layer in rMap.layerList)
                      Selector<MapEditorProvider, bool>(
                        selector: (c, p) => p.currLayerName == layer.key,
                        builder: (_, isCurr, child) {
                          if (isCurr) {
                            return Selector<MapEditorProvider, UniqueKey>(
                              selector: (_, p) => p.layersVersion,
                              builder: (context, _, __) {
                                return RepaintBoundary(
                                  child: CustomPaint(
                                    painter: MapPainter(
                                      layer.value,
                                      width,
                                      height,
                                    ),
                                    size: size,
                                    willChange: false,
                                  ),
                                );
                              },
                            );
                          } else {
                            return child!;
                          }
                        },
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: MapPainter(
                              layer.value,
                              width,
                              height,
                            ),
                            size: size,
                            willChange: false,
                          ),
                        ),
                      ),
                    // 选中框
                    Selector<MapEditorProvider, Coord?>(
                      selector: (_, p) => p.currCell,
                      builder: (_, coord, __) {
                        if (coord == null) {
                          return const SizedBox();
                        }
                        return RepaintBoundary(
                          child: CustomPaint(
                            painter: CurrTilePainter(coord),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
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

class _LayerTool extends StatefulWidget {
  const _LayerTool({Key? key}) : super(key: key);

  @override
  State<_LayerTool> createState() => _LayerToolState();
}

class _LayerToolState extends State<_LayerTool> {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xff323844),
      child: Row(
        children: [
          Expanded(
            child: Selector<MapEditorProvider, Tuple2<int, Iterable<String>>>(
              selector: (_, p) => Tuple2(
                p.rMap.layers.length,
                p.rMap.layers.keys,
              ),
              builder: (_, __, ___) {
                final tabs = context
                    .read<MapEditorProvider>()
                    .rMap
                    .layerList
                    .map((e) => e.key)
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
          TextButton(
            onPressed: fillLayer,
            child: const Icon(
              Icons.format_color_fill,
              color: Color(0xff10a50c),
            ),
          ),
        ],
      ),
    );
  }

  void fillLayer() {
    context.read<MapEditorProvider>().fillCurrLayer();
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
        return Text('deleteLayerConfirm'.lang.args({
          'layer': curName,
        }));
      },
      onConfirm: (fail) {
        context.read<MapEditorProvider>().deleteLayer(curName);
      },
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VMProvider<bool>(
      create: () => false,
      builder: (context) {
        return VMProvider<double>(
          create: () => 300,
          builder: (context) {
            const minWidth = 280.0;
            final maxWidth = MediaQuery.of(context).size.width * 0.7;
            return Row(
              children: [
                _buildDraggableDivider(context, minWidth, maxWidth),
                Consumer<ValueModel<double>>(
                  builder: (context, width, child) {
                    return SizedBox(
                      width: context.vmData<double>(),
                      child: child,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: _TileSet(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDraggableDivider(
    BuildContext context,
    double minWidth,
    double maxWidth,
  ) {
    return GestureDetector(
      onPanDown: (_) {
        context.vmSet<bool>(true);
      },
      onPanUpdate: (details) {
        final newVal = context.vmData<double>() - details.delta.dx;
        if (newVal >= minWidth && newVal <= maxWidth) {
          context.vmSet<double>(newVal);
        }
      },
      onPanEnd: (_) {
        context.vmSet<bool>(false);
      },
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        child: SizedBox(
          width: 5,
          height: double.infinity,
          child: VMObserver<bool>(
            builder: (resizing) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                color: resizing
                    ? const Color(0xff528bff)
                    : const Color(0xff323845),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: -5,
                      right: -5,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const Positioned(
                      left: -5,
                      right: -5,
                      child: Icon(
                        Icons.drag_handle,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TileSet extends StatefulWidget {
  const _TileSet({Key? key}) : super(key: key);

  @override
  State<_TileSet> createState() => _TileSetState();
}

class _TileSetState extends State<_TileSet> {
  final Map<String, List<MapEntry<int, RTileData>>> typedListMap = {};
  late String currTab;
  @override
  void initState() {
    super.initState();
    final list = R.getAllTiles();
    for (final item in list) {
      if (!typedListMap.containsKey(item.value.type)) {
        typedListMap[item.value.type] = [];
      }
      typedListMap[item.value.type]!.add(item);
    }
    currTab = typedListMap.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DefaultTabController(
          length: typedListMap.length,
          child: SizedBox(
            height: 30,
            child: TabBar(
              tabs: typedListMap.entries
                  .map((e) => Text(e.key.langWatch))
                  .toList(growable: false),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 3,
              isScrollable: true,
              onTap: (tab) {
                setState(() {
                  currTab =
                      typedListMap.entries.toList(growable: false)[tab].key;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Wrap(
              spacing: 2,
              runSpacing: 2,
              children: typedListMap[currTab]!
                  .map(_buildItem)
                  .toList(growable: false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(MapEntry<int, RTileData> e) {
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
                painter: TilePainter(
                  selected: isSelected,
                  sprite: MapEditor.spriteCached[e.key],
                  tileSize: e.value.size,
                ),
                size: Size(
                  MapEditor.len2 * e.value.size.x,
                  MapEditor.len2 * e.value.size.y,
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class Footer extends StatefulWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
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
                        context.read<MapEditorProvider>().setTileId(null);
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
                        final model = context.read<MapEditorProvider>();
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
    final model = context.read<MapEditorProvider>();

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
                  decoration: inputDecor.copyWith(hintText: 'width'.langWatch),
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
                  decoration: inputDecor.copyWith(hintText: 'height'.langWatch),
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
        });
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
        labelColor: const Color(0xffeeeeee),
        padding: EdgeInsets.zero,
        unselectedLabelColor: Colors.blueGrey,
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
  /// 当前选中 tile
  int? currTileId;

  /// 地图数据
  late RMap rMap;

  /// 地图宽度
  int get width => rMap.width;

  /// 地图高度
  int get height => rMap.height;

  /// 当前选中地图坐标
  Coord? currCell;

  /// 标记层级版本用于更新
  UniqueKey layersVersion = UniqueKey();

  String? currLayerName;

  MapEditorProvider() {
    final layerName = 'layer1'.lang;
    const w = 20;
    const h = 20;
    rMap = RMap(width: w, height: h, layers: {
      layerName: _createLayer(1, w, h, 1),
    });
    currLayerName = layerName;
  }

  /// 修改图层名字
  setCurrLayerName(String name) {
    if (currLayerName != name) {
      currLayerName = name;
      notifyListeners();
    }
  }

  fillCurrLayer() {
    if (currLayerName != null) {
      rMap.layers[currLayerName]!.fill = currTileId;
      layersVersion = UniqueKey();
      notifyListeners();
    } else {
      Fluttertoast.showToast(msg: 'noLayer'.lang);
    }
  }

  setTileId(int? id) {
    if (currTileId != id) {
      currTileId = id;
    } else {
      currTileId = null;
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
    notifyListeners();
    Fluttertoast.showToast(msg: 'layerAdded'.lang);
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
      notifyListeners();
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
      notifyListeners();
    }
  }

  RMapLayerData _createLayer(int index, int w, int h, [int? fill]) {
    return RMapLayerData(
      index: index,
      fill: null,
      obj: false,
      matrix: List.generate(
        h,
        (_) => List.generate(w, (_) => fill ?? RMapGlobal.emptyTile),
      ),
    );
  }

  paintCell(int x, int y) {
    int? id = currTileId;
    final newCoord = Coord(x, y);
    if (id == null && currCell == newCoord) {
      id = RMapGlobal.emptyTile;
    } else {
      currCell = newCoord;
    }
    if (id != null) {
      if (currLayerName != null) {
        if (rMap.layers.containsKey(currLayerName)) {
          rMap.layers[currLayerName]!.matrix[y][x] = id;
          layersVersion = UniqueKey();
        }
      }
    }
    notifyListeners();
  }
}

class Coord {
  final int x;
  final int y;
  const Coord(this.x, this.y);

  @override
  String toString() {
    return 'rowColumn'.lang.args({
      'row': y,
      'column': x,
    });
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        ((other is Coord) && other.x == x && other.y == y);
  }

  @override
  int get hashCode => Object.hash(this, x, y);
}
