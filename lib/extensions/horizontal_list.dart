import 'package:flutter/material.dart';

class HorizontalList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double? spacing;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool reverse;
  final ScrollController? controller;

  HorizontalList({
    required this.itemCount,
    required this.itemBuilder,
    this.spacing,
    this.padding,
    this.physics,
    this.controller,
    this.reverse = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: physics,
      padding: padding ?? EdgeInsets.zero,
      scrollDirection: Axis.horizontal,
      reverse: reverse,
      controller: controller,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: EdgeInsets.only(
                right: spacing ?? 8), // Add spacing between items
            child: itemBuilder(context, index),
          ),
        ),
      ),
    );
  }
}
