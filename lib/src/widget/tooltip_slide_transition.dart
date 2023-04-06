import 'package:flutter/material.dart';

class ToolTipSlideTransition extends AnimatedWidget {
  const ToolTipSlideTransition({
    required Listenable position,
    required this.child,
  }) : super(listenable: position);

  final Widget child;

  Animation<Offset> get _progress => listenable as Animation<Offset>;

  @override
  Widget build(BuildContext context) =>
      Transform.translate(offset: _progress.value, child: child);
}
