import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:modern_calculator/providers/calculator_provider.dart';
import 'package:modern_calculator/core/constants/app_colors.dart';

class DisplayPanel extends StatelessWidget {
  final VoidCallback? onHistoryTap;

  const DisplayPanel({super.key, this.onHistoryTap});

  void _copyToClipboard(BuildContext context, String text) {
    if (text.isEmpty || text == '0' || text == 'Error') return;

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isLandscape ? 12 : 20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Top bar with history button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (onHistoryTap != null)
                _buildGlassIconButton(
                  context,
                  Icons.history_rounded,
                  onHistoryTap!,
                  isDark,
                ),
              const Spacer(),
              // Angle mode indicator (for scientific mode)
              if (calc.useRadians)
                _buildModeChip(context, 'RAD', isDark)
              else
                _buildModeChip(context, 'DEG', isDark),
            ],
          ),

          const Spacer(),

          // Expression
          GestureDetector(
            onLongPress: () => _copyToClipboard(context, calc.expression),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                calc.expression.isEmpty ? ' ' : calc.expression,
                key: ValueKey(calc.expression),
                style: TextStyle(
                  fontSize: isLandscape ? 20 : 24,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.end,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Preview (real-time calculation)
          if (calc.preview.isNotEmpty && calc.preview != calc.result)
            AnimatedOpacity(
              opacity: calc.preview.isNotEmpty ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                '= ${calc.preview}',
                style: TextStyle(
                  fontSize: isLandscape ? 18 : 22,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? AppColors.accent.withOpacity(0.7)
                      : AppColors.accentDark.withOpacity(0.7),
                ),
                textAlign: TextAlign.end,
              ),
            ),

          const SizedBox(height: 12),

          // Result
          GestureDetector(
            onLongPress: () => _copyToClipboard(context, calc.result),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: AutoSizeText(
                calc.result,
                key: ValueKey(calc.result),
                style: TextStyle(
                  fontSize: isLandscape ? 48 : 64,
                  fontWeight: FontWeight.w300,
                  color: calc.hasError
                      ? (isDark ? AppColors.deleteDark : AppColors.delete)
                      : (isDark ? AppColors.textDark : AppColors.textLight),
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.end,
                maxLines: 1,
                minFontSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassIconButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
              ),
            ),
            child: Icon(
              icon,
              color: isDark ? AppColors.textDark : AppColors.textLight,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeChip(BuildContext context, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}
