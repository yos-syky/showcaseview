import 'dart:math';

import 'package:flutter/material.dart';

class GradientHelper {
  GradientHelper({
    required this.screenSize,
    required this.key,
    required this.rect,
  }) {
    position = rect.center;
    print(position);
    fractionalLocation = _getFractionLocation();
  }

  final Size screenSize;
  final GlobalKey key;
  final Rect rect;
  Offset? fractionalLocation;
  Offset? position;
  Size? widgetSize;

  Offset? _findPosition() {
    var box = key.currentContext?.findRenderObject() as RenderBox?;
    widgetSize = box?.size;
    return box?.localToGlobal(Offset.zero);
  }

  Offset _getFractionLocation() {
    return Offset(
      position!.dx / screenSize.width,
      position!.dy / screenSize.height,
    );
  }

  LocationOnScreen _findLocationOnScreen() {
    if (position == null) {
      return LocationOnScreen.unknown;
    } else {
      if (position!.dx == screenSize.width / 2 &&
          position!.dy == screenSize.height / 2) {
        return LocationOnScreen.center;
      } else if (position!.dx == screenSize.width / 2 && position!.dy == 0) {
        return LocationOnScreen.topCenter;
      } else if (position!.dx == screenSize.width / 2 &&
          position!.dy == screenSize.height - rect.height) {
        return LocationOnScreen.bottomCenter;
      } else if (position!.dx < screenSize.width / 2 &&
          position!.dx > (screenSize.width / 4) * 3 &&
          position!.dy < (screenSize.height / 2)) {
        return LocationOnScreen.topMiddle;
      } else if (position!.dx < screenSize.width / 4 &&
          position!.dy > screenSize.height / 2) {
        return LocationOnScreen.bottomLeft;
      } else if (position!.dx > (screenSize.width / 4) * 3 &&
          position!.dy > screenSize.height / 2) {
        return LocationOnScreen.bottomRight;
      } else if (position!.dx > screenSize.width / 2 &&
          position!.dx < (screenSize.width / 4) * 3 &&
          position!.dy > screenSize.height / 2) {
        return LocationOnScreen.bottomMiddle;
      } else if (position!.dx < screenSize.width / 4 &&
          position!.dy < screenSize.height / 4) {
        return LocationOnScreen.topLeft;
      } else if (position!.dx > (screenSize.width * 3) / 4 &&
          position!.dy < screenSize.height / 2) {
        return LocationOnScreen.topRight;
      }
      return LocationOnScreen.unknown;
    }
  }

  LinearGradient? getGradient({
    required List<Color> colors,
    Alignment begin = Alignment.topCenter,
    Alignment end = Alignment.bottomCenter,
  }) {
    final location = _findLocationOnScreen();
    print(location.name);
    if (location == LocationOnScreen.unknown) return null;
    var lg = LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
      stops: getStops(colors.length, location),
      transform: getGradientRotation(location),
    );

    return lg;
  }

  List<double> getStops(int length, LocationOnScreen locationOnScreen) {
    if (length == 2) {
      return [0, 1];
    } else if (length > 9) {
      return [];
    }
    switch (locationOnScreen) {
      case LocationOnScreen.topLeft:
        return [
          fractionalLocation!.dy * .5,
          ...List.generate(length - 2, (index) => fractionalLocation!.dy + .1),
          1
        ];
      case LocationOnScreen.topRight:
      case LocationOnScreen.bottomLeft:
      case LocationOnScreen.bottomRight:
      case LocationOnScreen.topCenter:
      case LocationOnScreen.bottomCenter:
      case LocationOnScreen.center:
      case LocationOnScreen.topMiddle:
      case LocationOnScreen.bottomMiddle:
      case LocationOnScreen.aroundTopLeft:
      case LocationOnScreen.aroundTopRight:
      case LocationOnScreen.aroundBottomLeft:
      case LocationOnScreen.aroundBottomRight:
        return [
          fractionalLocation!.dy,
          fractionalLocation!.dy + .1,
          ...List.generate(length - 3, (index) => fractionalLocation!.dy + .15),
          1
        ];
      case LocationOnScreen.unknown:
        return [];
    }
  }

  GradientRotation getGradientRotation(LocationOnScreen locationOnScreen) {
    switch (locationOnScreen) {
      case LocationOnScreen.topLeft:
        return const GradientRotation(5.4);
      case LocationOnScreen.topRight:
        return const GradientRotation(.8);
      case LocationOnScreen.bottomLeft:
        return const GradientRotation(.9);
      case LocationOnScreen.bottomRight:
        return const GradientRotation(2.5);
      case LocationOnScreen.topCenter:
        // TODO: Handle this case.
        break;
      case LocationOnScreen.bottomCenter:
        // TODO: Handle this case.
        break;
      case LocationOnScreen.center:
        // TODO: Handle this case.
        break;
      case LocationOnScreen.topMiddle:
        // TODO: Handle this case.
        break;
      case LocationOnScreen.bottomMiddle:
        // TODO: Handle this case.
        break;
      case LocationOnScreen.aroundTopLeft:
        // TODO: Handle this case.
        break;
      case LocationOnScreen.aroundTopRight:
        // TODO: Handle this case.
        break;
      case LocationOnScreen.aroundBottomLeft:
        // TODO: Handle this case.
        break;
      case LocationOnScreen.aroundBottomRight:
        // TODO: Handle this case.
        break;
      case LocationOnScreen.unknown:
        return const GradientRotation(0);
    }
    return const GradientRotation(0);
  }
}

enum LocationOnScreen {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  topCenter,
  bottomCenter,
  center,
  topMiddle,
  bottomMiddle,
  aroundTopLeft,
  aroundTopRight,
  aroundBottomLeft,
  aroundBottomRight,
  unknown
}
