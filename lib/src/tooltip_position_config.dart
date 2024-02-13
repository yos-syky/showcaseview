import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

import 'enum.dart';
import 'tooltip_widget.dart';

class TooltipPositionConfig {
  TooltipPositionConfig({
    required this.position,
    required this.size,
    required this.screenSize,
    required this.widgetRect,
  });

  final TooltipPosition position;
  final Size size;
  final Size screenSize;
  final Rect? widgetRect;

  double? leftPosition;
  double? rightPosition;
  double? topPosition;
  double? arrowLeft;
  double? arrowRight;

  Alignment alignment = Alignment.center;
  Alignment scaleAnimAlign = Alignment.center;
  EdgeInsets padding = EdgeInsets.zero;
  EdgeInsets arrowPadding = EdgeInsets.zero;
  double offsetFactor = 0;
  Offset fractionalTranslation = Offset.zero;
  Tween<Offset> slideTween = Tween();

  void initialize() {
    leftPosition = _getLeft();
    rightPosition = _getRight(leftPosition);
    topPosition = _getTop();

    arrowLeft = _arrowLeft();
    arrowRight = _arrowRight();
    alignment = _getAlignment();
    scaleAnimAlign = _getScaleAlignment();

    padding = _contentPadding();
    arrowPadding = _arrowPadding();
    offsetFactor = _getOffsetFactor;
    fractionalTranslation = _getFractionalTranslation;
    slideTween = _getSlideTween;
  }

  double get _getOffsetFactor {
    switch (position) {
      case TooltipPosition.top:
        return -1;
      case TooltipPosition.left:
        return 0;
      case TooltipPosition.right:
      case TooltipPosition.bottom:
        return 1;
    }
  }

  Offset get _getFractionalTranslation {
    final offset = offsetFactor.clamp(-1, 0).toDouble();
    switch (position) {
      case TooltipPosition.top:
      case TooltipPosition.bottom:
        return Offset(0, offset);
      case TooltipPosition.left:
      case TooltipPosition.right:
        return Offset(offset, 0);
    }
  }

  Tween<Offset> get _getSlideTween {
    final offset = offsetFactor.clamp(-1, 0).toDouble();
    switch (position) {
      case TooltipPosition.top:
      case TooltipPosition.bottom:
        return Tween<Offset>(
          begin: Offset(0, offset * 0.1),
          end: const Offset(0, 0.1),
        );
      case TooltipPosition.right:
        return Tween<Offset>(
          begin: Offset(offset * 0.1, 0),
          end: const Offset(0.1, 0),
        );
      case TooltipPosition.left:
        return Tween<Offset>(
          begin: Offset(offset * 0.1, 0),
          end: const Offset(-0.1, 0),
        );
    }
  }

  Alignment _getScaleAlignment() {
    switch (position) {
      case TooltipPosition.top:
      case TooltipPosition.bottom:
        if (widgetRect == null) return Alignment.center;
        final widgetCenter = (widgetRect!.left + widgetRect!.right) * 0.5;
        final left = leftPosition == null ? 0 : widgetCenter - leftPosition!;
        var right = leftPosition == null
            ? (screenSize.width - widgetCenter) - (rightPosition ?? 0)
            : 0;

        final x = left == 0
            ? 1 - (2 * (right / size.width))
            : -1 + (2 * (left / size.width));

        final y = position.isBottom ||
                (screenSize.height * 0.5) < (widgetRect?.top ?? 0)
            ? -1.0
            : 1.0;

        return Alignment(x, y);
      case TooltipPosition.left:
        return Alignment.centerRight;
      case TooltipPosition.right:
        return Alignment.centerLeft;
    }
  }

  Alignment _getAlignment() {
    switch (position) {
      case TooltipPosition.top:
        return leftPosition == null
            ? Alignment.bottomRight
            : Alignment.bottomLeft;
      case TooltipPosition.bottom:
        return Alignment.topLeft;
      case TooltipPosition.left:
        return Alignment.centerRight;
      case TooltipPosition.right:
        return Alignment.centerLeft;
    }
  }

  EdgeInsets _arrowPadding() {
    switch (position) {
      case TooltipPosition.left:
        return const EdgeInsets.only(right: 22 - kDefaultArrowHeight);
      case TooltipPosition.top:
        return const EdgeInsets.only(bottom: 27 - kDefaultArrowHeight);
      case TooltipPosition.right:
        return const EdgeInsets.only(left: 22 - kDefaultArrowHeight);
      case TooltipPosition.bottom:
        return const EdgeInsets.only(top: 22 - kDefaultArrowHeight);
    }
  }

  EdgeInsets _contentPadding() {
    switch (position) {
      case TooltipPosition.left:
      case TooltipPosition.right:
        return EdgeInsets.zero;
      case TooltipPosition.top:
        return const EdgeInsets.only(bottom: kDefaultArrowHeight - 1);
      case TooltipPosition.bottom:
        return const EdgeInsets.only(top: kDefaultArrowHeight - 1);
    }
  }

  double? _arrowLeft() {
    switch (position) {
      case TooltipPosition.top:
      case TooltipPosition.bottom:
        if (widgetRect == null) return null;
        final widgetCenter = (widgetRect!.left + widgetRect!.right) * 0.5;
        return leftPosition == null
            ? null
            : widgetCenter - (kDefaultArrowWidth * 0.5) - leftPosition!;
      case TooltipPosition.left:
      case TooltipPosition.right:
        return leftPosition == null ? null : -(kDefaultArrowWidth * 0.4);
    }
  }

  double? _arrowRight() {
    switch (position) {
      case TooltipPosition.top:
      case TooltipPosition.bottom:
        if (widgetRect == null) return null;
        final widgetCenter = (widgetRect!.left + widgetRect!.right) * 0.5;
        return leftPosition == null
            ? (screenSize.width - widgetCenter) -
                (rightPosition ?? 0) -
                (kDefaultArrowWidth * 0.5)
            : null;
      case TooltipPosition.left:
      case TooltipPosition.right:
        return leftPosition == null ? -(kDefaultArrowWidth * 0.4) : null;
    }
  }

  double? _getLeft() {
    if (widgetRect == null) return null;
    switch (position) {
      case TooltipPosition.top:
      case TooltipPosition.bottom:
        final widgetCenter = (widgetRect!.left + widgetRect!.right) * 0.5;
        final leftPos = widgetCenter - (size.width * 0.5);
        return (leftPos + size.width) > screenSize.width
            ? null
            : max(kDefaultPaddingFromParent, leftPos);
      case TooltipPosition.left:
      case TooltipPosition.right:
        final space = widgetRect!.right + kDefaultPaddingFromParent;
        return (space + size.width) >= screenSize.width ? null : space;
    }
  }

  double? _getTop() {
    if (widgetRect == null) return null;
    switch (position) {
      case TooltipPosition.top:
        return widgetRect!.top + (offsetFactor * 3);
      case TooltipPosition.bottom:
        return widgetRect!.bottom + (offsetFactor * 3);
      case TooltipPosition.left:
      case TooltipPosition.right:
        final widgetCenterVertical =
            widgetRect!.top + ((widgetRect!.bottom - widgetRect!.top) * 0.5);
        final topPos = widgetCenterVertical - (size.height * 0.5);
        return topPos.isNegative ? null : topPos;
    }
  }

  double? _getRight(double? left) {
    if (widgetRect == null) return null;
    switch (position) {
      case TooltipPosition.top:
      case TooltipPosition.bottom:
        if (left == null || (left + size.width) > screenSize.width) {
          final widgetCenter = (widgetRect!.left + widgetRect!.right) * 0.5;
          final rightPosition = widgetCenter + (size.width * 0.5);
          return (rightPosition + size.width) > screenSize.width
              ? kDefaultPaddingFromParent
              : null;
        } else {
          return null;
        }
      case TooltipPosition.left:
      case TooltipPosition.right:
        if (left != null) return null;
        final widgetLeft = widgetRect!.left - kDefaultPaddingFromParent;
        return (widgetLeft - size.width).isNegative
            ? null
            : screenSize.width - widgetLeft;
    }
  }
}
