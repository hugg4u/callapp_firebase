import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'api/firebase_api.dart';
import 'package:http/http.dart' as http;

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(),
      // routes: {
      //   NotificationScreen.route: (context) => const NotificationScreen(),
      // }
    );
  }
}

class HomeScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  HomeScreen({super.key});

  Future<void> sendMessage(String message) async {
    print(message);
    WebSocketChannel channel;

    try {
      channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:3000/'),
      );
      // channel.sink.add(jsonEncode(<String, String>{
      //   'token': token,
      // }));
      channel.sink.add(message);
      await channel.stream.listen((event) {
        if (kDebugMode) {
          print(event);
        }
        channel.sink.close();
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notification'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Message',
            ),
          ),
          ElevatedButton(
            onPressed: () => sendMessage(_controller.text),
            child: const Text('Send'),
          )
        ],
      ),
    );
  }
}
