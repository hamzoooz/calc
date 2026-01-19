import 'dart:math' as math;
import 'package:modern_calculator/core/services/matrix_service.dart';

/// Complex number class for equation solutions
class Complex {
  final double real;
  final double imaginary;

  const Complex(this.real, this.imaginary);

  factory Complex.fromReal(double real) => Complex(real, 0);

  double get magnitude => math.sqrt(real * real + imaginary * imaginary);
  double get phase => math.atan2(imaginary, real);

  Complex operator +(Complex other) =>
      Complex(real + other.real, imaginary + other.imaginary);

  Complex operator -(Complex other) =>
      Complex(real - other.real, imaginary - other.imaginary);

  Complex operator *(Complex other) => Complex(
        real * other.real - imaginary * other.imaginary,
        real * other.imaginary + imaginary * other.real,
      );

  Complex operator /(Complex other) {
    double denom = other.real * other.real + other.imaginary * other.imaginary;
    return Complex(
      (real * other.real + imaginary * other.imaginary) / denom,
      (imaginary * other.real - real * other.imaginary) / denom,
    );
  }

  Complex get conjugate => Complex(real, -imaginary);

  Complex sqrt() {
    double r = magnitude;
    double theta = phase;
    double sqrtR = math.sqrt(r);
    return Complex(sqrtR * math.cos(theta / 2), sqrtR * math.sin(theta / 2));
  }

  bool get isReal => imaginary.abs() < 1e-10;

  @override
  String toString() {
    if (isReal) {
      if (real == real.roundToDouble()) {
        return real.toInt().toString();
      }
      return real.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }

    String realStr = real.abs() < 1e-10 ? '' : _formatNum(real);
    String imagStr = _formatNum(imaginary.abs());
    String sign = imaginary >= 0 ? (realStr.isEmpty ? '' : '+') : '-';

    if (realStr.isEmpty) {
      return '${imaginary < 0 ? '-' : ''}${imagStr}i';
    }
    return '$realStr$sign${imagStr}i';
  }

  String _formatNum(double n) {
    if (n == n.roundToDouble()) {
      return n.toInt().toString();
    }
    return n.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}

/// Result of equation solving
class EquationResult {
  final List<Complex> solutions;
  final String equation;
  final String type;
  final bool hasRealSolutions;

  EquationResult({
    required this.solutions,
    required this.equation,
    required this.type,
  }) : hasRealSolutions = solutions.any((s) => s.isReal);

  List<double> get realSolutions =>
      solutions.where((s) => s.isReal).map((s) => s.real).toList();

  @override
  String toString() {
    if (solutions.isEmpty) return 'No solutions';
    return solutions.map((s) => 'x = $s').join('\n');
  }
}

/// Equation Solver Service
class EquationSolver {
  /// Solve linear equation: ax + b = 0
  static EquationResult solveLinear(double a, double b) {
    if (a == 0) {
      if (b == 0) {
        return EquationResult(
          solutions: [],
          equation: '0 = 0',
          type: 'Linear (infinite solutions)',
        );
      }
      return EquationResult(
        solutions: [],
        equation: '${_formatCoef(b)} = 0',
        type: 'Linear (no solution)',
      );
    }

    double x = -b / a;
    return EquationResult(
      solutions: [Complex.fromReal(x)],
      equation: '${_formatCoef(a)}x + ${_formatCoef(b)} = 0',
      type: 'Linear',
    );
  }

  /// Solve quadratic equation: ax² + bx + c = 0
  static EquationResult solveQuadratic(double a, double b, double c) {
    if (a == 0) {
      return solveLinear(b, c);
    }

    double discriminant = b * b - 4 * a * c;
    String equation = '${_formatCoef(a)}x² + ${_formatCoef(b)}x + ${_formatCoef(c)} = 0';

    if (discriminant > 0) {
      double sqrtD = math.sqrt(discriminant);
      double x1 = (-b + sqrtD) / (2 * a);
      double x2 = (-b - sqrtD) / (2 * a);
      return EquationResult(
        solutions: [Complex.fromReal(x1), Complex.fromReal(x2)],
        equation: equation,
        type: 'Quadratic (2 real roots)',
      );
    } else if (discriminant == 0) {
      double x = -b / (2 * a);
      return EquationResult(
        solutions: [Complex.fromReal(x)],
        equation: equation,
        type: 'Quadratic (1 repeated root)',
      );
    } else {
      double realPart = -b / (2 * a);
      double imagPart = math.sqrt(-discriminant) / (2 * a);
      return EquationResult(
        solutions: [
          Complex(realPart, imagPart),
          Complex(realPart, -imagPart),
        ],
        equation: equation,
        type: 'Quadratic (2 complex roots)',
      );
    }
  }

  /// Solve cubic equation: ax³ + bx² + cx + d = 0
  static EquationResult solveCubic(double a, double b, double c, double d) {
    if (a == 0) {
      return solveQuadratic(b, c, d);
    }

    String equation =
        '${_formatCoef(a)}x³ + ${_formatCoef(b)}x² + ${_formatCoef(c)}x + ${_formatCoef(d)} = 0';

    // Normalize to x³ + px² + qx + r = 0
    double p = b / a;
    double q = c / a;
    double r = d / a;

    // Convert to depressed cubic: t³ + pt + q = 0 using substitution x = t - p/3
    double pDepressed = q - p * p / 3;
    double qDepressed = 2 * p * p * p / 27 - p * q / 3 + r;

    // Cardano's discriminant
    double discriminant = qDepressed * qDepressed / 4 + pDepressed * pDepressed * pDepressed / 27;

    List<Complex> solutions = [];

    if (discriminant > 0) {
      // One real root, two complex conjugates
      double sqrtD = math.sqrt(discriminant);
      double u = _cbrt(-qDepressed / 2 + sqrtD);
      double v = _cbrt(-qDepressed / 2 - sqrtD);

      double realRoot = u + v - p / 3;
      solutions.add(Complex.fromReal(realRoot));

      // Complex roots
      double realPart = -(u + v) / 2 - p / 3;
      double imagPart = (u - v) * math.sqrt(3) / 2;
      solutions.add(Complex(realPart, imagPart));
      solutions.add(Complex(realPart, -imagPart));
    } else if (discriminant == 0) {
      // Three real roots, at least two equal
      double u = _cbrt(-qDepressed / 2);
      solutions.add(Complex.fromReal(2 * u - p / 3));
      solutions.add(Complex.fromReal(-u - p / 3));
      solutions.add(Complex.fromReal(-u - p / 3));
    } else {
      // Three distinct real roots (casus irreducibilis)
      double m = 2 * math.sqrt(-pDepressed / 3);
      double theta = math.acos(3 * qDepressed / (pDepressed * m)) / 3;

      solutions.add(Complex.fromReal(m * math.cos(theta) - p / 3));
      solutions.add(Complex.fromReal(m * math.cos(theta - 2 * math.pi / 3) - p / 3));
      solutions.add(Complex.fromReal(m * math.cos(theta - 4 * math.pi / 3) - p / 3));
    }

    return EquationResult(
      solutions: solutions,
      equation: equation,
      type: 'Cubic',
    );
  }

  /// Solve quartic equation: ax⁴ + bx³ + cx² + dx + e = 0
  static EquationResult solveQuartic(
      double a, double b, double c, double d, double e) {
    if (a == 0) {
      return solveCubic(b, c, d, e);
    }

    String equation =
        '${_formatCoef(a)}x⁴ + ${_formatCoef(b)}x³ + ${_formatCoef(c)}x² + ${_formatCoef(d)}x + ${_formatCoef(e)} = 0';

    // Normalize
    double aa = b / a;
    double bb = c / a;
    double cc = d / a;
    double dd = e / a;

    // Ferrari's method - find a root of the resolvent cubic
    EquationResult cubic = solveCubic(
      1,
      -bb,
      aa * cc - 4 * dd,
      -aa * aa * dd + 4 * bb * dd - cc * cc,
    );

    double y = cubic.realSolutions.isNotEmpty
        ? cubic.realSolutions.first
        : cubic.solutions.first.real;

    // Calculate roots using the resolvent
    double r = math.sqrt(aa * aa / 4 - bb + y);
    List<Complex> solutions = [];

    if (r.abs() < 1e-10) {
      double d1 = math.sqrt(y * y / 4 - dd);
      solutions.addAll(_solveQuadraticComplex(1, aa / 2, y / 2 - d1));
      solutions.addAll(_solveQuadraticComplex(1, aa / 2, y / 2 + d1));
    } else {
      double d1 = 3 * aa * aa / 4 - r * r - 2 * bb +
          (4 * aa * bb - 8 * cc - aa * aa * aa) / (4 * r);
      double d2 = 3 * aa * aa / 4 - r * r - 2 * bb -
          (4 * aa * bb - 8 * cc - aa * aa * aa) / (4 * r);

      if (d1 >= 0) {
        double sqrtD1 = math.sqrt(d1);
        solutions.add(Complex.fromReal(-aa / 4 + r / 2 + sqrtD1 / 2));
        solutions.add(Complex.fromReal(-aa / 4 + r / 2 - sqrtD1 / 2));
      } else {
        double sqrtD1 = math.sqrt(-d1);
        solutions.add(Complex(-aa / 4 + r / 2, sqrtD1 / 2));
        solutions.add(Complex(-aa / 4 + r / 2, -sqrtD1 / 2));
      }

      if (d2 >= 0) {
        double sqrtD2 = math.sqrt(d2);
        solutions.add(Complex.fromReal(-aa / 4 - r / 2 + sqrtD2 / 2));
        solutions.add(Complex.fromReal(-aa / 4 - r / 2 - sqrtD2 / 2));
      } else {
        double sqrtD2 = math.sqrt(-d2);
        solutions.add(Complex(-aa / 4 - r / 2, sqrtD2 / 2));
        solutions.add(Complex(-aa / 4 - r / 2, -sqrtD2 / 2));
      }
    }

    return EquationResult(
      solutions: solutions,
      equation: equation,
      type: 'Quartic',
    );
  }

  /// Helper for quartic solver
  static List<Complex> _solveQuadraticComplex(double a, double b, double c) {
    double discriminant = b * b - 4 * a * c;
    if (discriminant >= 0) {
      double sqrtD = math.sqrt(discriminant);
      return [
        Complex.fromReal((-b + sqrtD) / (2 * a)),
        Complex.fromReal((-b - sqrtD) / (2 * a)),
      ];
    } else {
      double realPart = -b / (2 * a);
      double imagPart = math.sqrt(-discriminant) / (2 * a);
      return [
        Complex(realPart, imagPart),
        Complex(realPart, -imagPart),
      ];
    }
  }

  /// Solve system of linear equations using matrix methods
  static List<double>? solveLinearSystem(List<List<double>> coefficients, List<double> constants) {
    if (coefficients.isEmpty || coefficients.length != constants.length) {
      return null;
    }

    try {
      Matrix a = Matrix(coefficients);
      return MatrixService.solveSystem(a, constants);
    } catch (e) {
      return null;
    }
  }

  /// Solve 2x2 system:
  /// a1*x + b1*y = c1
  /// a2*x + b2*y = c2
  static Map<String, double>? solve2x2System(
    double a1, double b1, double c1,
    double a2, double b2, double c2,
  ) {
    double det = a1 * b2 - a2 * b1;
    if (det.abs() < 1e-10) {
      return null; // No unique solution
    }

    double x = (c1 * b2 - c2 * b1) / det;
    double y = (a1 * c2 - a2 * c1) / det;

    return {'x': x, 'y': y};
  }

  /// Solve 3x3 system using Cramer's rule
  static Map<String, double>? solve3x3System(
    double a1, double b1, double c1, double d1,
    double a2, double b2, double c2, double d2,
    double a3, double b3, double c3, double d3,
  ) {
    // Calculate main determinant
    double det = a1 * (b2 * c3 - b3 * c2) -
        b1 * (a2 * c3 - a3 * c2) +
        c1 * (a2 * b3 - a3 * b2);

    if (det.abs() < 1e-10) {
      return null; // No unique solution
    }

    // Cramer's rule
    double detX = d1 * (b2 * c3 - b3 * c2) -
        b1 * (d2 * c3 - d3 * c2) +
        c1 * (d2 * b3 - d3 * b2);

    double detY = a1 * (d2 * c3 - d3 * c2) -
        d1 * (a2 * c3 - a3 * c2) +
        c1 * (a2 * d3 - a3 * d2);

    double detZ = a1 * (b2 * d3 - b3 * d2) -
        b1 * (a2 * d3 - a3 * d2) +
        d1 * (a2 * b3 - a3 * b2);

    return {
      'x': detX / det,
      'y': detY / det,
      'z': detZ / det,
    };
  }

  /// Newton-Raphson method for finding roots numerically
  static double? newtonRaphson(
    double Function(double) f,
    double Function(double) fPrime,
    double x0, {
    int maxIterations = 100,
    double tolerance = 1e-10,
  }) {
    double x = x0;

    for (int i = 0; i < maxIterations; i++) {
      double fx = f(x);
      double fpx = fPrime(x);

      if (fpx.abs() < 1e-15) {
        return null; // Derivative too small
      }

      double xNew = x - fx / fpx;

      if ((xNew - x).abs() < tolerance) {
        return xNew;
      }

      x = xNew;
    }

    return null; // Did not converge
  }

  /// Bisection method for finding roots
  static double? bisection(
    double Function(double) f,
    double a,
    double b, {
    int maxIterations = 100,
    double tolerance = 1e-10,
  }) {
    double fa = f(a);
    double fb = f(b);

    if (fa * fb > 0) {
      return null; // No sign change
    }

    for (int i = 0; i < maxIterations; i++) {
      double c = (a + b) / 2;
      double fc = f(c);

      if (fc.abs() < tolerance || (b - a) / 2 < tolerance) {
        return c;
      }

      if (fa * fc < 0) {
        b = c;
        fb = fc;
      } else {
        a = c;
        fa = fc;
      }
    }

    return (a + b) / 2;
  }

  /// Solve polynomial using numerical methods
  static List<double> solvePolynomialNumerically(
    List<double> coefficients, {
    double minX = -100,
    double maxX = 100,
    int numIntervals = 1000,
  }) {
    List<double> roots = [];
    double dx = (maxX - minX) / numIntervals;

    double evaluate(double x) {
      double result = 0;
      for (int i = 0; i < coefficients.length; i++) {
        result += coefficients[i] * math.pow(x, coefficients.length - 1 - i);
      }
      return result;
    }

    for (int i = 0; i < numIntervals; i++) {
      double a = minX + i * dx;
      double b = a + dx;

      double? root = bisection(evaluate, a, b);
      if (root != null && !roots.any((r) => (r - root).abs() < 1e-6)) {
        roots.add(root);
      }
    }

    return roots;
  }

  static double _cbrt(double x) {
    return x < 0 ? -math.pow(-x, 1 / 3).toDouble() : math.pow(x, 1 / 3).toDouble();
  }

  static String _formatCoef(double c) {
    if (c == c.roundToDouble()) {
      return c.toInt().toString();
    }
    return c.toStringAsFixed(2);
  }
}
