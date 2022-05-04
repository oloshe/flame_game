import 'package:flame/components.dart';

mixin Reorder on Component {
  int? oldPriority;

  void reorder() {
    oldPriority = priority;
    priority = 100;
  }
}