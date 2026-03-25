import 'dart:async';

import 'package:clora_user/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extensions.dart';

class NoInternetScreen extends StatefulWidget {
  @override
  _NoInternetScreenState createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startInternetCheck();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startInternetCheck() {
    debugPrint("isNetworkAvailable()");
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (await isNetworkAvailable()) {
        if (mounted) {
          pop();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Feather.wifi_off, size: 100, color: context.iconColor),
          16.height,
          Text(language.YourInternetIsNotWorking,
              style: boldTextStyle(size: textFontSize_20)),
        ],
      ).center(),
    );
  }
}
