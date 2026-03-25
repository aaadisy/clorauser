import 'package:flutter/material.dart';

class CustomMarquee extends StatefulWidget {
  final Widget child;
  final Duration scrollDuration;
  final double blankSpace;

  const CustomMarquee({
    Key? key,
    required this.child,
    this.scrollDuration = const Duration(seconds: 10),
    this.blankSpace = 20.0,
  }) : super(key: key);

  @override
  _CustomMarqueeState createState() => _CustomMarqueeState();
}

class _CustomMarqueeState extends State<CustomMarquee>
    with SingleTickerProviderStateMixin {
  late ScrollController _controller;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.scrollDuration,
    )..addListener(() {
        if (_controller.hasClients) {
          _controller.jumpTo(_animationController.value *
              _controller.position.maxScrollExtent);
        }
      });

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _controller,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: [
          widget.child,
          SizedBox(width: widget.blankSpace),
          widget.child,
        ],
      ),
    );
  }
}
