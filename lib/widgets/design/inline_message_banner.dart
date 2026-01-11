import 'package:flutter/material.dart';

enum InlineMessageVariant { info, warning, error, success }

class InlineMessageBanner extends StatelessWidget {
  const InlineMessageBanner({
    super.key,
    required this.message,
    this.title,
    this.variant = InlineMessageVariant.error,
  });

  final String message;
  final String? title;
  final InlineMessageVariant variant;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (Color accent, IconData icon) = switch (variant) {
      InlineMessageVariant.info => (scheme.primary, Icons.info_outline),
      InlineMessageVariant.warning => (Colors.amber.shade800, Icons.warning_amber_rounded),
      InlineMessageVariant.error => (scheme.error, Icons.error_outline),
      InlineMessageVariant.success => (Colors.green.shade700, Icons.check_circle_outline),
    };

    final bg = accent.withOpacity(0.08);
    final border = accent.withOpacity(0.25);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(message, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
