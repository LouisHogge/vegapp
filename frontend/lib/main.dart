import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/selected_garden_model.dart';
import 'models/synchronizing_model.dart';
import 'controllers/routes.dart';
import 'controllers/database_helper.dart';

/// Entry point of the Flutter application.
///
/// Initializes the app, setting preferred orientations, handling first-run logic,
/// setting up global HTTP overrides, and starting the app with [VeGApp].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Checking for first run
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool isFirstRun = prefs.getBool('firstRun') ?? true;

  if (isFirstRun) {
    // Initialize database
    await DatabaseHelper.instance.getDatabase();

    // Marking as not first run anymore
    await prefs.setBool('firstRun', false);
  }

  // Preload selectedGardenId
  await SelectedGardenModel().loadSelectedGardenId();
  await SelectedGardenModel().loadSelectedGardenName();
  await SynchronizingModel().loadSynchronizeNumber();

  HttpOverrides.global = MyHttpOverrides();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => SynchronizingModel()),
  ], child: VeGApp(isFirstRun: isFirstRun)));
}

/// Custom HTTP overrides to allow bad certificates.
///
/// This is used to bypass SSL certificate validation because speam.montefiore.uliege.be is self-signed.
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

/// The root widget of the application.
///
/// Decides the initial route based on whether the app is running for the first time and
/// if a garden is already selected. It sets up the routing for the application.
class VeGApp extends StatelessWidget {
  final bool isFirstRun;

  // Constructs a [VeGApp] which initializes with [isFirstRun] to determine the initial route.
  const VeGApp({super.key, required this.isFirstRun});

  @override
  Widget build(BuildContext context) {
    final selectedGardenId = SelectedGardenModel().getSelectedGardenIdSync();
    final initialRoute = selectedGardenId > -1 ? Routes.home : Routes.start;

    return MaterialApp(
        title: 'VeGApp',
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
        routes: Routes.staticRoutes,
        onGenerateRoute: Routes.onGenerateRoute);
  }
}
