import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomFAB extends StatefulWidget {
  final ScrollController? controller;
  final VoidCallback? onPressed;
  final Widget? child;

  const CustomFAB({
    super.key,
    required this.controller,
    this.onPressed,
    required this.child,
  });

  @override
  State<CustomFAB> createState() => _CustomFABState();
}

class _CustomFABState extends State<CustomFAB> {
  bool isVisible = true;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(() {
      if (widget.controller!.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (isVisible != false) {
          setState(() {
            isVisible = false;
          });
        }
      } else {
        if (isVisible != true) {
          setState(() {
            isVisible = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: FloatingActionButton(
        isExtended: isVisible,
        onPressed: widget.onPressed,
        child: widget.child,
      ),
    );
  }
}
