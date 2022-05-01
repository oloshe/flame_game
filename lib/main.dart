import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game/common.dart';
import 'package:game/game.dart';
import 'package:game/pages/map_editor.dart';
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

  i18n = await I18N.create();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: i18n),
      ],
      builder: (context, child) {
        return Consumer<I18N>(
          builder: (context, _, __) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: MapEditor(),
              // home: GameWidget(
              //   game: MyGame(),
              // )
            );
          },
        );
      }
    );
  }

}