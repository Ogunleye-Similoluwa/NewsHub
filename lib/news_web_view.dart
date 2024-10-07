import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class NewsWebView extends StatelessWidget {
  final String url;

  const NewsWebView({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: url,
      appBar: AppBar(
        title: Text("NEWS NOW"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      withZoom: true,
      withLocalStorage: true,
      // hidden: true,
      initialChild: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}