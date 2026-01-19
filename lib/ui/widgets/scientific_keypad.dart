import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:modern_calculator/providers/calculator_provider.dart';
import 'package:modern_calculator/providers/settings_provider.dart';
import 'package:modern_calculator/ui/widgets/calculator_button.dart';
import 'package:modern_calculator/core/constants/app_colors.dart';

class ScientificKeypad extends StatefulWidget {
  const ScientificKeypad({super.key});

  @override
  State<ScientificKeypad> createState() => _ScientificKeypadState();
}

class _ScientificKeypadState extends State<ScientificKeypad> {
  bool _isSecondMode = false;
  bool _isHyperbolicMode = false;

  @override
  Widget build(BuildContext context) {
    final calc = context.read<CalculatorProvider>();
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Mode toggles row
        Expanded(
          child: Row(
            children: [
              // 2nd mode toggle
              _buildModeToggle(
                isDark,
                '2nd',
                _isSecondMode,
                () => setState(() => _isSecondMode = !_isSecondMode),
                AppColors.scientific,
              ),
              // Hyperbolic mode toggle
              _buildModeToggle(
                isDark,
                'HYP',
                _isHyperbolicMode,
                () => setState(() => _isHyperbolicMode = !_isHyperbolicMode),
                AppColors.function,
              ),
              // Angle mode toggle
              CalculatorButton(
                label: settings.useRadians ? 'RAD' : 'DEG',
                type: ButtonType.scientific,
                fontSize: 14,
                onTap: () {
                  settings.toggleAngleMode();
                  calc.setRadiansMode(settings.useRadians);
                },
              ),
              // Factorial
              CalculatorButton(
                label: '!',
                type: ButtonType.scientific,
                fontSize: 18,
                onTap: () => calc.addToExpression('!'),
              ),
            ],
          ),
        ),
        // Trigonometric functions row
        Expanded(
          child: Row(
            children: [
              CalculatorButton(
                label: _getTrigLabel('sin'),
                type: ButtonType.scientific,
                fontSize: 13,
                onTap: () => calc.addFunction(_getTrigFunction('sin')),
              ),
              CalculatorButton(
                label: _getTrigLabel('cos'),
                type: ButtonType.scientific,
                fontSize: 13,
                onTap: () => calc.addFunction(_getTrigFunction('cos')),
              ),
              CalculatorButton(
                label: _getTrigLabel('tan'),
                type: ButtonType.scientific,
                fontSize: 13,
                onTap: () => calc.addFunction(_getTrigFunction('tan')),
              ),
              CalculatorButton(
                label: _isSecondMode ? 'csc' : 'π',
                type: ButtonType.scientific,
                fontSize: _isSecondMode ? 13 : 18,
                onTap: _isSecondMode
                    ? () => calc.addFunction('csc')
                    : () => calc.addToExpression('π'),
              ),
            ],
          ),
        ),
        // Logarithm and root functions row
        Expanded(
          child: Row(
            children: [
              CalculatorButton(
                label: _isSecondMode ? 'eˣ' : 'ln',
                type: ButtonType.scientific,
                fontSize: 14,
                onTap: _isSecondMode
                    ? () => calc.addFunction('exp')
                    : () => calc.addFunction('ln'),
              ),
              CalculatorButton(
                label: _isSecondMode ? '10ˣ' : 'log',
                type: ButtonType.scientific,
                fontSize: 14,
                onTap: _isSecondMode
                    ? () {
                        calc.addToExpression('10^');
                      }
                    : () => calc.addFunction('log'),
              ),
              CalculatorButton(
                label: _isSecondMode ? '³√' : '√',
                type: ButtonType.scientific,
                fontSize: 18,
                onTap: _isSecondMode
                    ? () => calc.addFunction('cbrt')
                    : () => calc.addFunction('sqrt'),
              ),
              CalculatorButton(
                label: _isSecondMode ? 'x³' : 'x²',
                type: ButtonType.scientific,
                fontSize: 14,
                onTap: _isSecondMode ? calc.cube : calc.square,
              ),
            ],
          ),
        ),
        // Power and special functions row
        Expanded(
          child: Row(
            children: [
              CalculatorButton(
                label: _isSecondMode ? 'sec' : 'e',
                type: ButtonType.scientific,
                fontSize: _isSecondMode ? 13 : 18,
                onTap: _isSecondMode
                    ? () => calc.addFunction('sec')
                    : () => calc.addToExpression('e'),
              ),
              CalculatorButton(
                label: _isSecondMode ? 'cot' : '^',
                type: ButtonType.scientific,
                fontSize: _isSecondMode ? 13 : 18,
                onTap: _isSecondMode
                    ? () => calc.addFunction('cot')
                    : () => calc.addToExpression('^'),
              ),
              CalculatorButton(
                label: _isSecondMode ? '|x|' : '1/x',
                type: ButtonType.scientific,
                fontSize: 14,
                onTap: _isSecondMode
                    ? () => calc.addFunction('abs')
                    : calc.inverse,
              ),
              CalculatorButton(
                label: _isSecondMode ? 'mod' : '%',
                type: ButtonType.function,
                onTap: _isSecondMode
                    ? () => calc.addToExpression(' mod ')
                    : () => calc.addToExpression('%'),
              ),
            ],
          ),
        ),
        // Row 1: AC, (), %, ÷
        Expanded(
          child: Row(
            children: [
              CalculatorButton(
                label: 'AC',
                type: ButtonType.action,
                onTap: calc.clear,
                onLongPress: calc.clearEntry,
              ),
              CalculatorButton(
                label: '( )',
                type: ButtonType.function,
                onTap: () => _handleBracket(calc),
              ),
              CalculatorButton(
                label: _isSecondMode ? '±' : '⌫',
                icon: _isSecondMode ? null : Icons.backspace_outlined,
                type: ButtonType.action,
                onTap: _isSecondMode ? calc.negate : calc.delete,
                onLongPress: _isSecondMode ? null : calc.clear,
              ),
              CalculatorButton(
                label: '÷',
                type: ButtonType.operator,
                onTap: () => calc.addToExpression('÷'),
              ),
            ],
          ),
        ),
        // Row 2: 7, 8, 9, ×
        Expanded(
          child: Row(
            children: [
              CalculatorButton(
                label: '7',
                type: ButtonType.number,
                onTap: () => calc.addToExpression('7'),
              ),
              CalculatorButton(
                label: '8',
                type: ButtonType.number,
                onTap: () => calc.addToExpression('8'),
              ),
              CalculatorButton(
                label: '9',
                type: ButtonType.number,
                onTap: () => calc.addToExpression('9'),
              ),
              CalculatorButton(
                label: '×',
                type: ButtonType.operator,
                onTap: () => calc.addToExpression('×'),
              ),
            ],
          ),
        ),
        // Row 3: 4, 5, 6, -
        Expanded(
          child: Row(
            children: [
              CalculatorButton(
                label: '4',
                type: ButtonType.number,
                onTap: () => calc.addToExpression('4'),
              ),
              CalculatorButton(
                label: '5',
                type: ButtonType.number,
                onTap: () => calc.addToExpression('5'),
              ),
              CalculatorButton(
                label: '6',
                type: ButtonType.number,
                onTap: () => calc.addToExpression('6'),
              ),
              CalculatorButton(
                label: '-',
                type: ButtonType.operator,
                onTap: () => calc.addToExpression('-'),
              ),
            ],
          ),
        ),
        // Row 4: 1, 2, 3, +
        Expanded(
          child: Row(
            children: [
              CalculatorButton(
                label: '1',
                type: ButtonType.number,
                onTap: () => calc.addToExpression('1'),
              ),
              CalculatorButton(
                label: '2',
                type: ButtonType.number,
                onTap: () => calc.addToExpression('2'),
              ),
              CalculatorButton(
                label: '3',
                type: ButtonType.number,
                onTap: () => calc.addToExpression('3'),
              ),
              CalculatorButton(
                label: '+',
                type: ButtonType.operator,
                onTap: () => calc.addToExpression('+'),
              ),
            ],
          ),
        ),
        // Row 5: 0, ., ⌫, =
        Expanded(
          child: Row(
            children: [
              CalculatorButton(
                label: '0',
                type: ButtonType.number,
                flex: 2,
                onTap: () => calc.addToExpression('0'),
              ),
              CalculatorButton(
                label: '.',
                type: ButtonType.number,
                onTap: () => calc.addToExpression('.'),
              ),
              CalculatorButton(
                label: '=',
                type: ButtonType.equals,
                onTap: calc.calculate,
                useGlassmorphism: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeToggle(
    bool isDark,
    String label,
    bool isActive,
    VoidCallback onTap,
    Color activeColor,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [activeColor, activeColor.withAlpha(200)],
                  )
                : null,
            color: isActive
                ? null
                : (isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(8)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withAlpha(100),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? Colors.white
                    : (isDark ? AppColors.textDark : AppColors.textLight),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTrigLabel(String base) {
    if (_isHyperbolicMode) {
      return _isSecondMode ? 'a${base}h' : '${base}h';
    }
    return _isSecondMode ? 'a$base' : base;
  }

  String _getTrigFunction(String base) {
    if (_isHyperbolicMode) {
      return _isSecondMode ? 'a${base}h' : '${base}h';
    }
    return _isSecondMode ? 'a$base' : base;
  }

  void _handleBracket(CalculatorProvider calc) {
    final expr = calc.expression;
    int openCount = 0;
    int closeCount = 0;

    for (var char in expr.split('')) {
      if (char == '(') openCount++;
      if (char == ')') closeCount++;
    }

    if (expr.isEmpty ||
        _isOperator(expr[expr.length - 1]) ||
        expr[expr.length - 1] == '(') {
      calc.addToExpression('(');
    } else if (openCount > closeCount &&
        (_isDigit(expr[expr.length - 1]) || expr[expr.length - 1] == ')')) {
      calc.addToExpression(')');
    } else {
      calc.addToExpression('(');
    }
  }

  bool _isOperator(String c) {
    return c == '+' || c == '-' || c == '×' || c == '÷' || c == '^';
  }

  bool _isDigit(String c) {
    return c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  }
}
