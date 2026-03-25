import 'package:flutter/material.dart';

class HtmlEditScreen extends StatelessWidget {
  const HtmlEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("HTML Editor")),
      body: const Center(child: Text("HTML Editor Screen")),
    );
  }
}