import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:clora_user/screens/consult/consult_now_screen.dart';

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
          _buildGlassCard(
            context,
            icon: Icons.calendar_month,
            title: "Book\nAppointment",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConsultNowScreen()),
            ),
          ),
          _buildGlassCard(
            context,
            icon: Icons.shopping_bag_outlined,
            title: "Shop",
            onTap: () => _openWebView(context, "https://shop.getclora.com/", "Shop"),
          ),
          _buildGlassCard(
            context,
            icon: Icons.shopping_cart_outlined,
            title: "Order\nMedicine",
            onTap: () => _openWebView(context, "https://pharmeasy.in/", "Order Medicine"),
          ),
          _buildGlassCard(
            context,
            icon: Icons.science_outlined,
            title: "Diagnostic\nTests",
            onTap: () => _openWebView(context, "https://pharmeasy.in/diagnostics?src=homecard", "Diagnostic Tests"),
          ),
        ],
      ),
    );
  }

  /// 🔥 GLASS CARD
  Widget _buildGlassCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),

        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),

          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),

              /// 🔥 SAME GLASS STYLE
              color: Colors.white.withOpacity(0.25),

              border: Border.all(
                color: Colors.white.withOpacity(0.35),
              ),
            ),

            child: Row(
              children: [

                /// ICON BOX
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFFEC4899),
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                /// TEXT
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
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
}

class _GenericWebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const _GenericWebViewScreen({
    required this.url,
    required this.title,
  });

  @override
  State<_GenericWebViewScreen> createState() =>
      _GenericWebViewScreenState();
}

class _GenericWebViewScreenState
    extends State<_GenericWebViewScreen> {
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
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),

          /// LOADER
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}