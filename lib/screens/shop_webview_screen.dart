import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ShopWebViewScreen extends StatefulWidget {
  const ShopWebViewScreen({Key? key}) : super(key: key);

  @override
  State<ShopWebViewScreen> createState() => _ShopWebViewScreenState();
}

class _ShopWebViewScreenState extends State<ShopWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(
        Uri.parse("https://shop.getclora.com/"),
      );
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }
    return true;
  }

  Future<void> _refreshPage() async {
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Shop"),
          backgroundColor: Colors.pink,
        ),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refreshPage,
              child: WebViewWidget(controller: _controller),
            ),

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
