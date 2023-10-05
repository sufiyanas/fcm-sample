import 'dart:developer';
import 'package:fcm_testing/API/firebase_api.dart';
import 'package:fcm_testing/API/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().registerPushNotificationHandler();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? token;
  @override
  void initState() {
    gettoken();
    super.initState();
  }

  Future<void> gettoken() async {
    // Future.delayed(Duration(seconds: 2), () {
    token = await NotificationService().getDeviceToken();
    log(token.toString());
    setState(() {});
  }

  void _copyTextToClipboard() {
    Clipboard.setData(ClipboardData(text: token ?? "token null"));
    const snackBar = SnackBar(
      content: Text('Text copied to clipboard'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SelectableText(
              token.toString(),
            ),
            const SizedBox(
              height: 100,
            ),
            ElevatedButton(
                onPressed: _copyTextToClipboard,
                child: const Text("Copy to clipboard"))
          ],
        ),
      ),
    );
  }
}
