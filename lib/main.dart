import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'package:mynote/common/global.dart';

import 'package:mynote/page/note/note.dart';
import 'package:mynote/page/auth/login.dart';

import 'package:mynote/provider/auth.dart';

import 'package:mynote/providers.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/timezone.dart' as tz;

import 'package:timezone/data/latest_all.dart' as tz;

void setupTimezone() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


void initializeNotifications() {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: DarwinInitializationSettings(),
  );

  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting("id", null);

  runApp(MultiProvider(
    providers: providers,
    child: const MyApp()
  ));

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  late AuthNotifier authNotifier;

  Future<void> getData() async {
    await Permission.scheduleExactAlarm.request();
    await Permission.notification.request();
  }

  @override 
  void initState() {
    super.initState();

    authNotifier = context.read<AuthNotifier>();

    Future.microtask(() => getData());

    setupTimezone();
    initializeNotifications();
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Harian',
      debugShowCheckedModeBanner: true,
      scaffoldMessengerKey: scaffoldKey,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: authNotifier.isLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }
          bool isLoggedIn = snapshot.data!;
          return isLoggedIn 
          ? const NotePage() 
          : const LoginPage();
        },
      )
    );
  }
}