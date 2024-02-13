/*
 * Copyright (c) 2021 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'dart:math';

import 'package:flutter/material.dart';

import 'enum.dart';
import 'get_position.dart';
import 'measure_size.dart';
import 'tooltip_position_config.dart';

const kDefaultPaddingFromParent = 14.0;
const kDefaultArrowWidth = 18.0;
const kDefaultArrowHeight = 9.0;

class ToolTipWidget extends StatefulWidget {
  final GetPosition? position;
  final Offset? offset;
  final Size? screenSize;
  final String? title;
  final TextAlign? titleAlignment;
  final String? description;
  final TextAlign? descriptionAlignment;
  final TextStyle? titleTextStyle;
  final TextStyle? descTextStyle;
  final Widget? container;
  final Color? tooltipBackgroundColor;
  final Color? textColor;
  final bool showArrow;
  final double? contentHeight;
  final double? contentWidth;
  final VoidCallback? onTooltipTap;
  final EdgeInsets? tooltipPadding;
  final Duration movingAnimationDuration;
  final bool disableMovingAnimation;
  final bool disableScaleAnimation;
  final BorderRadius? tooltipBorderRadius;
  final Duration scaleAnimationDuration;
  final Curve scaleAnimationCurve;
  final Alignment? scaleAnimationAlignment;
  final bool isTooltipDismissed;
  final TooltipPosition? tooltipPosition;
  final EdgeInsets? titlePadding;
  final EdgeInsets? descriptionPadding;
  final TextDirection? titleTextDirection;
  final TextDirection? descriptionTextDirection;

  const ToolTipWidget({
    Key? key,
    required this.position,
    required this.offset,
    required this.screenSize,
    required this.title,
    required this.titleAlignment,
    required this.description,
    required this.titleTextStyle,
    required this.descTextStyle,
    required this.container,
    required this.tooltipBackgroundColor,
    required this.textColor,
    required this.showArrow,
    required this.contentHeight,
    required this.contentWidth,
    required this.onTooltipTap,
    required this.movingAnimationDuration,
    required this.descriptionAlignment,
    this.tooltipPadding = const EdgeInsets.symmetric(vertical: 8),
    required this.disableMovingAnimation,
    required this.disableScaleAnimation,
    required this.tooltipBorderRadius,
    required this.scaleAnimationDuration,
    required this.scaleAnimationCurve,
    this.scaleAnimationAlignment,
    this.isTooltipDismissed = false,
    this.tooltipPosition,
    this.titlePadding,
    this.descriptionPadding,
    this.titleTextDirection,
    this.descriptionTextDirection,
  }) : super(key: key);

  @override
  State<ToolTipWidget> createState() => _ToolTipWidgetState();
}

class _ToolTipWidgetState extends State<ToolTipWidget>
    with TickerProviderStateMixin {
  Offset? position;

  late final AnimationController _movingAnimationController;
  late final Animation<double> _movingAnimation;
  late final AnimationController _scaleAnimationController;
  late final Animation<double> _scaleAnimation;

  Size tooltipSize = Size.zero;
  double tooltipScreenEdgePadding = 20;
  double tooltipTextPadding = 15;

  late TooltipPositionConfig config;

  TooltipPosition findPositionForContent(Offset position) {
    if (widget.tooltipPosition != null) return widget.tooltipPosition!;

    final widgetPosition = widget.position;
    final screenSize = widget.screenSize ?? MediaQuery.of(context).size;

    var height = 120.0;
    height = widget.contentHeight ?? height;
    final bottomPosition =
        position.dy + ((widget.position?.getHeight() ?? 0) / 2);
    final EdgeInsets viewInsets = EdgeInsets.fromWindowPadding(
        WidgetsBinding.instance.window.viewInsets,
        WidgetsBinding.instance.window.devicePixelRatio);
    final double actualVisibleScreenHeight =
        screenSize.height - viewInsets.bottom;
    final hasSpaceInBottom =
        (actualVisibleScreenHeight - bottomPosition) >= height;

    if (hasSpaceInBottom) return TooltipPosition.bottom;

    final topPosition =
        position.dy - ((widget.position?.getHeight() ?? 0) * 0.5);
    final hasSpaceInTop = topPosition >= height;

    if (hasSpaceInTop) return TooltipPosition.top;

    if (widgetPosition == null) return TooltipPosition.bottom;

    final tooltipWidth = widget.container == null
        ? tooltipSize.width
        : widget.contentWidth ?? _customContainerSize.value.width;

    final leftPosition = widgetPosition.getLeft();
    final hasSpaceInLeft = !((leftPosition - tooltipWidth).isNegative);
    if (hasSpaceInLeft) return TooltipPosition.left;

    final rightPosition = widgetPosition.getRight();
    final hasSpaceInRight = (rightPosition + tooltipWidth) < screenSize.width;
    if (hasSpaceInRight) return TooltipPosition.right;

    return TooltipPosition.bottom;
  }

  Size _getTooltipSize() {
    final titleStyle = widget.titleTextStyle ??
        Theme.of(context)
            .textTheme
            .titleLarge!
            .merge(TextStyle(color: widget.textColor));
    final descriptionStyle = widget.descTextStyle ??
        Theme.of(context)
            .textTheme
            .titleSmall!
            .merge(TextStyle(color: widget.textColor));

    final tooltipPaddingOffset = Offset(
      (widget.tooltipPadding?.right ?? 0) + (widget.tooltipPadding?.left ?? 0),
      (widget.tooltipPadding?.top ?? 0) + (widget.tooltipPadding?.bottom ?? 0),
    );

    final titlePaddingOffset = Offset(
      (widget.titlePadding?.right ?? 0) + (widget.titlePadding?.left ?? 0),
      (widget.titlePadding?.top ?? 0) + (widget.titlePadding?.bottom ?? 0),
    );

    final descriptionPaddingOffset = Offset(
      (widget.descriptionPadding?.right ?? 0) +
          (widget.descriptionPadding?.left ?? 0),
      (widget.descriptionPadding?.top ?? 0) +
          (widget.descriptionPadding?.bottom ?? 0),
    );

    final titleSize = widget.title == null
        ? Size.zero
        : _textSize(widget.title!, titleStyle) +
            tooltipPaddingOffset +
            titlePaddingOffset;

    final descriptionSize = widget.description == null
        ? Size.zero
        : _textSize(widget.description!, descriptionStyle) +
            tooltipPaddingOffset +
            descriptionPaddingOffset;

    final totalWidth =
        max(titleSize.width, descriptionSize.width) + tooltipTextPadding;

    final totalHeight = (titleSize.height + descriptionSize.height) -
        // Making sure that `tooltipPaddingOffset.dy` isn't applied twice.
        (widget.title == null || widget.description == null
            ? 0
            : tooltipPaddingOffset.dy);

    final screenSizeOffset =
        ((widget.screenSize ?? MediaQuery.of(context).size) -
            Offset(tooltipScreenEdgePadding, tooltipScreenEdgePadding)) as Size;

    return Size(
      totalWidth.clamp(0, screenSizeOffset.width),
      totalHeight.clamp(0, screenSizeOffset.height),
    );
  }

  double _getSpace() {
    var space = widget.position!.getCenter() - (widget.contentWidth! / 2);
    if (space + widget.contentWidth! > widget.screenSize!.width) {
      space = widget.screenSize!.width - widget.contentWidth! - 8;
    } else if (space < (widget.contentWidth! / 2)) {
      space = 16;
    }
    return space;
  }

  final GlobalKey _customContainerKey = GlobalKey();
  final ValueNotifier<Size> _customContainerSize = ValueNotifier(Size.zero);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.container != null &&
          _customContainerKey.currentContext?.size != null) {
        // TODO: Is it wise to call setState here? All it is doing is setting
        // a value in ValueNotifier which does not require a setState to refresh anyway.
        setState(() {
          _customContainerSize.value =
              _customContainerKey.currentContext!.size!;
        });
      }
    });
    _movingAnimationController = AnimationController(
      duration: widget.movingAnimationDuration,
      vsync: this,
    );
    _movingAnimation = CurvedAnimation(
      parent: _movingAnimationController,
      curve: Curves.easeInOut,
    );
    _scaleAnimationController = AnimationController(
      duration: widget.scaleAnimationDuration,
      vsync: this,
      lowerBound: widget.disableScaleAnimation ? 1 : 0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleAnimationController,
      curve: widget.scaleAnimationCurve,
    );
    if (widget.disableScaleAnimation) {
      movingAnimationListener();
    } else {
      _scaleAnimationController
        ..addStatusListener((scaleAnimationStatus) {
          if (scaleAnimationStatus == AnimationStatus.completed) {
            movingAnimationListener();
          }
        })
        ..forward();
    }
    if (!widget.disableMovingAnimation) {
      _movingAnimationController.forward();
    }
  }

  void movingAnimationListener() {
    _movingAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _movingAnimationController.reverse();
      }
      if (_movingAnimationController.isDismissed) {
        if (!widget.disableMovingAnimation) {
          _movingAnimationController.forward();
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    tooltipSize = _getTooltipSize();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _movingAnimationController.dispose();
    _scaleAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: maybe all this calculation doesn't need to run here. Maybe all or some of it can be moved outside?
    position = widget.offset;
    config = getConfiguration(findPositionForContent(position!))..initialize();
    if (!widget.disableScaleAnimation && widget.isTooltipDismissed) {
      _scaleAnimationController.reverse();
    }

    if (widget.container == null) {
      return Positioned(
        top: config.topPosition,
        left: config.leftPosition,
        right: config.rightPosition,
        child: ScaleTransition(
          scale: _scaleAnimation,
          alignment: widget.scaleAnimationAlignment ?? config.scaleAnimAlign,
          child: FractionalTranslation(
            translation: config.fractionalTranslation,
            child: SlideTransition(
              position: config.slideTween.animate(_movingAnimation),
              child: Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding:
                      widget.showArrow ? config.arrowPadding : EdgeInsets.zero,
                  child: Stack(
                    alignment: config.alignment,
                    clipBehavior: Clip.none,
                    children: [
                      if (widget.showArrow)
                        Positioned(
                          left: config.arrowLeft,
                          right: config.arrowRight,
                          child: CustomPaint(
                            painter: _Arrow(
                              strokeColor: widget.tooltipBackgroundColor!,
                              strokeWidth: 10,
                              paintingStyle: PaintingStyle.fill,
                              position: config.position,
                            ),
                            child: SizedBox(
                              height: config.position.isVertical
                                  ? kDefaultArrowHeight
                                  : kDefaultArrowWidth,
                              width: config.position.isVertical
                                  ? kDefaultArrowWidth
                                  : kDefaultArrowHeight,
                            ),
                          ),
                        ),
                      Padding(
                        padding:
                            widget.showArrow ? config.padding : EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: widget.tooltipBorderRadius ??
                              BorderRadius.circular(8.0),
                          child: GestureDetector(
                            onTap: widget.onTooltipTap,
                            child: Container(
                              width: tooltipSize.width,
                              padding: widget.tooltipPadding,
                              color: widget.tooltipBackgroundColor,
                              child: Column(
                                crossAxisAlignment: widget.title != null
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.center,
                                children: <Widget>[
                                  if (widget.title != null)
                                    Padding(
                                      padding: widget.titlePadding ??
                                          EdgeInsets.zero,
                                      child: Text(
                                        widget.title!,
                                        textAlign: widget.titleAlignment,
                                        textDirection:
                                            widget.titleTextDirection,
                                        style: widget.titleTextStyle ??
                                            Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .merge(
                                                  TextStyle(
                                                    color: widget.textColor,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  Padding(
                                    padding: widget.descriptionPadding ??
                                        EdgeInsets.zero,
                                    child: Text(
                                      widget.description!,
                                      textAlign: widget.descriptionAlignment,
                                      textDirection:
                                          widget.descriptionTextDirection,
                                      style: widget.descTextStyle ??
                                          Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .merge(
                                                TextStyle(
                                                  color: widget.textColor,
                                                ),
                                              ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Stack(
      children: <Widget>[
        Positioned(
          top: (config.topPosition ?? 10) -
              (config.position.isVertical ? 10 : 0),
          left: config.position.isVertical ? _getSpace() : config.leftPosition,
          right: config.position.isVertical ? null : config.rightPosition,
          child: FractionalTranslation(
            translation: config.fractionalTranslation,
            child: SlideTransition(
              position: config.slideTween.animate(_movingAnimation),
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: widget.onTooltipTap,
                  child: Container(
                    padding: config.padding,
                    color: Colors.transparent,
                    child: Center(
                      child: MeasureSize(
                        key: _customContainerKey,
                        onSizeChange: onSizeChange,
                        child: widget.container,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void onSizeChange(Size? size) {
    var tempPos = position;
    tempPos = Offset(position!.dx, position!.dy + size!.height);
    setState(() => position = tempPos);
  }

  Size _textSize(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.size;
  }

  TooltipPositionConfig getConfiguration(TooltipPosition location) {
    return TooltipPositionConfig(
      position: location,
      size: widget.container == null ? tooltipSize : _customContainerSize.value,
      screenSize: widget.screenSize ?? MediaQuery.of(context).size,
      widgetRect: widget.position?.getRect(),
    );
  }
}

class _Arrow extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;
  final TooltipPosition position;
  final Paint _paint;

  /// Paints an Arrow to point towards the showcased widget.
  ///
  /// The pointed head of the arrow would be in the opposite direction of the
  /// tooltip [position].
  _Arrow({
    this.strokeColor = Colors.black,
    this.strokeWidth = 3,
    this.paintingStyle = PaintingStyle.stroke,
    this.position = TooltipPosition.bottom,
  }) : _paint = Paint()
          ..color = strokeColor
          ..strokeWidth = strokeWidth
          ..style = paintingStyle;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(getTrianglePath(size.width, size.height), _paint);
  }

  Path getTrianglePath(double x, double y) {
    switch (position) {
      case TooltipPosition.bottom:
        return Path()
          ..moveTo(0, y)
          ..lineTo(x * 0.5, 0)
          ..lineTo(x, y)
          ..lineTo(0, y);
      case TooltipPosition.top:
        return Path()
          ..moveTo(0, 0)
          ..lineTo(x, 0)
          ..lineTo(x * 0.5, y)
          ..lineTo(0, 0);
      case TooltipPosition.left:
        return Path()
          ..moveTo(0, 0)
          ..lineTo(x, y * 0.5)
          ..lineTo(0, y)
          ..lineTo(0, 0);
      case TooltipPosition.right:
        return Path()
          ..moveTo(x, 0)
          ..lineTo(0, y * 0.5)
          ..lineTo(x, y)
          ..lineTo(x, 0);
    }
  }

  @override
  bool shouldRepaint(covariant _Arrow oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
