import 'package:flutter/material.dart';

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.bordered = false,
    this.borderColor,
    this.borderWidth = 1,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool bordered;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final cardTheme = Theme.of(context).cardTheme;
    final shape =
        (cardTheme.shape as RoundedRectangleBorder?) ??
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    final borderedShape = RoundedRectangleBorder(
      borderRadius: shape.borderRadius,
      side: BorderSide(
        color: borderColor ?? Theme.of(context).dividerColor,
        width: borderWidth,
      ),
    );

    return Card(
      margin: margin ?? cardTheme.margin,
      elevation: bordered ? 0 : (cardTheme.elevation ?? 2),
      color: cardTheme.color,
      surfaceTintColor: cardTheme.surfaceTintColor,
      shape: bordered ? borderedShape : shape,
      child: Padding(padding: padding, child: child),
    );
  }
}
