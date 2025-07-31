import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BlogWebViewScreen extends StatelessWidget {
  final String title;
  final String url;

  const BlogWebViewScreen({super.key, required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: WebViewWidget(
        controller: WebViewController()
          ..loadRequest(Uri.parse(url))
          ..setJavaScriptMode(JavaScriptMode.unrestricted),
      ),
    );
  }
}
