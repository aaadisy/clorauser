import 'package:clora_user/extensions/text_styles.dart';
import 'package:flutter/material.dart';

class FullScreenDialogContent extends StatelessWidget {
  final List<dynamic>? imageUrls;
  final String? userName;
  final int? index;

  const FullScreenDialogContent(
      {Key? key, this.imageUrls, this.userName, this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            userName ?? '',
            style: primaryTextStyle(size: 20, color: Colors.black),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SafeArea(
          child: ListView.builder(
            itemCount: imageUrls?.length ?? 0,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrls?[index] ?? "",
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('Failed to load image'),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
