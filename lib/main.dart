
import 'package:flutter/material.dart';
import 'package:flutter_study/pages/ExampleDragTarget.dart';
import 'package:flutter_study/route/route.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namer App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 235, 85, 97),
        ),
      ),
      routes: Routes.routes,
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(builder: (context) {
          String? routeName = settings.name;
          if (routeName == "/example-drag-target") {
            print(routeName);
            return ExampleDragTarget();
          }
          return Container(child: Text('默认路由页面'),);
        });
      },
    );
  }
}

