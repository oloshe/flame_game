import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:game/common.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

/// 编辑器的精灵缓存
/// TODO：退出编辑器n秒后清理缓存
final Map<int, Sprite> _cacheSprite = {};

class MapEditor extends StatelessWidget {
  static const int len = 48;
  static const double len2 = 48.0;
  static const minWidth = 10;
  static const minHeight = 10;

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
            child: SafeArea(
              right: true,
              bottom: false,
              child: FutureBuilder<void>(
                future: loadAllSprite(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              _buildGrid(context),
                              const VerticalDivider(
                                color: Color(0xff333841),
                                width: 1,
                              ),
                              _buildHeader(context),
                            ],
                          ),
                        ),
                        const Divider(
                          color: Color(0xff333841),
                          height: 1,
                        ),
                        const Footer(),
                      ],
                    );
                  } else {
                    return const RefreshProgressIndicator();
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// 地图
  Widget _buildGrid(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(50),
            child: GestureDetector(
              onTapDown: (details) {
                // print(details.localPosition);
                final x = details.localPosition.dx ~/ len;
                final y = details.localPosition.dy ~/ len;
                context.read<MapEditorProvider>().paintCell(x, y);
              },
              child: Selector<MapEditorProvider, Tuple3<int, int, UniqueKey>>(
                selector: (_, p) {
                  return Tuple3(p.width, p.height, p.layersVersion);
                },
                builder: (context, _, child) {
                  final rMap = context.read<MapEditorProvider>().rMap;
                  return RepaintBoundary(
                    child: CustomPaint(
                      painter: MapPainter(rMap),
                      size: Size(
                        rMap.width * len2,
                        rMap.height * len2,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    const inputBorder = OutlineInputBorder(
      borderSide: BorderSide.none,
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
                            )).copyWith(hintText: 'width'.langWatch(context)),
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
                            )).copyWith(hintText: 'height'.langWatch(context)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        style: ButtonStyle(
                          side: MaterialStateProperty.all(
                            const BorderSide(color: Color(0xff568af2)),
                          ),
                          backgroundColor: MaterialStateProperty.all(
                            const Color(0xff21252b),
                          ),
                        ),
                        onPressed: () {
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
                        child: Text(
                          'modify'.langWatch(context),
                          style: const TextStyle(
                              fontWeight: FontWeight.w300, height: 1.2),
                        ),
                      ),
                    )
                  ],
                );
              }),
            ),
            const SizedBox(height: 5),
            const Divider(
              height: 1,
            ),
            const SizedBox(height: 5),
            Expanded(
              child: SingleChildScrollView(child: _buildTileSet()),
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
                  painter: TilePainter(isSelected, _cacheSprite[e.key]),
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
      _cacheSprite[item.key] = sprite;
    }
  }
}

class Footer extends StatefulWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> with TickerProviderStateMixin {
  late final TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(
      length: context.read<MapEditorProvider>().rMap.layers.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ColoredBox(
        color: const Color(0xff21252b),
        child: Row(
          children: [
            Selector<MapEditorProvider, int>(
                selector: (_, p) => p.rMap.layers.length,
                builder: (_, __, ___) {
                  final tabs = context
                      .read<MapEditorProvider>()
                      .rMap
                      .layers
                      .keys
                      .map((e) => Text(e))
                      .toList(growable: false);
                  return TabBar(
                    controller: controller,
                    tabs: tabs,
                    isScrollable: true,
                    labelColor: Colors.blueGrey,
                    labelPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  );
                }),
            TextButton(onPressed: () {}, child: const Icon(Icons.add)),
          ],
        ),
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  final RMap mapData;
  final Paint painter = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke;

  MapPainter(this.mapData);

  @override
  void paint(Canvas canvas, Size size) {
    const len = MapEditor.len2;
    // 绘制网格
    _eachCell((x, y) {
      canvas.drawRect(Rect.fromLTWH(x * len, y * len, len, len), painter);
    });
    for (final _layer in mapData.layers.entries) {
      final layer = _layer.value;
      _eachCell((x, y) {
        final id = layer.matrix[y][x];
        if (id == RMapGlobal.emptyTile) {
          return;
        } else {
          _cacheSprite[id]!.render(
            canvas,
            size: Vector2(len, len),
            position: Vector2(len * x, len * y),
          );
          // canvas.drawImage(image, offset, paint)
        }
      });
    }
  }

  void _eachCell(void Function(int x, int y) func) {
    for (var y = 0; y < mapData.height; y++) {
      for (var x = 0; x < mapData.width; x++) {
        func.call(x, y);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class TilePainter extends CustomPainter {
  final bool selected;
  final Sprite? sprite;
  Paint painter = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  TilePainter(this.selected, this.sprite);

  @override
  void paint(Canvas canvas, Size size) {
    if (sprite != null) {
      sprite!.render(
        canvas,
        size: Vector2(MapEditor.len2, MapEditor.len2),
      );
      if (selected) {
        canvas.drawRect(
            Rect.fromLTWH(-1, -1, size.width, size.height), painter);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class MapEditorProvider with ChangeNotifier {
  int currTileId = -1;
  late RMap rMap;
  int get width => rMap.width;
  int get height => rMap.height;

  /// 标记层级版本用于更新
  UniqueKey layersVersion = UniqueKey();

  late String currLayerName;

  MapEditorProvider() {
    final layerName = 'layer1'.lang;
    const w = 50;
    const h = 50;
    rMap = RMap(width: w, height: h, layers: {
      layerName: RMapLayerData(
        name: layerName,
        index: 1,
        fill: null,
        obj: false,
        matrix: List.generate(
          h,
          (_) => List.generate(w, (_) => RMapGlobal.emptyTile),
        ),
      )
    });
    currLayerName = layerName;
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

  paintCell(int x, int y) {
    if (currTileId != -1) {
      rMap.layers[currLayerName]?.matrix[y][x] = currTileId;
      layersVersion = UniqueKey();
      notifyListeners();
    }
  }
}
