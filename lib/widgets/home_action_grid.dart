import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:clora_user/screens/consult/consult_now_screen.dart';
import 'package:clora_user/screens/shop_webview_screen.dart';

class HomeActionGrid extends StatelessWidget {
  const HomeActionGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.2,
        children: [
          _buildActionCard(
            context,
            icon: Icons.calendar_month,
            title: "Book\nAppointment",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConsultNowScreen())),
          ),
          _buildActionCard(
            context,
            icon: Icons.shopping_bag_outlined,
            title: "Shop",
            onTap: () => _openWebView(context, "https://shop.getclora.com/", "Shop"),
          ),
          _buildActionCard(
            context,
            icon: Icons.shopping_cart_outlined,
            title: "Order\nMedicine",
            onTap: () => _openWebView(context, "https://pharmeasy.in/", "Order Medicine"),
          ),
          _buildActionCard(
            context,
            icon: Icons.science_outlined,
            title: "Diagnostic\nTests",
            onTap: () => _openWebView(context, "https://pharmeasy.in/diagnostics?src=homecard", "Diagnostic Tests"),
          ),
        ],
      ),
    );
  }

  void _openWebView(BuildContext context, String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _GenericWebViewScreen(url: url, title: title),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F2F8), 
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
              ),
              child: Icon(icon, color: const Color(0xFF6B4E71), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenericWebViewScreen extends StatefulWidget {
  final String url;
  final String title;
  const _GenericWebViewScreen({required this.url, required this.title});

  @override
  State<_GenericWebViewScreen> createState() => _GenericWebViewScreenState();
}

class _GenericWebViewScreenState extends State<_GenericWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.pinkAccent),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
