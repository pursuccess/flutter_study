import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 235, 85, 97)),
        ),
        home: MyHomePage(),
      ),
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

class MyHomePage extends StatefulWidget {
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
      case 2: 
        page = ExampleDragTarget();
        
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
        appBar: AppBar(
          title: Text("Context测试"),
        ),
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.water_drop_outlined),
                      label: Text('Drop'),
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
      }
    );
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

    Scaffold? scaffold = context.findAncestorWidgetOfExactType<Scaffold>();
    // 直接返回 AppBar的title， 此处实际上是Text("Context测试")
    if (scaffold != null && scaffold.appBar != null) {
      print((scaffold.appBar as AppBar).title);
    }

    Container? row = context.findAncestorWidgetOfExactType<Container>();
    print(row);

    Stream.fromFutures([
      // 1秒后返回结果
      Future.delayed(Duration(seconds: 1), () {
        print(DateTime.now());
        return "hello 1";
      }),
      // 抛出一个异常
      Future.delayed(Duration(seconds: 2), () {
        print(DateTime.now());
        throw AssertionError("Error");
      }),
      // 3秒后返回结果
      Future.delayed(Duration(seconds: 3), () {
        print(DateTime.now());
        return "hello 3";
      })
    ]).listen((data) {
      print(data);
    }, onError: (e) {
      print('error: ${e.message}');
    }, onDone: () {
      print('onDone');
    });

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
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

class ExampleDragTarget extends StatefulWidget {
  const ExampleDragTarget({Key? key}) : super(key: key);

  @override
  State<ExampleDragTarget> createState() => _ExampleDragTargetState();
  // State<ExampleDragTarget> createState() => DropPageState();
}

class _ExampleDragTargetState extends State<ExampleDragTarget> {
  final List<XFile> _list = [];

  bool _dragging = false;

  Offset? offset;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) async {
        print('done');
        setState(() {
          _list.addAll(detail.files);
        });

        for (final file in detail.files) {
          debugPrint('  ${file.path} ${file.name}'
              '  ${await file.lastModified()}'
              '  ${await file.length()}'
              '  ${file.mimeType}');
        }
      },
      onDragUpdated: (details) {
        print('update');
        setState(() {
          offset = details.localPosition;
        });
      },
      onDragEntered: (detail) {
        print('enter');
        setState(() {
          _dragging = true;
          offset = detail.localPosition;
        });
      },
      onDragExited: (detail) {
        print('exit');
        setState(() {
          _dragging = false;
          offset = null;
        });
      },
      child: Container(
        height: 200,
        width: 200,
        color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.black26,
        child: Stack(
          children: [
            if (_list.isEmpty)
              const Center(child: Text("Drop here"))
            else
              Text(_list.map((e) => e.path).join("\n")),
            if (offset != null)
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  '$offset',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
          ],
        ),
      ),
    );
  }
}

class DropPageState extends State<ExampleDragTarget> {
  XFile? file;
  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) async{
        setState(() {
          file = detail.files.last;
        });
        final filePath = file?.path as String;
        if (filePath.endsWith(".svg")) {
          final svgContent = await file?.readAsString();
          print(svgContent);
        }
      },
      child: file == null ? uploadImage() : viewImage(file!),
    );
  }
  
  Widget uploadImage() {
    return Center(
      child: Container(
        width: 400,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(
            color: const Color(0xFFC9CDD4),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.image, size: 60, color: Colors.blue),
            SizedBox(height: 8),
            Text(
              '拖动图片打开',
              style: TextStyle(fontSize: 24, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget viewImage(XFile file) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(blurRadius: 8, color: Colors.black26),
            ],
          ),
          child: file.path.endsWith(".svg") ? SvgPicture.file(
                    File(file.path),
                    height: 352,
                  ) : Image.file(
            File(file.path),
          ),
        ),
      ),
    );
  }
}

