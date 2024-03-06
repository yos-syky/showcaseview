import 'package:flutter/material.dart';

enum TooltipPosition { above, below }

enum TooltipAlignment { left, center, right }

extension TooltipAlignmentX on TooltipAlignment {
  Alignment get value {
    switch (this) {
      case TooltipAlignment.left:
        return Alignment.centerLeft;
      case TooltipAlignment.right:
        return Alignment.centerRight;
      default:
        return Alignment.center;
    }
  }
}
