import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Container()),
      body: WebView(
        initialUrl: 'https://www.example.com',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
        javascriptChannels: <JavascriptChannel>[
          JavascriptChannel(
            name: 'messageHandler',
            onMessageReceived: (JavascriptMessage message) {
              // Handle message received from JavaScript
              print('Message received: ${message.message}');
            },
          ),
        ].toSet(),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final WebViewController controller = await _controller.future;
            // Execute JavaScript function in WebView
            controller.evaluateJavascript("alert('Hello from Flutter!')");
          },
          child: AlarmPage()),
    );
  }
}

class AlarmPage extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarm Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _scheduleAlarm,
          child: Text('Set Alarm'),
        ),
      ),
    );
  }

  Future<void> _scheduleAlarm() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_channel',
      'Alarm',
      icon: 'app_icon',
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
      largeIcon: DrawableResourceAndroidBitmap('app_icon'),
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
      sound: 'alarm_sound.aiff',
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Set your alarm time here
    var scheduledTime = DateTime.now().add(Duration(seconds: 10));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Alarm',
      'Wake up!',
      scheduledTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alarm scheduled for $scheduledTime'),
      ),
    );
  }
}
