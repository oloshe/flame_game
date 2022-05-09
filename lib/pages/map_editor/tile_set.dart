
import 'package:flutter/material.dart';
import 'package:game/common.dart';
import 'package:game/common/provider_helper.dart';
import 'package:game/pages/map_editor/map_editor.dart';
import 'package:game/pages/map_editor/map_editor_provider.dart';
import 'package:game/pages/map_editor/tile_painter.dart';
import 'package:provider/provider.dart';

class TileSet extends StatefulWidget {
  const TileSet({Key? key}) : super(key: key);

  @override
  State<TileSet> createState() => _TileSetState();
}

class _TileSetState extends State<TileSet> {
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
          context.editor.setTileId(e.key);
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
                  MapEditor.len * e.value.size.x,
                  MapEditor.len * e.value.size.y,
                ),
              ),
            );
          },
        ),
      );
    });
  }
}


class SidePanel extends StatelessWidget {
  const SidePanel({Key? key}) : super(key: key);

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
                    child: TileSet(),
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