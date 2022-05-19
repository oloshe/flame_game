import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:game/common.dart';
import 'package:game/common/base/coord.dart';
import 'package:game/components/respect_map.dart';
import 'package:game/pages/map_editor/editor_footer.dart';
import 'package:game/pages/map_editor/map_editor_provider.dart';
import 'package:game/pages/map_editor/map_painter.dart';
import 'package:game/pages/map_editor/tile_set.dart';
import 'package:game/respect/index.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class MapEditor extends StatelessWidget {
  static final double len = RespectMap.base.x;
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
            child: Column(
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
                        const SidePanel(),
                      ],
                    ),
                  ),
                ),
                const EditorFooter(),
              ],
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
            final x = details.localPosition.dx ~/ len;
            final y = details.localPosition.dy ~/ len;
            context.editor.paintCell(x, y);
          },
          onDoubleTapDown: (details) {},
          child: Selector<MapEditorProvider, Tuple2<Coord, int>>(
            selector: (_, p) {
              /// 宽高发生变化
              return Tuple2(Coord(p.width, p.height), p.rMap.layers.length);
            },
            builder: (context, _, child) {
              final model = context.editor;
              final rMap = model.rMap;
              final width = rMap.width;
              final height = rMap.height;
              final size = Size(width * len, height * len);
              // if (rMap.layers.isEmpty) {
              //   return SizedBox.fromSize(
              //     size: size,
              //     child: const Center(child: Text('No Layer')),
              //   );
              // }
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
      child: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: Selector<MapEditorProvider,
                  Tuple3<int, Iterable<String>, bool?>>(
                selector: (_, p) => Tuple3(
                  p.rMap.layers.length,
                  p.rMap.layers.keys,
                  p.currLayerVisible,
                ),
                builder: (_, __, ___) {
                  final tabs = context.editor.rMap.layerList
                      .map((e) => Tuple2(e.key, e.value.visible))
                      .toList(growable: false);
                  return _LayerTab(tabs);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayerTab extends StatelessWidget {
  final List<Tuple2<String, bool>> tabs;
  const _LayerTab(this.tabs, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) {
      return const SizedBox();
    }
    return DefaultTabController(
      length: tabs.length,
      child: TabBar(
        tabs: tabs.map((e) {
          return Text(
            e.item1,
            style: !e.item2
                ? const TextStyle(
                    color: Colors.brown,
                    decoration: TextDecoration.lineThrough,
                    decorationThickness: 3,
                    decorationColor: Colors.blueGrey,
                  )
                : null,
          );
        }).toList(growable: false),
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
          context.editor.setCurrLayerName(tabs[index].item1);
        },
      ),
    );
  }
}
