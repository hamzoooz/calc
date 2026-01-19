import 'package:flutter/material.dart';

class AppColors {
  // Primary Gradient
  static const Color primaryStart = Color(0xFF667eea);
  static const Color primaryEnd = Color(0xFF764ba2);

  // Secondary / Accent
  static const Color accent = Color(0xFF00d2ff);
  static const Color accentDark = Color(0xFF3a7bd5);

  // Backgrounds
  static const Color bgLight = Color(0xFFF5F7FA);
  static const Color bgDark = Color(0xFF0D1117);

  // Surfaces
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF161B22);

  // Card/Glass surfaces
  static const Color cardLight = Color(0xFFF8F9FA);
  static const Color cardDark = Color(0xFF21262D);

  // Text
  static const Color textLight = Color(0xFF1F2937);
  static const Color textDark = Color(0xFFF0F6FC);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textSecondaryDark = Color(0xFF8B949E);

  // Functional Colors
  static const Color operator = Color(0xFFFF9500);
  static const Color operatorDark = Color(0xFFFFAB40);
  static const Color function = Color(0xFF00BFA5);
  static const Color functionDark = Color(0xFF1DE9B6);
  static const Color delete = Color(0xFFFF3B30);
  static const Color deleteDark = Color(0xFFFF6B6B);
  static const Color equals = Color(0xFF667eea);
  static const Color equalsDark = Color(0xFF818CF8);

  // Scientific button colors
  static const Color scientific = Color(0xFF8B5CF6);
  static const Color scientificDark = Color(0xFFA78BFA);

  // Mode-specific colors
  static const Color matrix = Color(0xFF06B6D4);        // Cyan
  static const Color matrixDark = Color(0xFF22D3EE);
  static const Color equations = Color(0xFFF59E0B);     // Amber
  static const Color equationsDark = Color(0xFFFBBF24);
  static const Color statistics = Color(0xFF10B981);    // Emerald
  static const Color statisticsDark = Color(0xFF34D399);

  // Tab indicator colors
  static const Color tabActive = Color(0xFF667eea);
  static const Color tabInactive = Color(0xFF6B7280);

  // History colors
  static const Color historyBg = Color(0xFFF1F5F9);
  static const Color historyBgDark = Color(0xFF1E2430);

  // Input field colors
  static const Color inputBgLight = Color(0xFFF3F4F6);
  static const Color inputBgDark = Color(0xFF1F2937);
  static const Color inputBorderLight = Color(0xFFE5E7EB);
  static const Color inputBorderDark = Color(0xFF374151);

  // Success/Error colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Glassmorphism
  static Color glassLight = Colors.white.withOpacity(0.7);
  static Color glassDark = Colors.white.withOpacity(0.1);
  static Color glassBorder = Colors.white.withOpacity(0.2);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStart, primaryEnd],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00d2ff), Color(0xFF3a7bd5)],
  );

  static const LinearGradient matrixGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
  );

  static const LinearGradient equationsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
  );

  static const LinearGradient statisticsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), Color(0xFF10B981)],
  );

  static const LinearGradient scientificGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
  );

  static LinearGradient darkBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      const Color(0xFF0D1117),
      const Color(0xFF161B22),
    ],
  );

  /// Get color for calculator mode
  static Color getModeColor(String mode, bool isDark) {
    switch (mode) {
      case 'standard':
        return isDark ? primaryEnd : primaryStart;
      case 'scientific':
        return isDark ? scientificDark : scientific;
      case 'matrix':
        return isDark ? matrixDark : matrix;
      case 'equations':
        return isDark ? equationsDark : equations;
      case 'statistics':
        return isDark ? statisticsDark : statistics;
      default:
        return isDark ? primaryEnd : primaryStart;
    }
  }

  /// Get gradient for calculator mode
  static LinearGradient getModeGradient(String mode) {
    switch (mode) {
      case 'standard':
        return primaryGradient;
      case 'scientific':
        return scientificGradient;
      case 'matrix':
        return matrixGradient;
      case 'equations':
        return equationsGradient;
      case 'statistics':
        return statisticsGradient;
      default:
        return primaryGradient;
    }
  }
}
