

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// 单个值的model，如果页面上只有一个数据或者不想创建一个model的时候使用
/// 可以搭配 [Consumer] 使用
/// 语法糖在 [ReadWatchExt]
class ValueModel<T> with ChangeNotifier {
  T data;
  ValueModel(this.data);
  void setData(T newData) {
    data = newData;
    notifyListeners();
  }

  /// 当 [T] 是 [Map] 或者 [List] 或 [Object] 等类型时
  /// 调用此方法可以强制更新
  void forceUpdate() {
    notifyListeners();
  }
}

/// 缩写
/// ```
/// ChangeNotifierProvider<ValueModel<T>>(
///   create: (_) => ValueModel(value),
/// )
/// ```
/// 简写成
/// `VMProvider<T>(value: value);`
///
///
/// ```
/// ChangeNotifierProvider<ValueModel<T>>.value(
///   value: model,
/// )
/// ```
/// 简写成
/// `VMProvider<T>.value(value: value);`
class VMProvider<T> extends SingleChildStatelessWidget {
  final WidgetBuilder? builder;
  final T Function()? value;
  final ValueModel<T>? model;
  final bool? lazy;

  /// 创建一个ValueModel值 的 ChangeNotifierProvider
  /// 销毁时自动会调用 dispose 方法
  const VMProvider({
    required T Function() create,
    Key? key,
    this.builder,
  })  : lazy = false,
        model = null,
        value = create,
        super(key: key);

  /// 用现有的model定义 一个 ChangeNotifierProvider
  /// 销毁时不会自动调用dispose方法
  const VMProvider.from(
      this.model, {
        Key? key,
        this.builder,
      })  : value = null,
        lazy = true,
        super(key: key);

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    Widget _builder(BuildContext context, Widget? _) {
      if (builder != null) {
        return builder!(context);
      }
      return child ?? const SizedBox.shrink();
    }
    if (value == null) {
      return ChangeNotifierProvider.value(
          value: model!,
          builder: _builder
      );
    } else {
      final val = value!();
      return ChangeNotifierProvider(
          create: (_) => ValueModel<T>(val),
          builder: _builder
      );
    }
  }
}

/// 监听值的变化，如果hash值变化之后会rebuild
class VMObserver<T> extends StatelessWidget {
  final Widget Function(T) builder;
  const VMObserver({required this.builder, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<ValueModel<T>, T>(
      selector: (context, vm) => vm.data,
      builder: (context, data, child) {
        return builder(data);
      },
    );
  }
}

/// 监听 [ValueModel] 的更新，每次都会 rebuild
class VMConsumer<T> extends StatelessWidget {
  final Widget Function(T) builder;
  const VMConsumer({required this.builder, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ValueModel<T>>(
      builder: (context, m, child) {
        return builder(m.data);
      },
    );
  }
}

/// 选择具体的某个值来进行监听更新
class VMSelector<T, S> extends StatelessWidget {
  final S Function(T) selector;
  final Widget Function(T, S) builder;
  const VMSelector({
    required this.selector,
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<ValueModel<T>, S>(
      selector: (context, vm) => selector(vm.data),
      builder: (context, data, child) {
        return builder(context.vmData<T>(), data);
      },
    );
  }
}

extension ReadWatchExt on BuildContext {
  /// 获取指定类型的 [ValueModel] 值
  T vmData<T>() {
    return read<ValueModel<T>>().data;
  }

  /// 获取 设置值的方法
  void Function(T) vmSetter<T>() {
    return read<ValueModel<T>>().setData;
  }

  /// 设置 [ValueModel] 的值
  void vmSet<T>(T data) {
    vmSetter<T>()(data);
  }

  void vmSetFn<T>(T Function(T) setter) {
    vmSet<T>(setter(vmData<T>()));
  }

  /// 获取 [ValueModel]
  ValueModel<T> vm<T>() {
    return read<ValueModel<T>>();
  }

  /// 监听 [ValueModel] 值的变化
  /// 一般用的比较少，因为会让整个provider内rebuild
  T vmWatch<T>() {
    return watch<ValueModel<T>>().data;
  }
}
