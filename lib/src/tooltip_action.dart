import 'package:flutter/material.dart';

import 'showcase_context_provider.dart';
import 'showcase_widget.dart';

class ToolTipAction extends StatelessWidget {
  const ToolTipAction.defaultAction({
    Key? key,
    this.actionOne,
    this.actionTwo,
    this.actionPadding = const EdgeInsets.only(top: 5),
    this.alignment = WrapAlignment.spaceBetween,
    this.crossAxisAlignment = WrapCrossAlignment.center,
  })  : actions = null,
        super(key: key);

  const ToolTipAction.customAction({
    Key? key,
    this.actions,
    this.actionPadding = const EdgeInsets.only(top: 5),
    this.alignment = WrapAlignment.spaceBetween,
    this.crossAxisAlignment = WrapCrossAlignment.center,
  })  : actionOne = null,
        actionTwo = null,
        super(key: key);

  /// Define configuration of first action
  final ActionWidgetConfig? actionOne;

  /// Define configuration of second action
  final ActionWidgetConfig? actionTwo;

  /// Define padding of action widget
  final EdgeInsets? actionPadding;

  /// Define configuration of list of action
  final List<ActionWidgetConfig>? actions;

  /// Define alignment of actions
  final WrapAlignment alignment;

  /// Define crossAxisAlignment of actions
  final WrapCrossAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final showcaseContext = ShowcaseContextProvider.of(context)?.context;
    return Padding(
      padding: actionPadding ?? EdgeInsets.zero,
      child: Wrap(
        alignment: alignment,
        crossAxisAlignment: crossAxisAlignment,
        children: actions != null
            ? [for (final action in actions!) getActionWidget(action)]
            : [
                getActionWidget(
                  actionOne ??
                      ActionWidgetConfig(
                        actionTitle: 'Prev',
                        onActionTap: () {
                          if (showcaseContext == null) return;
                          ShowCaseWidget.of(showcaseContext).previous();
                        },
                      ),
                ),
                getActionWidget(
                  actionTwo ??
                      ActionWidgetConfig(
                        actionTitle: 'Next',
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(10),
                        onActionTap: () {
                          if (showcaseContext == null) return;
                          ShowCaseWidget.of(showcaseContext).next();
                        },
                      ),
                )
              ],
      ),
    );
  }

  Widget getActionWidget(ActionWidgetConfig? actionWidgetConfig) {
    if (actionWidgetConfig == null) return const SizedBox();
    return GestureDetector(
      onTap: actionWidgetConfig.onActionTap,
      child: Container(
        decoration: actionWidgetConfig.decoration,
        padding: actionWidgetConfig.padding,
        margin: actionWidgetConfig.margin,
        child: Text(
          actionWidgetConfig.actionTitle,
          style: actionWidgetConfig.textStyle,
          maxLines: 1,
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

  /// Defines title of action
  final String actionTitle;

  /// Defines decoration of action
  final BoxDecoration? decoration;

  /// Provide padding to the action
  final EdgeInsets? padding;

  /// Provide margin to the action
  final EdgeInsets? margin;

  /// Define text style of action
  final TextStyle? textStyle;

  /// Called when user tap on action
  final VoidCallback onActionTap;
}
