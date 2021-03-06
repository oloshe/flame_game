import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game/common/utils/i18n.dart';
import 'package:game/pages/map_editor/map_editor.dart';
import 'package:game/respect/index.dart';
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
          debugShowCheckedModeBanner: false,
          navigatorKey: navKey,
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            if (deviceLocale?.languageCode == 'zh') {
              Translations.instance.updateLocale(const Locale('zh', 'CN'));
            }
            return null;
          },
          // home: GameWidget(
          //   game: MyGame(),
          // ),
          home: Consumer<Translations>(
            builder: (context, tr, child) {
              return const MapEditor();
            },
          ),
        );
      },
    );
  }
}
