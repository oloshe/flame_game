
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

/// 需要多个参数的时候可以配合 [tuple] 来定义类型。
/// 例如 `Event<Tuple2<String, int>>`
class Event<T> extends BaseEvent<T> {
  Event([
    String? eventName,
    Key? key,
  ]) : super(key ?? UniqueKey(), eventName);

  /// 监听[eventName]事件
  /// 传入的[callback]必须接收[data]参数
  /// 返回一个[StreamSubscription]类型对象，持有该对象并调用cancel()可以移除监听
  @override
  EventHandler on(EventCallback<T> callback) =>
      _EventMgr.instance.on<T>(key, callback);

  /// 监听[eventName]事件，响应一次事件后自动移除监听
  /// 传入的[callback]必须接收[data]参数
  /// 传入额外的[T]类型能指定回调方法[callback]接收的[data]类型为[T]
  /// 返回一个[StreamSubscription]类型对象，持有该对象并调用cancel()可以移除监听
  @override
  EventHandler once(EventCallback<T> callback) =>
      _EventMgr.instance.once<T>(key, callback);

  /// 广播[eventName]事件
  /// [data]是传给事件响应方法的参数
  void emit(T data) {
    _trace(data);
    _EventMgr.instance.emit(key, data);
  }
}

/// [Event] 的无参数版本
/// 如果需要多个参数，可以 Event2，Event3... 以此类推
/// 或者 [Event] 搭配 Tuple 一起使用
class Event0 extends BaseEvent<void> {
  Event0([
    String? eventName,
    Key? key,
  ]) : super(key ?? UniqueKey(), eventName);

  /// 广播事件
  void emit() {
    _trace();
    _EventMgr.instance.emit(key);
  }

  @override
  EventHandler on(EventCallback0 callback) =>
      _EventMgr.instance.on<void>(key, (_) {
        callback();
      });

  @override
  EventHandler once(EventCallback0 callback) =>
      _EventMgr.instance.once<void>(key, (_) {
        callback();
      });
}

/// [Event] 的双参数版本
class Event2<T, F> extends BaseEvent<Tuple2<T, F>> {
  Event2([
    String? eventName,
    Key? key,
  ]) : super(key ?? UniqueKey(), eventName);

  void emit(T arg1, F arg2) {
    _trace([arg1, arg2]);
    _EventMgr.instance.emit(key, Tuple2(arg1, arg2));
  }

  @override
  EventHandler on(EventCallback2<T, F> callback) =>
      _EventMgr.instance.on<Tuple2<T, F>>(key, (tuple) {
        callback(tuple.item1, tuple.item2);
      });

  @override
  EventHandler once(EventCallback2<T, F> callback) =>
      _EventMgr.instance.once<Tuple2<T, F>>(key, (tuple) {
        callback(tuple.item1, tuple.item2);
      });
}

/// [Event] 的双参数版本
class Event3<A, B, C> extends BaseEvent<Tuple3<A, B, C>> {
  Event3([
    String? eventName,
    Key? key,
  ]) : super(key ?? UniqueKey(), eventName);

  void emit(A arg1, B arg2, C arg3) {
    _trace([arg1, arg2, arg3]);
    _EventMgr.instance.emit(key, Tuple3(arg1, arg2, arg3));
  }

  @override
  EventHandler on(EventCallback3<A, B, C> callback) =>
      _EventMgr.instance.on<Tuple3<A, B, C>>(key, (tuple) {
        callback(tuple.item1, tuple.item2, tuple.item3);
      });

  @override
  EventHandler once(EventCallback3<A, B, C> callback) =>
      _EventMgr.instance.once<Tuple3<A, B, C>>(key, (tuple) {
        callback(tuple.item1, tuple.item2, tuple.item3);
      });
}

/// 事件定义
class _EventData<T> {
  Key key;
  T? eventData;
  _EventData(this.key, [this.eventData]);
}

/// 事件响应方法类型定义
typedef EventCallback0 = void Function();
typedef EventCallback<T> = void Function(T);
typedef EventCallback2<T, F> = void Function(T, F);
typedef EventCallback3<A, B, C> = void Function(A, B, C);

/// 自定义事件的流订阅类
typedef EventSubscription = StreamSubscription<_EventData<dynamic>>;

class _EventMgr {
  /// 是否打印日志
  static const printLog = true;

  /// [_EventMgr] 实例，用于触发事件
  static _EventMgr instance = _EventMgr();

  final StreamController<_EventData<dynamic>> _streamController =
  StreamController.broadcast(sync: false);

  /// 广播[eventName]事件
  /// [data]是传给事件响应方法的参数
  void emit(Key key, [dynamic data]) {
    //在没有监听者的情况下add事件，事件会一直存在于stream的缓存区内，有内存泄漏风险
    if (_streamController.hasListener) {
      _streamController.add(_EventData(key, data));
    }
  }

  /// 监听[eventName]事件
  /// 传入的[callback]必须接收[data]参数
  /// 传入额外的[T]类型能指定回调方法[callback]接收的[data]类型为[T]
  /// 返回一个[StreamSubscription]类型对象，持有该对象并调用cancel()可以移除监听
  EventHandler on<T>(Key key, EventCallback<T> callback) {
    return _streamController.stream //
        .where((event) => event.key == key) //
        .listen(
          (event) => callback.call(event.eventData),
      cancelOnError: true, // 报错就取消
    )
        .handler;
  }

  /// 监听[eventName]事件，响应一次事件后自动移除监听
  /// 传入的[callback]必须接收[data]参数
  /// 传入额外的[T]类型能指定回调方法[callback]接收的[data]类型为[T]
  /// 返回一个[StreamSubscription]类型对象，持有该对象并调用cancel()可以移除监听
  EventHandler once<T>(Key key, EventCallback<T> callback) {
    late final EventSubscription subscription;
    subscription = _streamController.stream //
        .where((event) => event.key == key) //
        .listen(
          (event) {
        callback.call(event.eventData);
        subscription.cancel();
      },
      cancelOnError: true, // 报错就取消
    );
    return subscription.handler;
  }

  /// 获得[eventName]的数据流[Stream]，方便在[StreamBuilder]场景使用
  /// 传入额外的[T]类型能指定[Stream]中的数据类型为[T]
  Stream<T> onStream<T>(Key key) {
    return _streamController.stream
        .where((event) => event.key == key)
        .map((event) => event.eventData as T);
  }
}

/// 封装一下 [StreamSubscription] 不关注具体类型
/// 方便定义，以及防止错用
/// 用于保存流订阅之后的句柄
class EventHandler {
  final StreamSubscription<dynamic> _streamSubscription;
  EventHandler(this._streamSubscription);

  /// 取消时间监听
  void cancel() {
    _streamSubscription.cancel();
  }
}

extension EventHandlerNullableExt on EventHandler? {
  void cancel() => this?.cancel();
}

extension EventHandlerExt on StreamSubscription<dynamic> {
  /// 方便获得句柄
  EventHandler get handler => EventHandler(this);
}

abstract class BaseEvent<T> {
  /// 事件名
  final String? eventName;
  final Key key;
  BaseEvent(this.key, [this.eventName]);

  /// 方便子类继承的事拓展为不同的类型
  dynamic on(covariant dynamic callback);
  dynamic once(covariant dynamic callback);

  // /// 获得[eventName]的数据流[Stream]，方便在[StreamBuilder]场景使用
  Stream<T> get stream => _EventMgr.instance.onStream<T>(key);

  @protected
  void _trace([dynamic data]) {
    if (_EventMgr.printLog) {
      if (data == null) {
        print(this);
      } else {
        print("$this\n$data");
      }
    }
  }

  @override
  String toString() {
    return "$key EventMgr - $eventName";
  }
}