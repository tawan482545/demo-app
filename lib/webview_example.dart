import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // ใช้ controller พื้นฐาน เหมาะกับ Android รุ่นเก่า
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                debugPrint('WebView loading: $progress%');
              },
              onPageStarted: (String url) {
                debugPrint('Started: $url');
              },
              onPageFinished: (String url) {
                debugPrint('Finished: $url');
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('Error: ${error.description}');
              },
            ),
          )
          ..loadRequest(
            Uri.parse(
              'https://teachablemachine.withgoogle.com/models/MwQofC9xN/',
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teachable Machine')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
