import 'package:flutter/material.dart';

class PillTag extends StatelessWidget {
  const PillTag({
    super.key,
    required this.label,
    required this.color,
    this.backgroundAlpha = 28,
    this.borderAlpha = 64,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.textStyle,
  });

  final String label;
  final Color color;
  final int backgroundAlpha;
  final int borderAlpha;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.labelMedium;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withAlpha(backgroundAlpha),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(borderAlpha), width: 1),
      ),
      child: Text(
        label,
        style: (base ?? const TextStyle())
            .merge(textStyle)
            .copyWith(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}
