import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:modern_calculator/providers/calculator_provider.dart';
import 'package:modern_calculator/ui/widgets/calculator_button.dart';

class StandardKeypad extends StatelessWidget {
  const StandardKeypad({super.key});

  @override
  Widget build(BuildContext context) {
    final calc = context.read<CalculatorProvider>();

    return Column(
      children: [
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
                label: '%',
                type: ButtonType.function,
                onTap: () => calc.addToExpression('%'),
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
                label: '⌫',
                icon: Icons.backspace_outlined,
                type: ButtonType.action,
                onTap: calc.delete,
                onLongPress: calc.clear,
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

  void _handleBracket(CalculatorProvider calc) {
    final expr = calc.expression;
    int openCount = 0;
    int closeCount = 0;

    for (var char in expr.split('')) {
      if (char == '(') openCount++;
      if (char == ')') closeCount++;
    }

    // If empty or last char is operator or open bracket, add open bracket
    if (expr.isEmpty ||
        _isOperator(expr[expr.length - 1]) ||
        expr[expr.length - 1] == '(') {
      calc.addToExpression('(');
    }
    // If there are unclosed brackets and last char is a number or close bracket
    else if (openCount > closeCount &&
        (_isDigit(expr[expr.length - 1]) || expr[expr.length - 1] == ')')) {
      calc.addToExpression(')');
    }
    // Otherwise add open bracket
    else {
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
