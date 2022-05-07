import 'package:flutter/material.dart';

/// 点击页面任何地方都让输入框失去焦点
class KeyboardCollapse extends StatelessWidget {
  final Widget child;
  const KeyboardCollapse({
    Key? key,
    required this.child,
  }) : super(key: key);

  static void hideKeyboard(BuildContext context) =>
      FocusScope.of(context).requestFocus(FocusNode());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 点击页面任何地方都让输入框失去焦点
      onTap: () {
        hideKeyboard(context);
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
