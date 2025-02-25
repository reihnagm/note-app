import 'package:flutter/material.dart';

class Bouncing extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPress;
  final VoidCallback? onLongPress;

  const Bouncing({
    required this.child, super.key, 
    required this.onPress,
    required this.onLongPress
  });

  @override
  BouncingState createState() => BouncingState();
}

class BouncingState extends State<Bouncing> with SingleTickerProviderStateMixin {
  Animation<double>? scale;
  AnimationController? controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
    scale = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: controller!, curve: Curves.ease));
  }

  
  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails event) {
        controller!.forward();
      },
      onTapUp: (TapUpDetails event) {
        if (widget.onPress != null) {
          controller!.reverse();
          widget.onPress!();
        }
      },
      onLongPress: () {
        if (widget.onLongPress != null) {
          widget.onLongPress!();
        }
      },
      onTapCancel: () {
        controller!.reverse();
      },
      child: ScaleTransition(
        scale: scale!,
        child: widget.child,
      ),
    );
  }
}
