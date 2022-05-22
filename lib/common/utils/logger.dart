import 'package:visual_console/visual_console.dart';
import 'dart:io';

var logger = VisualLogger(
  filter: ProductionFilter(),
  output: VisualOutput(),
  printer: VisualPrinter(
    realPrinter: VisualPrefixPrinter(
      methodCount: 1,
      lineLength: () {
        int lineLength = 80;
        try {
          // 获取控制台一行能打印多少字符
          lineLength = stdout.terminalColumns;
        } catch (e) {}
        return lineLength;
      }(),
      colors: stdout.supportsAnsiEscapes, // Colorful log messages
      printEmojis: false, // 打印表情符号
      printTime: true, // 打印时间
    ),
  ),
);