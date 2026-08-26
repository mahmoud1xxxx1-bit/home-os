import 'package:flutter/material.dart';

Future<T?> showAppFormSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  EdgeInsetsGeometry contentPadding = const EdgeInsets.fromLTRB(24, 0, 24, 24),
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final viewInsets = MediaQuery.viewInsetsOf(sheetContext);
      final size = MediaQuery.sizeOf(sheetContext);

      return AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: size.height * .9),
          child: SingleChildScrollView(
            padding: contentPadding,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: builder(sheetContext),
          ),
        ),
      );
    },
  );
}
