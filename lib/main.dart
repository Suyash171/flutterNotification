import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String messageTitle = "Empty";
  String notificationAlert = "alert";

 // FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    setFirebase();

    /*    _firebaseMessaging.configure(
      onMessage: (message) async{
        setState(() {
          messageTitle = message["notification"]["title"];
          ///notificationAlert = "New Notification Alert";
          notificationAlert = message['notification']['body'];
          _showNotificationWithDefaultSound(messageTitle, notificationAlert);
        });
      },

      onResume: (message) async{
        setState(() {
          messageTitle = message["data"]["title"];
          notificationAlert = message['notification']['body'];
          //notificationAlert = "Application opened from Notification";
         // _showNotificationWithDefaultSound(messageTitle, notificationAlert);
        });
      },
    );*/

    var initializationSettingsAndroid =  AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(defaultPresentAlert: true, defaultPresentBadge: true, defaultPresentSound: true);
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
  }

  void _incrementCounter() {
    setState(() {
      //_counter++;
      _showNotificationWithDefaultSound('title', 'message');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notify"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              notificationAlert,
            ),
            Text(
              messageTitle,
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Future onSelectNotification(String payload) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Here is your payload"),
        content: Text('Payload: $payload'),
      ),
    );
  }

  Future<void> setFirebase() async {
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure(
        onMessage: (message) async {
          print(message);
          if (Platform.isIOS) {
            _showNotificationWithDefaultSound(
              message['aps']['alert']['title'],
              message['aps']['alert']['body'],
            );
          } else {
            _showNotificationWithDefaultSound(
              message['notification']['title'],
              message['notification']['body'],
            );
          }
        },
        onLaunch: (message) async {
          print(message['data']['title']);
        },
        onResume: (message) async {
          print(message['data']['title']);
        },
        onBackgroundMessage:
        Platform.isAndroid ? myBackgroundMessageHandler : null,
      );

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      print("FirebaseMessaging token: $token");

      _initialized = true;
    }
  }

  Future _showNotificationWithDefaultSound(String title, String message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.max, priority: Priority.high);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      message,
      platformChannelSpecifics,
      payload: '',
    );
  }
}



Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}
