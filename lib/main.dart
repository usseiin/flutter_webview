import 'package:app/src/menu.dart';
import 'package:app/src/navigator_controls.dart';
import 'package:app/src/webview_stack.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main(List<String> args) {
  runApp(const WebViewApp());
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..loadRequest(Uri.parse("https://flutter.dev"));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Webview App",
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Webview App"),
          actions: [
            NavigatorControls(controller: controller),
            Menu(controller: controller)
          ],
        ),
        body: WebviewStack(controller: controller),
      ),
    );
  }
}
