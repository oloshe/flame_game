import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game/common.dart';
import 'package:game/common/utils/provider_helper.dart';
import 'package:game/main.dart';
import 'package:game/widgets/button.dart';
import 'package:game/widgets/keyboard_collapse.dart';

class Modal {
  Modal._();

  static Future<T?> showModal<T>({
    BuildContext? context,
    required String title,
    WidgetBuilder? builder,
    EdgeInsets? contentPadding,
    double? width,
    String? cancelText,
    String? confirmText,
    FutureOr<T?> Function(VoidCallback markAsFailed)? onConfirm,
    VoidCallback? onCancel,
  }) async {
    return await showGeneralDialog<T>(
      context: context ?? MyApp.navKey.currentContext!,
      barrierColor: Colors.black12,
      transitionDuration: Duration.zero,
      pageBuilder: (context, _, __) {
        return KeyboardCollapse(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Dialog(
              backgroundColor: const Color(0xff21252b),
              elevation: 10,
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  color: Color(0xff4d5055),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.hardEdge,
              child: VMProvider<bool>(
                create: () => false,
                builder: (context) {
                  return SizedBox(
                    width: width ?? 300,
                    child: Focus(
                      onFocusChange: (val) {
                        if (kIsWeb) {
                          return;
                        }
                        context.vmSet<bool>(val);
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 标题
                            VMObserver<bool>(builder: (keyboardShow) {
                              return SizedBox(
                                width: double.infinity,
                                height: keyboardShow ? 0 : null,
                                child: ColoredBox(
                                  color: const Color(0xff38393b),
                                  child: SizedBox(
                                    height: 30,
                                    child: Center(
                                      child: Text(
                                        title,
                                        style: const TextStyle(
                                          color: Color(0xffb4b5b7),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 内容
                                if (builder != null)
                                  Padding(
                                    padding: contentPadding ??
                                        const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 20,
                                        ),
                                    child: DefaultTextStyle(
                                      style: const TextStyle(
                                          color: Color(0xffa2a9b6)),
                                      child: builder(context),
                                    ),
                                  ),
                                // 按钮
                                VMObserver<bool>(builder: (keyboardShow) {
                                  if (keyboardShow) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 5),
                                    child: Row(
                                      children: [
                                        const Spacer(),
                                        NormalButton(
                                          text: cancelText ?? 'cancel'.lang,
                                          onTap: () {
                                            onCancel?.call();
                                            Navigator.pop(context);
                                          },
                                        ),
                                        const SizedBox(width: 20),
                                        MainButton(
                                          text: confirmText ?? 'confirm'.lang,
                                          onTap: () async {
                                            if (onConfirm != null) {
                                              bool close = true;
                                              final result =
                                                  await onConfirm.call(() {
                                                close = false;
                                              });
                                              if (close == false) {
                                                return;
                                              }
                                              Navigator.pop(context, result);
                                              return;
                                            } else {
                                              Navigator.pop(context);
                                            }
                                          },
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<bool?> showInputModal({
    BuildContext? context,
    required String title,
    String? initialValue,
    String? hint,
    WidgetBuilder? builder,
    String? cancelText,
    String? confirmText,
    FutureOr<bool?> Function(String)? onConfirm,
    VoidCallback? onCancel,
    int? maxLength,
  }) {
    var input = initialValue ?? '';
    return Modal.showModal(
      context: context,
      title: title,
      confirmText: confirmText,
      cancelText: cancelText,
      onCancel: onCancel,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      builder: (context) {
        return TextFormField(
          onChanged: (val) => input = val,
          initialValue: input,
          style: const TextStyle(
            color: Color(0xffa0a7b4),
          ),
          maxLength: maxLength ?? 140,
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
              color: Color(0xff808080),
            )),
            counterStyle: TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
            hintStyle: TextStyle(color: Color(0xff6f7076)),
          ).copyWith(hintText: hint),
        );
      },
      onConfirm: (fail) {
        if (onConfirm != null) {
          final close = onConfirm.call(input);
          if (close == false) {
            return false;
          }
        }
        return true;
      },
    );
  }
}
