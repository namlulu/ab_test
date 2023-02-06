import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:provider/provider.dart';

import 'model/bucket_model.dart';
import 'services/auth_service.dart';
import '/views/login_page.dart';
import 'views/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // main 함수에서 async 사용하기 위함
  await Firebase.initializeApp(); // firebase 앱 시작
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => BucketModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  @override
  void initState() {
    setRemoteSetting();
    super.initState();
  }

  void setRemoteSetting() async {
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    await remoteConfig.setDefaults(
      const {
        "TEST_TEXT": "LEFT",
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      home: user == null
          ? LoginPage(
              analytics: analytics,
              remoteConfig: remoteConfig,
            )
          : HomePage(
              analytics: analytics,
              remoteConfig: remoteConfig,
              direction: remoteConfig.getString('TEST_TEXT'),
            ),
    );
  }
}
