import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:modern_calculator/providers/calculator_provider.dart';
import 'package:modern_calculator/providers/settings_provider.dart';
import 'package:modern_calculator/core/constants/app_colors.dart';
import 'package:modern_calculator/ui/widgets/display_panel.dart';
import 'package:modern_calculator/ui/widgets/standard_keypad.dart';
import 'package:modern_calculator/ui/widgets/scientific_keypad.dart';
import 'package:modern_calculator/ui/screens/history_screen.dart';
import 'package:modern_calculator/ui/screens/settings_screen.dart';
import 'package:modern_calculator/ui/screens/matrix_screen.dart';
import 'package:modern_calculator/ui/screens/equations_screen.dart';
import 'package:modern_calculator/ui/screens/statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_ModeTab> _modes = [
    _ModeTab(
      mode: CalculatorMode.standard,
      label: 'Standard',
      icon: Icons.calculate_outlined,
    ),
    _ModeTab(
      mode: CalculatorMode.scientific,
      label: 'Scientific',
      icon: Icons.science_outlined,
    ),
    _ModeTab(
      mode: CalculatorMode.matrix,
      label: 'Matrix',
      icon: Icons.grid_on_rounded,
    ),
    _ModeTab(
      mode: CalculatorMode.equations,
      label: 'Equations',
      icon: Icons.functions_rounded,
    ),
    _ModeTab(
      mode: CalculatorMode.statistics,
      label: 'Statistics',
      icon: Icons.bar_chart_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _modes.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsProvider>();
      final calc = context.read<CalculatorProvider>();
      calc.setRadiansMode(settings.useRadians);

      // Set initial tab based on saved mode
      int modeIndex = _modes.indexWhere((m) => m.mode == settings.calculatorMode);
      if (modeIndex >= 0) {
        _tabController.animateTo(modeIndex);
      }
    });

    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final settings = context.read<SettingsProvider>();
      settings.setCalculatorMode(_modes[_tabController.index].mode);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    SystemChrome.setSystemUIOverlayStyle(
      isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: AppColors.bgDark,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: AppColors.bgLight,
            ),
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Premium Mode Selector
            _buildModeSelector(isDark),

            // Content based on mode
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildCalculatorView(isDark, isLandscape, isScientific: false),
                  _buildCalculatorView(isDark, isLandscape, isScientific: true),
                  const MatrixScreen(),
                  const EquationsScreen(),
                  const StatisticsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(13)
                    : Colors.black.withAlpha(8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicator: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryStart.withAlpha(77),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                padding: const EdgeInsets.all(4),
                tabs: _modes.map((mode) => Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(mode.icon, size: 16),
                      const SizedBox(width: 6),
                      Text(mode.label),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Settings button
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withAlpha(13)
                  : Colors.black.withAlpha(8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: isDark ? AppColors.textDark : AppColors.textLight,
                size: 22,
              ),
              onPressed: _openSettings,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorView(bool isDark, bool isLandscape, {required bool isScientific}) {
    final settings = context.watch<SettingsProvider>();
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    if (isLandscape) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: DisplayPanel(onHistoryTap: _openHistory),
          ),
          Container(
            width: 1,
            margin: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  isDark
                      ? Colors.white.withAlpha(26)
                      : Colors.black.withAlpha(13),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: isScientific
                  ? const ScientificKeypad()
                  : const StandardKeypad(),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // Display panel
        Expanded(
          flex: isScientific ? 2 : 3,
          child: DisplayPanel(onHistoryTap: _openHistory),
        ),

        // Divider
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                isDark
                    ? Colors.white.withAlpha(26)
                    : Colors.black.withAlpha(13),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Keypad
        Expanded(
          flex: isScientific ? 6 : 5,
          child: Container(
            padding: EdgeInsets.all(isTablet ? 16 : 8),
            child: isScientific
                ? const ScientificKeypad()
                : const StandardKeypad(),
          ),
        ),
      ],
    );
  }
}

class _ModeTab {
  final CalculatorMode mode;
  final String label;
  final IconData icon;

  _ModeTab({
    required this.mode,
    required this.label,
    required this.icon,
  });
}
