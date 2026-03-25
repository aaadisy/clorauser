import 'package:clora_user/extensions/extension_util/bool_extensions.dart';
import 'package:flutter/material.dart';
import '../../extensions/colors.dart';
import '../../extensions/widgets.dart';

class CommonScaffoldComponent extends StatelessWidget {
  final String? appBarTitle;
  final Widget? body;
  final bool? showBack;
  final PreferredSizeWidget? appBar;
  final List<Widget>? action;
  final bool? extendedBody;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? bottom;
  final bool? resizeToAvoidBottomInset;

  const CommonScaffoldComponent(
      {this.appBarTitle,
      this.body,
      this.action,
      this.appBar,
      this.showBack = true,
      this.extendedBody = false,
      this.floatingActionButton,
      this.floatingActionButtonLocation,
      this.bottomNavigationBar,
      this.bottom,
      this.resizeToAvoidBottomInset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: extendedBody.validate(),
      resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
      backgroundColor: bgColor,
      appBar: appBar ??
          appBarWidget(appBarTitle ?? '',
              actions: action,
              showBack: showBack!,
              bottom: bottom,
              context1: context),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
