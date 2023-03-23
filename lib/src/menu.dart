import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum _MenuOption {
  navigationDelegate,
  userAgent,
  javaScriptChannel,
  listCookies,
  addCookies,
  removeCookies,
  clearCookies,
  setCookies,
  loadFlutterAsset,
  loadLocalFile,
  loadHTMLString
}

class Menu extends StatefulWidget {
  const Menu({super.key, required this.controller});

  final WebViewController controller;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final cookieManager = WebViewCookieManager();
  final _htmlString = '''<!DOCTYPE html>
      <!-- Copyright 2013 The Flutter Authors. All rights reserved.
      Use of this source code is governed by a BSD-style license that can be
      found in the LICENSE file. -->
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta http-equiv="X-UA-Compatible" content="IE=edge">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Document</title>
      </head>
      <body>
          <h1>Local demo page</h1>
          <p>
          This is an example page used to demonstrate how to load a local file or HTML
          string using the <a href="https://pub.dev/packages/webview_flutter">Flutter
          webview</a> plugin.
          </p>
      </body>
      </html>''';

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuOption>(
      onSelected: (value) async {
        switch (value) {
          case _MenuOption.navigationDelegate:
            await widget.controller
                .loadRequest(Uri.parse("https://www.youtube.com"));
            break;
          case _MenuOption.userAgent:
            final userAgent = await widget.controller
                .runJavaScriptReturningResult('navigator.userAgent');
            if (!mounted) return;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('$userAgent')));
            break;
          case _MenuOption.javaScriptChannel:
            await widget.controller.runJavaScript(
              '''
              var req = new XMLHttpRequest();
              req.open('GET', "https://api.ipify.org/?format=json");
              req.onload = function() {
                if (req.status == 200) {
                  let response = JSON.parse(req.responseText);
                  SnackBar.postMessage("IP Address: " + response.ip);
                } else {
                  SnackBar.postMessage("Error: " + req.status);
                }
              }
              req.send();''',
            );
            break;
          case _MenuOption.addCookies:
            await _onAddCookies(widget.controller);
            break;
          case _MenuOption.removeCookies:
            await _onRemoveCookies(widget.controller);
            break;
          case _MenuOption.setCookies:
            await _onSetCookies(widget.controller);
            break;
          case _MenuOption.listCookies:
            await _onListCookies(widget.controller);
            break;
          case _MenuOption.clearCookies:
            await _onClearCookies(widget.controller);
            break;
          case _MenuOption.loadFlutterAsset:
            await _onLoadFlutterAssetExample(widget.controller, context);
            break;
          case _MenuOption.loadHTMLString:
            await _onLoadHTMLStringExample(widget.controller, context);
            break;
          case _MenuOption.loadLocalFile:
            await _onLoadLocalFileExample(widget.controller, context);
            break;
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: _MenuOption.navigationDelegate,
            child: Text("Navigate to Youtube"),
          ),
          const PopupMenuItem(
            value: _MenuOption.userAgent,
            child: Text("Navigate to user-agent"),
          ),
          const PopupMenuItem(
            value: _MenuOption.javaScriptChannel,
            child: Text('Lookup IP location'),
          ),
          const PopupMenuItem(
            value: _MenuOption.addCookies,
            child: Text("Add cookies"),
          ),
          const PopupMenuItem(
            value: _MenuOption.clearCookies,
            child: Text('Clear cookies'),
          ),
          const PopupMenuItem(
            value: _MenuOption.listCookies,
            child: Text("List cookies"),
          ),
          const PopupMenuItem(
            value: _MenuOption.removeCookies,
            child: Text("Remove cookies"),
          ),
          const PopupMenuItem(
            value: _MenuOption.setCookies,
            child: Text("Set cookies"),
          ),
          const PopupMenuItem(
            value: _MenuOption.loadFlutterAsset,
            child: Text("Load flutter asset"),
          ),
          const PopupMenuItem(
            value: _MenuOption.loadHTMLString,
            child: Text("Load HTML string"),
          ),
          const PopupMenuItem(
            value: _MenuOption.loadLocalFile,
            child: Text("Load local file"),
          ),
        ];
      },
    );
  }

  Future<void> _onListCookies(WebViewController controller) async {
    final String cookies = await widget.controller
        .runJavaScriptReturningResult('document.cookies') as String;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cookies.isNotEmpty || cookies != 'null'
            ? cookies
            : 'There are no cookies'),
      ),
    );
  }

  Future<void> _onAddCookies(WebViewController controller) async {
    await widget.controller.runJavaScript(
      '''
      var date = new Date();
      date.setTime(date.getTime()+(30*24*60*60*1000);
      document.setCookies("FirstName = John, expires="+date.toGMTString());
      ''',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Custom cookies added')),
    );
  }

  Future<void> _onSetCookies(WebViewController controller) async {
    await cookieManager.setCookie(
      const WebViewCookie(name: 'foo', value: 'bar', domain: 'flutter.dev'),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie is set.'),
      ),
    );
  }

  Future<void> _onClearCookies(WebViewController controller) async {
    final bool hadCookies = await cookieManager.clearCookies();
    var message = "There were cookies. Now, they are gone";

    if (hadCookies) {
      message = 'There were no cookies to clear';
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _onRemoveCookies(WebViewController controller) async {
    await controller.runJavaScript(
        'document.cookie="FirstName=John; expires=Thu, 01 Jan 1970 00:00:00 UTC" ');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie removed.'),
      ),
    );
  }

  Future<void> _onLoadFlutterAssetExample(
      WebViewController controller, BuildContext context) async {
    await controller.loadFlutterAsset('assets/www/index.html');
  }

  Future<void> _onLoadHTMLStringExample(
      WebViewController controller, BuildContext context) async {
    await controller.loadHtmlString(_htmlString);
  }

  Future<void> _onLoadLocalFileExample(
      WebViewController controller, BuildContext context) async {
    final dir = await getTemporaryDirectory();
    final path = dir.path;
    final File indexFile = File('$path/www/index.html');

    await Directory('$path/www').create(recursive: true);
    final absoluteFilePath = await indexFile.writeAsString(_htmlString);

    controller.loadFile(absoluteFilePath.path);
  }
}
