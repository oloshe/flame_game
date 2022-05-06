import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game/common.dart';
import 'package:game/common/i18n.dart';
import 'package:game/game.dart';
import 'package:game/pages/map_editor/map_editor.dart';
import 'package:game/widgets/button.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 设置屏幕方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  await R.init();

  await Translations.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navKey = GlobalKey();
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Translations.instance,
        ),
      ],
      builder: (context, child) {
        return MaterialApp(
          locale: const Locale('zh', 'CN'),
          debugShowCheckedModeBanner: false,
          navigatorKey: navKey,
          home: GameWidget(
            game: MyGame(),
            overlayBuilderMap: {
              "backBtn": (context, game) {
                return Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    child: NormalButton(
                      text: '返回',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              }
            },
          ),
          // home: Consumer<Translations>(
          //   builder: (context, tr, child) {
          //     return const MapEditor();
          //   },
          // ),
        );
      },
    );
  }
}
