import 'dart:math' as math;

/// A robust calculation engine that supports BODMAS order of operations,
/// scientific functions, and proper error handling.
class CalculationEngine {
  bool useRadians;

  // Cache for frequently computed values
  static final Map<String, double> _cache = {};
  static const int _maxCacheSize = 100;

  CalculationEngine({this.useRadians = false});

  /// Main calculation method that evaluates a mathematical expression
  String calculate(String expression) {
    try {
      // Check cache first
      String cacheKey = '${expression}_$useRadians';
      if (_cache.containsKey(cacheKey)) {
        return _formatResult(_cache[cacheKey]!);
      }

      // Clean and preprocess the expression
      String processed = _preprocess(expression);

      // Tokenize
      List<String> tokens = _tokenize(processed);

      // Convert to postfix (Reverse Polish Notation) using Shunting-yard algorithm
      List<String> postfix = _toPostfix(tokens);

      // Evaluate postfix expression
      double result = _evaluatePostfix(postfix);

      // Cache the result
      _addToCache(cacheKey, result);

      // Format result
      return _formatResult(result);
    } catch (e) {
      return 'Error';
    }
  }

  void _addToCache(String key, double value) {
    if (_cache.length >= _maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  /// Preprocess the expression - replace symbols and handle implicit multiplication
  String _preprocess(String expr) {
    String result = expr;

    // Replace display symbols with operators
    result = result.replaceAll('×', '*');
    result = result.replaceAll('÷', '/');
    result = result.replaceAll('−', '-');

    // Replace constants
    result = result.replaceAll('π', '(${math.pi})');
    // Be careful with 'e' - only replace standalone e, not in function names
    result = _replaceEulerConstant(result);

    // Handle percentage - simple conversion to decimal
    result = _handlePercentage(result);

    // Handle square root symbol
    result = result.replaceAll('√', 'sqrt');

    // Handle factorial
    result = _handleFactorial(result);

    // Handle implicit multiplication: 2(3) -> 2*(3), (2)(3) -> (2)*(3), 2sin -> 2*sin
    result = _addImplicitMultiplication(result);

    return result;
  }

  String _replaceEulerConstant(String expr) {
    // Replace standalone 'e' but not in function names like 'exp', 'sec', etc.
    StringBuffer result = StringBuffer();
    int i = 0;
    while (i < expr.length) {
      if (expr[i] == 'e') {
        // Check if it's part of a function name
        bool isPartOfFunction = false;

        // Check common functions containing 'e'
        List<String> functionsWithE = ['exp', 'sec', 'csc', 'asec', 'acsc', 'sech', 'csch'];
        for (String func in functionsWithE) {
          int startIdx = i - func.indexOf('e');
          if (startIdx >= 0 && startIdx + func.length <= expr.length) {
            String substring = expr.substring(startIdx, startIdx + func.length);
            if (substring == func) {
              isPartOfFunction = true;
              break;
            }
          }
        }

        if (!isPartOfFunction) {
          // Check if preceded/followed by letter (part of variable name)
          bool precededByLetter = i > 0 && _isLetter(expr[i - 1]);
          bool followedByLetter = i < expr.length - 1 && _isLetter(expr[i + 1]) && expr[i + 1] != 'x';

          if (!precededByLetter && !followedByLetter) {
            result.write('(${math.e})');
            i++;
            continue;
          }
        }
      }
      result.write(expr[i]);
      i++;
    }
    return result.toString();
  }

  String _handlePercentage(String expr) {
    // Replace % with /100 but handle cases like 50+10% = 55
    StringBuffer result = StringBuffer();
    for (int i = 0; i < expr.length; i++) {
      if (expr[i] == '%') {
        result.write('/100');
      } else {
        result.write(expr[i]);
      }
    }
    return result.toString();
  }

  String _handleFactorial(String expr) {
    // Find numbers followed by ! and replace with factorial function call
    RegExp factorialRegex = RegExp(r'(\d+)!');
    String result = expr.replaceAllMapped(factorialRegex, (match) {
      int n = int.parse(match.group(1)!);
      return '(${_factorial(n)})';
    });

    // Handle factorial of expressions in parentheses like (5)!
    RegExp parenFactorialRegex = RegExp(r'\)!');
    result = result.replaceAll(parenFactorialRegex, ')*FACT_MARKER');

    return result;
  }

  double _factorial(int n) {
    if (n < 0) throw Exception('Factorial of negative number');
    if (n <= 1) return 1;
    double result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  /// Calculate gamma function for non-integer factorial
  double _gamma(double x) {
    // Lanczos approximation
    const g = 7;
    const List<double> c = [
      0.99999999999980993,
      676.5203681218851,
      -1259.1392167224028,
      771.32342877765313,
      -176.61502916214059,
      12.507343278686905,
      -0.13857109526572012,
      9.9843695780195716e-6,
      1.5056327351493116e-7
    ];

    if (x < 0.5) {
      return math.pi / (math.sin(math.pi * x) * _gamma(1 - x));
    }

    x -= 1;
    double a = c[0];
    for (int i = 1; i < g + 2; i++) {
      a += c[i] / (x + i);
    }

    double t = x + g + 0.5;
    return math.sqrt(2 * math.pi) * math.pow(t, x + 0.5) * math.exp(-t) * a;
  }

  String _addImplicitMultiplication(String expr) {
    StringBuffer result = StringBuffer();

    for (int i = 0; i < expr.length; i++) {
      result.write(expr[i]);

      if (i < expr.length - 1) {
        String current = expr[i];
        String next = expr[i + 1];

        // Number followed by ( or function
        bool needsMultiply = false;

        if (_isDigit(current) || current == ')') {
          if (next == '(' || _isLetter(next)) {
            needsMultiply = true;
          }
        }

        if (current == ')' && (_isDigit(next) || next == '(')) {
          needsMultiply = true;
        }

        if (needsMultiply) {
          result.write('*');
        }
      }
    }

    return result.toString();
  }

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  bool _isLetter(String c) =>
      (c.codeUnitAt(0) >= 65 && c.codeUnitAt(0) <= 90) ||
      (c.codeUnitAt(0) >= 97 && c.codeUnitAt(0) <= 122);

  /// Tokenize the expression into numbers, operators, functions, and parentheses
  List<String> _tokenize(String expr) {
    List<String> tokens = [];
    StringBuffer currentToken = StringBuffer();
    int i = 0;

    while (i < expr.length) {
      String c = expr[i];

      if (_isDigit(c) || c == '.') {
        currentToken.write(c);
      } else if (_isLetter(c)) {
        // Could be a function name
        if (currentToken.isNotEmpty && _isDigitString(currentToken.toString())) {
          tokens.add(currentToken.toString());
          currentToken.clear();
        }
        currentToken.write(c);
      } else if (_isOperator(c) || c == '(' || c == ')') {
        if (currentToken.isNotEmpty) {
          tokens.add(currentToken.toString());
          currentToken.clear();
        }

        // Handle negative numbers at start or after operator/open paren
        if (c == '-' &&
            (tokens.isEmpty ||
                tokens.last == '(' ||
                _isOperator(tokens.last))) {
          currentToken.write(c);
        } else {
          tokens.add(c);
        }
      } else if (c == ' ') {
        if (currentToken.isNotEmpty) {
          tokens.add(currentToken.toString());
          currentToken.clear();
        }
      }
      i++;
    }

    if (currentToken.isNotEmpty) {
      tokens.add(currentToken.toString());
    }

    return tokens;
  }

  bool _isDigitString(String s) {
    return double.tryParse(s) != null;
  }

  bool _isOperator(String c) {
    return c == '+' || c == '-' || c == '*' || c == '/' || c == '^';
  }

  bool _isFunction(String token) {
    return [
      // Basic trig
      'sin', 'cos', 'tan',
      // Inverse trig
      'asin', 'acos', 'atan',
      // Hyperbolic
      'sinh', 'cosh', 'tanh',
      // Inverse hyperbolic
      'asinh', 'acosh', 'atanh',
      // Reciprocal trig
      'sec', 'csc', 'cot',
      // Inverse reciprocal trig
      'asec', 'acsc', 'acot',
      // Hyperbolic reciprocal
      'sech', 'csch', 'coth',
      // Logarithms
      'log', 'ln', 'log2', 'log10',
      // Roots and powers
      'sqrt', 'cbrt', 'exp', 'exp2',
      // Other
      'abs', 'ceil', 'floor', 'round', 'sign',
      'mod',
    ].contains(token.toLowerCase());
  }

  int _precedence(String op) {
    switch (op) {
      case '+':
      case '-':
        return 1;
      case '*':
      case '/':
      case 'mod':
        return 2;
      case '^':
        return 3;
      default:
        return 0;
    }
  }

  bool _isRightAssociative(String op) {
    return op == '^';
  }

  /// Convert infix notation to postfix using Shunting-yard algorithm
  List<String> _toPostfix(List<String> tokens) {
    List<String> output = [];
    List<String> operatorStack = [];

    for (String token in tokens) {
      if (double.tryParse(token) != null) {
        // Number
        output.add(token);
      } else if (_isFunction(token)) {
        operatorStack.add(token.toLowerCase());
      } else if (token == '(') {
        operatorStack.add(token);
      } else if (token == ')') {
        while (operatorStack.isNotEmpty && operatorStack.last != '(') {
          output.add(operatorStack.removeLast());
        }
        if (operatorStack.isNotEmpty && operatorStack.last == '(') {
          operatorStack.removeLast();
        }
        // If there's a function on top, pop it
        if (operatorStack.isNotEmpty && _isFunction(operatorStack.last)) {
          output.add(operatorStack.removeLast());
        }
      } else if (_isOperator(token)) {
        while (operatorStack.isNotEmpty &&
            operatorStack.last != '(' &&
            (_precedence(operatorStack.last) > _precedence(token) ||
                (_precedence(operatorStack.last) == _precedence(token) &&
                    !_isRightAssociative(token)))) {
          output.add(operatorStack.removeLast());
        }
        operatorStack.add(token);
      }
    }

    while (operatorStack.isNotEmpty) {
      output.add(operatorStack.removeLast());
    }

    return output;
  }

  /// Evaluate postfix expression
  double _evaluatePostfix(List<String> postfix) {
    List<double> stack = [];

    for (String token in postfix) {
      double? number = double.tryParse(token);

      if (number != null) {
        stack.add(number);
      } else if (_isFunction(token)) {
        if (stack.isEmpty) throw Exception('Invalid expression');
        double a = stack.removeLast();
        stack.add(_applyFunction(token, a));
      } else if (_isOperator(token)) {
        if (stack.length < 2) throw Exception('Invalid expression');
        double b = stack.removeLast();
        double a = stack.removeLast();
        stack.add(_applyOperator(token, a, b));
      }
    }

    if (stack.length != 1) throw Exception('Invalid expression');
    return stack.first;
  }

  double _applyOperator(String op, double a, double b) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        if (b == 0) throw Exception('Division by zero');
        return a / b;
      case '^':
        return math.pow(a, b).toDouble();
      case 'mod':
        return a % b;
      default:
        throw Exception('Unknown operator: $op');
    }
  }

  double _applyFunction(String func, double value) {
    // Convert to radians if needed for trig functions
    double angleValue = useRadians ? value : _degreesToRadians(value);

    switch (func.toLowerCase()) {
      // Basic trig
      case 'sin':
        return math.sin(angleValue);
      case 'cos':
        return math.cos(angleValue);
      case 'tan':
        return math.tan(angleValue);

      // Inverse trig
      case 'asin':
        double result = math.asin(value);
        return useRadians ? result : _radiansToDegrees(result);
      case 'acos':
        double result = math.acos(value);
        return useRadians ? result : _radiansToDegrees(result);
      case 'atan':
        double result = math.atan(value);
        return useRadians ? result : _radiansToDegrees(result);

      // Hyperbolic functions
      case 'sinh':
        return (math.exp(value) - math.exp(-value)) / 2;
      case 'cosh':
        return (math.exp(value) + math.exp(-value)) / 2;
      case 'tanh':
        return (math.exp(value) - math.exp(-value)) / (math.exp(value) + math.exp(-value));

      // Inverse hyperbolic
      case 'asinh':
        return math.log(value + math.sqrt(value * value + 1));
      case 'acosh':
        if (value < 1) throw Exception('acosh domain error');
        return math.log(value + math.sqrt(value * value - 1));
      case 'atanh':
        if (value.abs() >= 1) throw Exception('atanh domain error');
        return 0.5 * math.log((1 + value) / (1 - value));

      // Reciprocal trig
      case 'sec':
        double cosVal = math.cos(angleValue);
        if (cosVal == 0) throw Exception('sec undefined');
        return 1 / cosVal;
      case 'csc':
        double sinVal = math.sin(angleValue);
        if (sinVal == 0) throw Exception('csc undefined');
        return 1 / sinVal;
      case 'cot':
        double tanVal = math.tan(angleValue);
        if (tanVal == 0) throw Exception('cot undefined');
        return 1 / tanVal;

      // Inverse reciprocal trig
      case 'asec':
        if (value.abs() < 1) throw Exception('asec domain error');
        double result = math.acos(1 / value);
        return useRadians ? result : _radiansToDegrees(result);
      case 'acsc':
        if (value.abs() < 1) throw Exception('acsc domain error');
        double result = math.asin(1 / value);
        return useRadians ? result : _radiansToDegrees(result);
      case 'acot':
        double result = math.atan(1 / value);
        return useRadians ? result : _radiansToDegrees(result);

      // Hyperbolic reciprocal
      case 'sech':
        double coshVal = (math.exp(value) + math.exp(-value)) / 2;
        return 1 / coshVal;
      case 'csch':
        double sinhVal = (math.exp(value) - math.exp(-value)) / 2;
        if (sinhVal == 0) throw Exception('csch undefined at 0');
        return 1 / sinhVal;
      case 'coth':
        double tanhVal = (math.exp(value) - math.exp(-value)) / (math.exp(value) + math.exp(-value));
        if (tanhVal == 0) throw Exception('coth undefined at 0');
        return 1 / tanhVal;

      // Logarithms
      case 'log':
      case 'log10':
        if (value <= 0) throw Exception('log domain error');
        return math.log(value) / math.ln10;
      case 'ln':
        if (value <= 0) throw Exception('ln domain error');
        return math.log(value);
      case 'log2':
        if (value <= 0) throw Exception('log2 domain error');
        return math.log(value) / math.ln2;

      // Roots and exponentials
      case 'sqrt':
        if (value < 0) throw Exception('Square root of negative number');
        return math.sqrt(value);
      case 'cbrt':
        return value < 0 ? -math.pow(-value, 1/3).toDouble() : math.pow(value, 1/3).toDouble();
      case 'exp':
        return math.exp(value);
      case 'exp2':
        return math.pow(2, value).toDouble();

      // Other functions
      case 'abs':
        return value.abs();
      case 'ceil':
        return value.ceilToDouble();
      case 'floor':
        return value.floorToDouble();
      case 'round':
        return value.roundToDouble();
      case 'sign':
        return value.sign;

      default:
        throw Exception('Unknown function: $func');
    }
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  double _radiansToDegrees(double radians) {
    return radians * (180 / math.pi);
  }

  /// Format the result for display
  String _formatResult(double value) {
    if (value.isNaN || value.isInfinite) {
      return 'Error';
    }

    // Check if it's effectively an integer
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }

    // Format with reasonable precision
    String formatted = value.toStringAsPrecision(10);

    // Remove trailing zeros after decimal point
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    }

    // Handle scientific notation for very large/small numbers
    if (value.abs() >= 1e10 || (value.abs() < 1e-6 && value != 0)) {
      formatted = value.toStringAsExponential(6);
    }

    return formatted;
  }

  /// Validate expression brackets
  bool validateBrackets(String expression) {
    int count = 0;
    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '(') count++;
      if (expression[i] == ')') count--;
      if (count < 0) return false;
    }
    return count == 0;
  }

  /// Get real-time preview of calculation
  String preview(String expression) {
    if (expression.isEmpty) return '0';
    try {
      return calculate(expression);
    } catch (e) {
      return '';
    }
  }

  // ==================== COMBINATORICS ====================

  /// Calculate permutation nPr = n! / (n-r)!
  static double permutation(int n, int r) {
    if (n < 0 || r < 0 || r > n) {
      throw Exception('Invalid permutation parameters');
    }
    double result = 1;
    for (int i = n; i > n - r; i--) {
      result *= i;
    }
    return result;
  }

  /// Calculate combination nCr = n! / (r! * (n-r)!)
  static double combination(int n, int r) {
    if (n < 0 || r < 0 || r > n) {
      throw Exception('Invalid combination parameters');
    }
    if (r > n - r) {
      r = n - r; // Optimization: C(n,r) = C(n,n-r)
    }
    double result = 1;
    for (int i = 0; i < r; i++) {
      result = result * (n - i) / (i + 1);
    }
    return result;
  }

  /// Calculate GCD using Euclidean algorithm
  static int gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      int t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  /// Calculate LCM
  static int lcm(int a, int b) {
    return (a * b).abs() ~/ gcd(a, b);
  }

  /// Check if a number is prime
  static bool isPrime(int n) {
    if (n < 2) return false;
    if (n == 2) return true;
    if (n % 2 == 0) return false;
    for (int i = 3; i * i <= n; i += 2) {
      if (n % i == 0) return false;
    }
    return true;
  }

  /// Prime factorization
  static List<int> primeFactors(int n) {
    List<int> factors = [];
    int d = 2;
    while (d * d <= n) {
      while (n % d == 0) {
        factors.add(d);
        n ~/= d;
      }
      d++;
    }
    if (n > 1) {
      factors.add(n);
    }
    return factors;
  }
}
