import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lets_chat/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lets_chat/services/database_service.dart';
import 'package:connectivity/connectivity.dart'; // Import connectivity package
import '../services/navigation_service.dart';
import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';

class SplashPage extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashPage({required Key key, required this.onInitializationComplete})
      : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2)).then((_) {
      _setup().then(
            (_) => widget.onInitializationComplete(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      title: "Let's Chat",
      theme: ThemeData(
        backgroundColor: const Color.fromARGB(36, 35, 49, 1),
        scaffoldBackgroundColor: const Color.fromARGB(36, 35, 49, 1),
      ),
      home: Scaffold(
        body: Center(
          child: Container(
            height: deviceHeight * 0.10,
            child: const Text(
              "Let's Chat",
              style: TextStyle(
                color: Colors.white,
                fontSize: 40.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _setup() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Check internet connectivity
    bool isConnected = await _checkConnectivity();
    if (!isConnected) {
      _showNoInternetSnackbar();
      return;
    }

    _registerServices();
  }

  Future<bool> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  void _showNoInternetSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No internet connection'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _registerServices() {
    GetIt.instance.registerSingleton<NavigationService>(
      NavigationService(),
    );
    GetIt.instance.registerSingleton<MediaService>(
      MediaService(),
    );

    GetIt.instance.registerSingleton<CloudStorageService>(
      CloudStorageService(),
    );
    GetIt.instance.registerSingleton<DatabaseService>(
      DatabaseService(),
    );
  }
}
