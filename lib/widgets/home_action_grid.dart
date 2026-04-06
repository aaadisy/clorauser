import 'package:flutter/material.dart';
import 'package:clora_user/screens/consult/consult_now_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeActionGrid extends StatelessWidget {
  const HomeActionGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),

      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,

        children: [

          /// BOOK APPOINTMENT
          _buildImageCard(
            context,
            image: "assets/home/book.jpeg",
            title: "Book Appointment",
            subtitle: "Book doctor visits",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConsultNowScreen()),
            ),
          ),

          /// SHOP
          _buildImageCard(
            context,
            image: "assets/home/shop.jpeg",
            title: "Shop Now",
            subtitle: "Curated wellness store",
            onTap: () => _openWebView(
              context,
              "https://shop.getclora.com/",
              "Shop",
            ),
          ),

          /// ORDER MEDICINE
          _buildImageCard(
            context,
            image: "assets/home/order.jpeg",
            title: "Order Medicine",
            subtitle: "Get meds at home",
            onTap: () => _openWebView(
              context,
              "https://pharmeasy.in/",
              "Order Medicine",
            ),
          ),

          /// DIAGNOSTIC
          _buildImageCard(
            context,
            image: "assets/home/diagnostic.jpeg",
            title: "Diagnostic Tests",
            subtitle: "Book lab tests",
            onTap: () => _openWebView(
              context,
              "https://pharmeasy.in/diagnostics?src=homecard",
              "Diagnostic Tests",
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 IMAGE CARD (MAIN UI)
  Widget _buildImageCard(
      BuildContext context, {
        required String image,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,

      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),

        child: Stack(
          children: [

            /// BACKGROUND IMAGE
            Positioned.fill(
              child: Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            ),

            /// DARK GRADIENT OVERLAY
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.2),
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
              ),
            ),

            /// TEXT
            Positioned(
              left: 16,
              bottom: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
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

          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}