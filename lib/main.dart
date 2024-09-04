import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:fluttertest/home/Camera.dart';
import 'package:fluttertest/home/Clock.dart';
import 'package:fluttertest/home/Push.dart';
import 'package:fluttertest/test/test_screen.dart';

void main() async {
  usePathUrlStrategy();

  List<CameraDescription> cameras = [];

  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.description');
  }

  FlutterLocalNotificationsPlugin()
    ..resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission()
    ..initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ));

  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.cameras,
  });

  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: MyHomePage(
        cameras: cameras,
      ),
      routes: {TestScreen.routeName: (ctx) => const TestScreen()},
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.cameras,
  });

  final List<CameraDescription> cameras;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class PagesData {
  final Widget page;
  final String title;
  final IconData icon;

  PagesData({required this.page, required this.title, required this.icon});
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <PagesData>[
      PagesData(
          page: const Center(child: Text('start page')),
          title: 'Home',
          icon: Icons.home),
      PagesData(
          page: CameraPage(cameras: widget.cameras),
          title: 'Camera',
          icon: Icons.photo_camera),
      PagesData(page: const ClockPage(), title: 'Clock', icon: Icons.timer),
      PagesData(page: const PushPage(), title: 'Push', icon: Icons.push_pin),
    ];

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
                      color: Colors.black,
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
                  destinations: pages
                      .map((e) => NavigationRailDestination(
                            icon: Icon(e.icon),
                            label: Text(e.title),
                          ))
                      .toList(),
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
                    child: pages[selectedIndex].page,
                  ),
                ),
              ),
            ],
          ));
    });
  }
}
