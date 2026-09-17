import 'package:flutter/material.dart';
import '../../core/errors/error_translator.dart';
import '../../core/constants/spacing.dart';

class ErrorStateView extends StatelessWidget {
  final Object error;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onSecondaryAction;

  const ErrorStateView({
    super.key,
    required this.error,
    required this.onPrimaryAction,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final info = ErrorTranslator.translate(error);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 40,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              Text(
                info.title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                info.explanation,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: onPrimaryAction,
                  child: Text(info.primaryActionLabel),
                ),
              ),
              if (onSecondaryAction != null &&
                  info.secondaryActionLabel != null) ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onSecondaryAction,
                    child: Text(info.secondaryActionLabel!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
