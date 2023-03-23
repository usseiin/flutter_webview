import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewStack extends StatefulWidget {
  const WebviewStack({super.key, required this.controller});
  final WebViewController controller;

  @override
  State<WebviewStack> createState() => _WebviewStackState();
}

class _WebviewStackState extends State<WebviewStack> {
  int loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    widget.controller
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          setState(() {
            loadingPercentage = 0;
          });
        },
        onProgress: (progress) {
          setState(() {
            loadingPercentage = progress;
          });
        },
        onPageFinished: (url) {
          setState(() {
            loadingPercentage = 100;
          });
        },
        onNavigationRequest: (request) {
          final host = request.url;
          if (host.contains("youtube")) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("blocking navigation to $host")));
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'SnackBar',
        onMessageReceived: (message) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message.message)));
        },
      );
  }

  @override
  build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: widget.controller),
        if (loadingPercentage < 100)
          LinearProgressIndicator(value: loadingPercentage / 100),
      ],
    );
  }
}
