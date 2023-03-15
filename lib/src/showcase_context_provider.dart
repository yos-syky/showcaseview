import 'package:flutter/material.dart';

/// This class is used to provide context of Showcase widget to Overlay so
/// that we can access ShowcaseWidget in widget tree from overlay.
class ShowcaseContextProvider extends InheritedWidget {
  final BuildContext context;

  const ShowcaseContextProvider({
    Key? key,
    required this.context,
    required Widget child,
  }) : super(key: key, child: child);

  static ShowcaseContextProvider? of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<ShowcaseContextProvider>();
    return result;
  }

  @override
  bool updateShouldNotify(ShowcaseContextProvider oldWidget) => false;
}
