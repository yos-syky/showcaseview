import 'package:flutter/material.dart';

class ToolTipAction extends StatelessWidget {
  const ToolTipAction({
    Key? key,
    required this.prev,
    required this.next,
    this.actionPadding,
  }) : super(key: key);

  final ActionWidgetConfig prev;
  final ActionWidgetConfig next;
  final EdgeInsets? actionPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: actionPadding ?? const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          getActionWidget(prev),
          getActionWidget(next),
        ],
      ),
    );
  }

  Widget getActionWidget(ActionWidgetConfig actionWidgetConfig) {
    return GestureDetector(
      onTap: actionWidgetConfig.onActionTap,
      child: Container(
        decoration: actionWidgetConfig.decoration,
        padding: actionWidgetConfig.padding,
        margin: actionWidgetConfig.margin,
        child: Text(
          actionWidgetConfig.actionTitle,
          style: actionWidgetConfig.textStyle,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class ActionWidgetConfig {
  const ActionWidgetConfig({
    Key? key,
    required this.actionTitle,
    this.decoration,
    this.padding,
    this.margin,
    this.textStyle,
    required this.onActionTap,
  });

  final String actionTitle;
  final BoxDecoration? decoration;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final TextStyle? textStyle;
  final VoidCallback onActionTap;
}
