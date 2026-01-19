import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modern_calculator/core/services/calculation_engine.dart';
import 'package:modern_calculator/data/models/history_item.dart';

class CalculatorProvider with ChangeNotifier {
  static const String _historyKey = 'calculation_history';
  static const int _maxHistoryItems = 50;

  final CalculationEngine _engine = CalculationEngine();

  String _expression = '';
  String _result = '0';
  String _preview = '';
  List<HistoryItem> _history = [];
  bool _useRadians = false;
  bool _hasError = false;

  // Getters
  String get expression => _expression;
  String get result => _result;
  String get preview => _preview;
  List<HistoryItem> get history => _history;
  List<HistoryItem> get favorites =>
      _history.where((item) => item.isFavorite).toList();
  bool get useRadians => _useRadians;
  bool get hasError => _hasError;

  CalculatorProvider() {
    _loadHistory();
  }

  // Load history from SharedPreferences
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];
      _history = historyJson
          .map((json) => HistoryItem.fromJson(jsonDecode(json)))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  // Save history to SharedPreferences
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson =
          _history.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }

  // Set angle mode (radians/degrees)
  void setRadiansMode(bool useRadians) {
    _useRadians = useRadians;
    _engine.useRadians = useRadians;
    notifyListeners();
  }

  // Add character to expression
  void addToExpression(String value) {
    _hasError = false;

    // If we just got a result and start with a number, clear
    if (_result != '0' && _expression.isEmpty && !_isOperator(value)) {
      _result = '0';
    }

    // If we have a result and add an operator, use the result
    if (_result != '0' && _expression.isEmpty && _isOperator(value)) {
      _expression = _result;
    }

    // Handle special cases
    if (value == '.' && _hasDecimalInCurrentNumber()) {
      return;
    }

    // Prevent consecutive operators
    if (_isOperator(value) && _expression.isNotEmpty) {
      String lastChar = _expression[_expression.length - 1];
      if (_isOperator(lastChar)) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    }

    _expression += value;
    _updatePreview();
    notifyListeners();
  }

  // Add function to expression (sin, cos, etc.)
  void addFunction(String func) {
    _hasError = false;
    _expression += '$func(';
    notifyListeners();
  }

  // Check if current number already has a decimal
  bool _hasDecimalInCurrentNumber() {
    // Find the last number in the expression
    int lastOperatorIndex = -1;
    for (int i = _expression.length - 1; i >= 0; i--) {
      if (_isOperator(_expression[i]) || _expression[i] == '(') {
        lastOperatorIndex = i;
        break;
      }
    }
    String currentNumber = _expression.substring(lastOperatorIndex + 1);
    return currentNumber.contains('.');
  }

  bool _isOperator(String c) {
    return c == '+' || c == '-' || c == '×' || c == '÷' || c == '^';
  }

  // Update real-time preview
  void _updatePreview() {
    if (_expression.isEmpty) {
      _preview = '';
      return;
    }

    // Try to calculate preview
    String previewResult = _engine.preview(_expression);
    if (previewResult.isNotEmpty && previewResult != 'Error') {
      _preview = previewResult;
    } else {
      _preview = '';
    }
  }

  // Clear all
  void clear() {
    _expression = '';
    _result = '0';
    _preview = '';
    _hasError = false;
    notifyListeners();
  }

  // Clear entry (current number only)
  void clearEntry() {
    if (_expression.isEmpty) return;

    // Remove last number or function
    int lastIndex = _expression.length - 1;
    while (lastIndex >= 0 &&
        !_isOperator(_expression[lastIndex]) &&
        _expression[lastIndex] != '(') {
      lastIndex--;
    }

    _expression = _expression.substring(0, lastIndex + 1);
    _updatePreview();
    notifyListeners();
  }

  // Delete last character
  void delete() {
    if (_expression.isNotEmpty) {
      // Check if we're deleting a function
      if (_expression.endsWith('(')) {
        // Check if there's a function name before the bracket
        List<String> functions = [
          'sin(',
          'cos(',
          'tan(',
          'log(',
          'ln(',
          'sqrt(',
          'abs(',
          'exp(',
          'asin(',
          'acos(',
          'atan('
        ];
        for (String func in functions) {
          if (_expression.endsWith(func)) {
            _expression =
                _expression.substring(0, _expression.length - func.length);
            _updatePreview();
            notifyListeners();
            return;
          }
        }
      }
      _expression = _expression.substring(0, _expression.length - 1);
      _hasError = false;
      _updatePreview();
      notifyListeners();
    }
  }

  // Calculate result
  void calculate() {
    if (_expression.isEmpty) return;

    String calcResult = _engine.calculate(_expression);

    if (calcResult == 'Error') {
      _hasError = true;
      _result = 'Error';
    } else {
      _hasError = false;
      // Add to history
      _addToHistory(_expression, calcResult);
      _result = calcResult;
      _expression = '';
      _preview = '';
    }

    notifyListeners();
  }

  // Add to history
  void _addToHistory(String expr, String res) {
    if (res == 'Error') return;

    final item = HistoryItem(
      expression: expr,
      result: res,
      timestamp: DateTime.now(),
    );

    _history.insert(0, item);

    // Limit history size
    if (_history.length > _maxHistoryItems) {
      // Remove oldest non-favorite items first
      _history = [
        ..._history.where((item) => item.isFavorite),
        ..._history
            .where((item) => !item.isFavorite)
            .take(_maxHistoryItems - _history.where((item) => item.isFavorite).length),
      ];
    }

    _saveHistory();
  }

  // Use history item
  void useHistoryItem(HistoryItem item) {
    _expression = item.result;
    _result = '0';
    _preview = '';
    notifyListeners();
  }

  // Toggle favorite
  void toggleFavorite(String id) {
    final index = _history.indexWhere((item) => item.id == id);
    if (index != -1) {
      _history[index] =
          _history[index].copyWith(isFavorite: !_history[index].isFavorite);
      _saveHistory();
      notifyListeners();
    }
  }

  // Delete history item
  void deleteHistoryItem(String id) {
    _history.removeWhere((item) => item.id == id);
    _saveHistory();
    notifyListeners();
  }

  // Clear all history
  void clearHistory() {
    _history.clear();
    _saveHistory();
    notifyListeners();
  }

  // Clear non-favorite history
  void clearNonFavoriteHistory() {
    _history.removeWhere((item) => !item.isFavorite);
    _saveHistory();
    notifyListeners();
  }

  // Copy result to clipboard
  Future<void> copyResult() async {
    await Clipboard.setData(ClipboardData(text: _result));
  }

  // Copy expression to clipboard
  Future<void> copyExpression() async {
    await Clipboard.setData(ClipboardData(text: _expression));
  }

  // Negate current number
  void negate() {
    if (_expression.isEmpty) {
      if (_result != '0' && _result != 'Error') {
        if (_result.startsWith('-')) {
          _result = _result.substring(1);
        } else {
          _result = '-$_result';
        }
        notifyListeners();
      }
      return;
    }

    // Find the start of the current number
    int start = _expression.length - 1;
    while (start > 0 &&
        !_isOperator(_expression[start - 1]) &&
        _expression[start - 1] != '(') {
      start--;
    }

    String currentNumber = _expression.substring(start);
    String prefix = _expression.substring(0, start);

    if (currentNumber.startsWith('-')) {
      _expression = prefix + currentNumber.substring(1);
    } else {
      _expression = '$prefix(-$currentNumber';
    }

    _updatePreview();
    notifyListeners();
  }

  // Calculate inverse (1/x)
  void inverse() {
    if (_result != '0' && _result != 'Error' && _expression.isEmpty) {
      _expression = '1/$_result';
      calculate();
    } else if (_expression.isNotEmpty) {
      _expression = '1/($_expression)';
      calculate();
    }
  }

  // Calculate square
  void square() {
    if (_result != '0' && _result != 'Error' && _expression.isEmpty) {
      _expression = '$_result^2';
      calculate();
    } else if (_expression.isNotEmpty) {
      _expression = '($_expression)^2';
      calculate();
    }
  }

  // Calculate cube
  void cube() {
    if (_result != '0' && _result != 'Error' && _expression.isEmpty) {
      _expression = '$_result^3';
      calculate();
    } else if (_expression.isNotEmpty) {
      _expression = '($_expression)^3';
      calculate();
    }
  }

  // Calculate square root
  void squareRoot() {
    if (_result != '0' && _result != 'Error' && _expression.isEmpty) {
      _expression = '√$_result';
      calculate();
    } else if (_expression.isNotEmpty) {
      _expression = '√($_expression)';
      calculate();
    }
  }
}
