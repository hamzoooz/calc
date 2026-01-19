import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:modern_calculator/providers/settings_provider.dart';

enum ButtonType {
  number,
  operator,
  function,
  action,
  equals,
  scientific,
}

class CalculatorButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final Color? textColor;
  final int flex;
  final ButtonType type;
  final double? fontSize;
  final IconData? icon;
  final bool useGlassmorphism;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.textColor,
    this.flex = 1,
    this.type = ButtonType.number,
    this.fontSize,
    this.icon,
    this.useGlassmorphism = true,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTap() {
    final settings = context.read<SettingsProvider>();

    // Haptic feedback
    if (settings.hapticEnabled) {
      HapticFeedback.lightImpact();
    }

    widget.onTap();
  }

  Color _getBackgroundColor(bool isDark) {
    if (widget.backgroundColor != null) return widget.backgroundColor!;

    switch (widget.type) {
      case ButtonType.number:
        return isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.9);
      case ButtonType.operator:
        return isDark
            ? const Color(0xFFFF9500).withOpacity(0.2)
            : const Color(0xFFFF9500).withOpacity(0.15);
      case ButtonType.function:
        return isDark
            ? const Color(0xFF00BFA5).withOpacity(0.2)
            : const Color(0xFF00BFA5).withOpacity(0.15);
      case ButtonType.action:
        return isDark
            ? const Color(0xFFFF3B30).withOpacity(0.2)
            : const Color(0xFFFF3B30).withOpacity(0.15);
      case ButtonType.equals:
        return isDark
            ? const Color(0xFF667eea)
            : const Color(0xFF667eea);
      case ButtonType.scientific:
        return isDark
            ? const Color(0xFF8B5CF6).withOpacity(0.2)
            : const Color(0xFF8B5CF6).withOpacity(0.15);
    }
  }

  Color _getTextColor(bool isDark) {
    if (widget.textColor != null) return widget.textColor!;

    switch (widget.type) {
      case ButtonType.number:
        return isDark ? Colors.white : const Color(0xFF1F2937);
      case ButtonType.operator:
        return isDark ? const Color(0xFFFFAB40) : const Color(0xFFFF9500);
      case ButtonType.function:
        return isDark ? const Color(0xFF1DE9B6) : const Color(0xFF00BFA5);
      case ButtonType.action:
        return isDark ? const Color(0xFFFF6B6B) : const Color(0xFFFF3B30);
      case ButtonType.equals:
        return Colors.white;
      case ButtonType.scientific:
        return isDark ? const Color(0xFFA78BFA) : const Color(0xFF8B5CF6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = _getBackgroundColor(isDark);
    final txtColor = _getTextColor(isDark);

    return Expanded(
      flex: widget.flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: _handleTap,
          onLongPress: widget.onLongPress,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: widget.useGlassmorphism && widget.type != ButtonType.equals
                ? _buildGlassButton(isDark, bgColor, txtColor)
                : _buildSolidButton(isDark, bgColor, txtColor),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton(bool isDark, Color bgColor, Color txtColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isPressed ? bgColor.withOpacity(0.8) : bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: _buildButtonContent(txtColor),
        ),
      ),
    );
  }

  Widget _buildSolidButton(bool isDark, Color bgColor, Color txtColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        gradient: widget.type == ButtonType.equals
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              )
            : null,
        color: widget.type != ButtonType.equals ? bgColor : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _isPressed
            ? []
            : [
                BoxShadow(
                  color: widget.type == ButtonType.equals
                      ? const Color(0xFF667eea).withOpacity(0.4)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: _buildButtonContent(txtColor),
    );
  }

  Widget _buildButtonContent(Color txtColor) {
    return Center(
      child: widget.icon != null
          ? Icon(
              widget.icon,
              color: txtColor,
              size: widget.fontSize ?? 26,
            )
          : Text(
              widget.label,
              style: TextStyle(
                fontSize: widget.fontSize ??
                    (widget.type == ButtonType.scientific ? 16 : 24),
                fontWeight: widget.type == ButtonType.number
                    ? FontWeight.w500
                    : FontWeight.w600,
                color: txtColor,
              ),
            ),
    );
  }
}
