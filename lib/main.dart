import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:fluttertest/home/Camera.dart';
import 'package:fluttertest/test/test_screen.dart';

void main() async {
  usePathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  print(firstCamera);

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: MyHomePage(
        camera: camera,
      ),
      routes: {TestScreen.routeName: (ctx) => const TestScreen()},
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (selectedIndex) {
      case 1:
        page = CameraPage(camera: widget.camera);
        break;
      default:
        page = const Center(child: Text('start page'));
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
          appBar: AppBar(title: const Text('Test App')),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                  ),
                  child: Text(
                    'Test App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Test Screen'),
                  onTap: () {
                    Navigator.of(context).pushNamed(TestScreen.routeName);
                  },
                ),
              ],
            ),
          ),
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 1000,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.build),
                      label: Text('Camera'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Center(
                    child: page,
                  ),
                ),
              ),
            ],
          ));
    });
  }
}
