import 'package:flutter_study/pages/ExampleDragTarget.dart';
import 'package:flutter_study/pages/Home.dart';

// 注册路由表
class Routes {
  static final routes = {
    "/": (context) => const MyHomePage(),
    "/example-drag-target": (context) => const ExampleDragTarget(),
  };
}
