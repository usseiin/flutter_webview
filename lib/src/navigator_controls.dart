import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NavigatorControls extends StatelessWidget {
  const NavigatorControls({super.key, required this.controller});
  final WebViewController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: () async {
              final message = ScaffoldMessenger.of(context);
              if (await controller.canGoBack()) {
                controller.goBack();
              } else {
                message.showSnackBar(
                    const SnackBar(content: Text("No back history item")));
                return;
              }
            },
            icon: const Icon(Icons.arrow_back_ios)),
        IconButton(
            onPressed: () async {
              final message = ScaffoldMessenger.of(context);
              if (await controller.canGoForward()) {
                controller.goForward();
              } else {
                message.showSnackBar(
                    const SnackBar(content: Text("No forward history item")));
                return;
              }
            },
            icon: const Icon(Icons.arrow_forward_ios)),
        IconButton(
            onPressed: () {
              controller.reload();
            },
            icon: const Icon(Icons.replay))
      ],
    );
  }
}
