import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

enum QuizCorrectness { correct, incorrect, neutral }

class QuizCorrectnessPill extends StatelessWidget {
  const QuizCorrectnessPill({
    super.key,
    required this.correctness,
    this.correctLabel = 'Correct',
    this.incorrectLabel = 'Incorrect',
  });

  final QuizCorrectness correctness;
  final String correctLabel;
  final String incorrectLabel;

  @override
  Widget build(BuildContext context) {
    final (Color accent, String label, IconData icon) = switch (correctness) {
      QuizCorrectness.correct => (AppColors.success, correctLabel, Icons.check),
      QuizCorrectness.incorrect => (
        AppColors.danger,
        incorrectLabel,
        Icons.close,
      ),
      QuizCorrectness.neutral => (
        Theme.of(context).colorScheme.primary,
        '',
        Icons.info_outline,
      ),
    };

    if (correctness == QuizCorrectness.neutral) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withAlpha(20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class QuizMetricTile extends StatelessWidget {
  const QuizMetricTile({
    super.key,
    required this.icon,
    required this.accentColor,
    required this.label,
    required this.value,
    this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final Color accentColor;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.card);
    final bg = isActive ? accentColor.withAlpha(20) : Theme.of(context).colorScheme.surface;
    final borderColor = isActive ? accentColor : Theme.of(context).dividerColor;

    final tile = Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: borderColor, width: isActive ? 2 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 2),
                    Text(label, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap == null) return tile;

    return Semantics(button: true, selected: isActive, child: tile);
  }
}

class AnswerOptionTile extends StatelessWidget {
  const AnswerOptionTile({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final radius = BorderRadius.circular(AppRadii.card);

    return Material(
      color: isSelected ? primary.withAlpha(20) : Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: isSelected ? primary : Theme.of(context).dividerColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? primary : AppColors.borderGray,
                    width: 2,
                  ),
                  color: isSelected ? primary : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReviewAnswerTile extends StatelessWidget {
  const ReviewAnswerTile({
    super.key,
    required this.label,
    required this.answerText,
    required this.correctness,
  });

  final String label;
  final String answerText;
  final QuizCorrectness correctness;

  @override
  Widget build(BuildContext context) {
    final (Color accent, IconData icon) = switch (correctness) {
      QuizCorrectness.correct => (AppColors.success, Icons.check_circle),
      QuizCorrectness.incorrect => (AppColors.danger, Icons.cancel),
      QuizCorrectness.neutral => (AppColors.textGray, Icons.info_outline),
    };

    final radius = BorderRadius.circular(AppRadii.card);

    return Material(
      color: accent.withAlpha(14),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: accent.withAlpha(80), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    answerText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
