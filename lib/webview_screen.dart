import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({super.key, required this.title});

  final String title;

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  late final WebViewController controller;
  var loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    var judul = widget.title.trim();
    if (judul == "Kecapi") {
      judul = "kacapi";
    } else if (judul == "Gender") {
      judul = "gender_(musik)";
    } else if (judul == "Serunai") {
      judul = "serunai_(alat_musik)";
    }
    controller = WebViewController()
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
      ))
      ..loadRequest(
        Uri.parse('https://id.wikipedia.org/wiki/$judul'),
      );
  }

  @override
  void dispose() {
    super.dispose();
    controller.clearLocalStorage();
    controller.clearCache();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            iconSize: 28,
            onPressed: () async {
              await controller.reload();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: loadWeb(),
    );
  }

  Widget loadWeb() {
    if (loadingPercentage < 100) {
      return LinearProgressIndicator(
        minHeight: 2,
        value: loadingPercentage / 100,
      );
    }
    return WebViewWidget(controller: controller);
  }
}
