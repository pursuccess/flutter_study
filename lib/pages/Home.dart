import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_study/pages/ExampleDragTarget.dart';
import 'package:provider/provider.dart';

// 首页
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: LayoutBuilder(builder: (context, constraints) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Flutter Study"),
            ),
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text('Favorites'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      print('selected: $value');
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    color: Colors.red,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: page,
                    ),
                  ),
                ),
              ],
            ),
          );
        }));
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    // Scaffold? scaffold = context.findAncestorWidgetOfExactType<Scaffold>();
    // // 直接返回 AppBar的title， 此处实际上是Text("Flutter Study")
    // if (scaffold != null && scaffold.appBar != null) {
    //   print((scaffold.appBar as AppBar).title);
    // }

    // Container? row = context.findAncestorWidgetOfExactType<Container>();
    // print(row);

    // Stream 测试
    // Stream.fromFutures([
    //   // 1秒后返回结果
    //   Future.delayed(Duration(seconds: 1), () {
    //     print(DateTime.now());
    //     return "hello 1";
    //   }),
    //   // 抛出一个异常
    //   Future.delayed(Duration(seconds: 2), () {
    //     print(DateTime.now());
    //     throw AssertionError("Error");
    //   }),
    //   // 3秒后返回结果
    //   Future.delayed(Duration(seconds: 3), () {
    //     print(DateTime.now());
    //     return "hello 3";
    //   })
    // ]).listen((data) {
    //   print(data);
    // }, onError: (e) {
    //   print('error: ${e.message}');
    // }, onDone: () {
    //   print('onDone');
    // });

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            child: Text("open new route ExampleDragTarget"),
            onPressed: () async {
              //导航到新路由
              var result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return ExampleDragTarget();
                }),
              );
              print('ExampleDragTarget widget返回值：$result');
            },
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(pair.asLowerCase, style: style),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}
