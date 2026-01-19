import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:modern_calculator/providers/calculator_provider.dart';
import 'package:modern_calculator/data/models/history_item.dart';
import 'package:modern_calculator/core/constants/app_colors.dart';
import 'package:modern_calculator/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: Text(l10n.history),
        actions: [
          if (calc.history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showClearConfirmation(context),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.all),
            Tab(text: l10n.favorites),
          ],
          indicatorColor: AppColors.primaryStart,
          labelColor: isDark ? AppColors.textDark : AppColors.textLight,
          unselectedLabelColor:
              isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryList(calc.history, calc, l10n, isDark),
          _buildHistoryList(calc.favorites, calc, l10n, isDark),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    List<HistoryItem> items,
    CalculatorProvider calc,
    AppLocalizations l10n,
    bool isDark,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noHistory,
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildHistoryTile(item, calc, isDark);
      },
    );
  }

  Widget _buildHistoryTile(
    HistoryItem item,
    CalculatorProvider calc,
    bool isDark,
  ) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.delete,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => calc.deleteHistoryItem(item.id),
      child: InkWell(
        onTap: () {
          calc.useHistoryItem(item);
          Navigator.pop(context);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Expression
                    Text(
                      item.expression,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Result
                    Text(
                      '= ${item.result}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textDark : AppColors.textLight,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    const SizedBox(height: 8),
                    // Bottom row: timestamp and actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTimestamp(item.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                item.isFavorite
                                    ? Icons.star
                                    : Icons.star_border,
                                color: item.isFavorite
                                    ? Colors.amber
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
                                size: 20,
                              ),
                              onPressed: () => calc.toggleFavorite(item.id),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: Icon(
                                Icons.copy,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                                size: 20,
                              ),
                              onPressed: () =>
                                  _copyToClipboard(context, item.result),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: Icon(
                                Icons.share,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                                size: 20,
                              ),
                              onPressed: () => _shareCalculation(item),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(timestamp);
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
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

  void _shareCalculation(HistoryItem item) {
    Share.share('${item.expression} = ${item.result}');
  }

  void _showClearConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final calc = context.read<CalculatorProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearHistory),
        content: const Text('This will delete all non-favorite calculations.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              calc.clearNonFavoriteHistory();
              Navigator.pop(context);
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(color: AppColors.delete),
            ),
          ),
        ],
      ),
    );
  }
}
