part of '../../common.dart';

var logger = VisualLogger(
  filter: ProductionFilter(),
  output: VisualOutput(),
  printer: VisualPrinter(
    realPrinter: VisualPrefixPrinter(
      methodCount: 1,
      lineLength: () {
        late int lineLength;
        try {
          // 获取控制台一行能打印多少字符
          lineLength = stdout.terminalColumns;
        } catch (e) {
          lineLength = 80;
        }
        return lineLength;
      }(),
      colors: stdout.supportsAnsiEscapes, // Colorful log messages
      printEmojis: false, // 打印表情符号
      printTime: true, // 打印时间
    ),
  ),
);
