import 'dart:math' as math;

/// Result class for regression analysis
class RegressionResult {
  final double slope;
  final double intercept;
  final double rSquared;
  final double correlationCoefficient;
  final String equation;

  RegressionResult({
    required this.slope,
    required this.intercept,
    required this.rSquared,
    required this.correlationCoefficient,
    required this.equation,
  });

  double predict(double x) => slope * x + intercept;

  @override
  String toString() {
    return 'y = ${_format(slope)}x + ${_format(intercept)}\nR² = ${_format(rSquared)}\nr = ${_format(correlationCoefficient)}';
  }

  String _format(double n) {
    if (n == n.roundToDouble()) return n.toInt().toString();
    return n.toStringAsFixed(4);
  }
}

/// Statistical distribution results
class DistributionResult {
  final double mean;
  final double variance;
  final double stdDev;
  final double skewness;
  final double kurtosis;

  DistributionResult({
    required this.mean,
    required this.variance,
    required this.stdDev,
    required this.skewness,
    required this.kurtosis,
  });
}

/// Statistics Service for scientific calculator
class StatisticsService {
  // ==================== BASIC STATISTICS ====================

  /// Calculate arithmetic mean
  static double mean(List<double> data) {
    if (data.isEmpty) throw Exception('Data set is empty');
    return data.reduce((a, b) => a + b) / data.length;
  }

  /// Calculate weighted mean
  static double weightedMean(List<double> values, List<double> weights) {
    if (values.length != weights.length) {
      throw Exception('Values and weights must have same length');
    }
    if (values.isEmpty) throw Exception('Data set is empty');

    double sumWeighted = 0;
    double sumWeights = 0;
    for (int i = 0; i < values.length; i++) {
      sumWeighted += values[i] * weights[i];
      sumWeights += weights[i];
    }
    return sumWeighted / sumWeights;
  }

  /// Calculate geometric mean
  static double geometricMean(List<double> data) {
    if (data.isEmpty) throw Exception('Data set is empty');
    if (data.any((x) => x <= 0)) {
      throw Exception('Geometric mean requires positive numbers');
    }

    double logSum = data.map((x) => math.log(x)).reduce((a, b) => a + b);
    return math.exp(logSum / data.length);
  }

  /// Calculate harmonic mean
  static double harmonicMean(List<double> data) {
    if (data.isEmpty) throw Exception('Data set is empty');
    if (data.any((x) => x == 0)) {
      throw Exception('Harmonic mean cannot have zero values');
    }

    double reciprocalSum = data.map((x) => 1 / x).reduce((a, b) => a + b);
    return data.length / reciprocalSum;
  }

  /// Calculate median
  static double median(List<double> data) {
    if (data.isEmpty) throw Exception('Data set is empty');

    List<double> sorted = List.from(data)..sort();
    int n = sorted.length;

    if (n % 2 == 1) {
      return sorted[n ~/ 2];
    } else {
      return (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2;
    }
  }

  /// Calculate mode (returns list for multimodal data)
  static List<double> mode(List<double> data) {
    if (data.isEmpty) throw Exception('Data set is empty');

    Map<double, int> frequency = {};
    for (var x in data) {
      frequency[x] = (frequency[x] ?? 0) + 1;
    }

    int maxFreq = frequency.values.reduce(math.max);
    if (maxFreq == 1) return []; // No mode

    return frequency.entries
        .where((e) => e.value == maxFreq)
        .map((e) => e.key)
        .toList();
  }

  /// Calculate range
  static double range(List<double> data) {
    if (data.isEmpty) throw Exception('Data set is empty');
    return data.reduce(math.max) - data.reduce(math.min);
  }

  /// Calculate minimum
  static double min(List<double> data) {
    if (data.isEmpty) throw Exception('Data set is empty');
    return data.reduce(math.min);
  }

  /// Calculate maximum
  static double max(List<double> data) {
    if (data.isEmpty) throw Exception('Data set is empty');
    return data.reduce(math.max);
  }

  /// Calculate sum
  static double sum(List<double> data) {
    if (data.isEmpty) return 0;
    return data.reduce((a, b) => a + b);
  }

  /// Calculate product
  static double product(List<double> data) {
    if (data.isEmpty) return 0;
    return data.reduce((a, b) => a * b);
  }

  // ==================== DISPERSION MEASURES ====================

  /// Calculate population variance
  static double variancePopulation(List<double> data) {
    if (data.isEmpty) throw Exception('Data set is empty');

    double m = mean(data);
    double sumSquares = data.map((x) => (x - m) * (x - m)).reduce((a, b) => a + b);
    return sumSquares / data.length;
  }

  /// Calculate sample variance (Bessel's correction)
  static double varianceSample(List<double> data) {
    if (data.length < 2) throw Exception('Need at least 2 data points');

    double m = mean(data);
    double sumSquares = data.map((x) => (x - m) * (x - m)).reduce((a, b) => a + b);
    return sumSquares / (data.length - 1);
  }

  /// Calculate population standard deviation
  static double stdDevPopulation(List<double> data) {
    return math.sqrt(variancePopulation(data));
  }

  /// Calculate sample standard deviation
  static double stdDevSample(List<double> data) {
    return math.sqrt(varianceSample(data));
  }

  /// Calculate coefficient of variation (CV)
  static double coefficientOfVariation(List<double> data) {
    double m = mean(data);
    if (m == 0) throw Exception('Mean is zero');
    return stdDevSample(data) / m.abs();
  }

  /// Calculate mean absolute deviation (MAD)
  static double meanAbsoluteDeviation(List<double> data) {
    if (data.isEmpty) throw Exception('Data set is empty');

    double m = mean(data);
    return data.map((x) => (x - m).abs()).reduce((a, b) => a + b) / data.length;
  }

  /// Calculate standard error of mean
  static double standardErrorMean(List<double> data) {
    return stdDevSample(data) / math.sqrt(data.length);
  }

  // ==================== PERCENTILES & QUARTILES ====================

  /// Calculate percentile
  static double percentile(List<double> data, double p) {
    if (data.isEmpty) throw Exception('Data set is empty');
    if (p < 0 || p > 100) throw Exception('Percentile must be 0-100');

    List<double> sorted = List.from(data)..sort();
    double index = (p / 100) * (sorted.length - 1);
    int lower = index.floor();
    int upper = index.ceil();

    if (lower == upper) {
      return sorted[lower];
    }

    return sorted[lower] + (index - lower) * (sorted[upper] - sorted[lower]);
  }

  /// Calculate quartiles Q1, Q2 (median), Q3
  static Map<String, double> quartiles(List<double> data) {
    return {
      'Q1': percentile(data, 25),
      'Q2': percentile(data, 50),
      'Q3': percentile(data, 75),
    };
  }

  /// Calculate interquartile range (IQR)
  static double interquartileRange(List<double> data) {
    Map<String, double> q = quartiles(data);
    return q['Q3']! - q['Q1']!;
  }

  /// Five number summary
  static Map<String, double> fiveNumberSummary(List<double> data) {
    Map<String, double> q = quartiles(data);
    return {
      'min': min(data),
      'Q1': q['Q1']!,
      'median': q['Q2']!,
      'Q3': q['Q3']!,
      'max': max(data),
    };
  }

  // ==================== DISTRIBUTION SHAPE ====================

  /// Calculate skewness (measure of asymmetry)
  static double skewness(List<double> data) {
    if (data.length < 3) throw Exception('Need at least 3 data points');

    double m = mean(data);
    double s = stdDevSample(data);
    int n = data.length;

    double sum = data.map((x) => math.pow((x - m) / s, 3).toDouble()).reduce((a, b) => a + b);

    return (n / ((n - 1) * (n - 2))) * sum;
  }

  /// Calculate kurtosis (measure of tail heaviness)
  static double kurtosis(List<double> data) {
    if (data.length < 4) throw Exception('Need at least 4 data points');

    double m = mean(data);
    double s = stdDevSample(data);
    int n = data.length;

    double sum = data.map((x) => math.pow((x - m) / s, 4).toDouble()).reduce((a, b) => a + b);

    double k = ((n * (n + 1)) / ((n - 1) * (n - 2) * (n - 3))) * sum;
    k -= (3 * (n - 1) * (n - 1)) / ((n - 2) * (n - 3));

    return k;
  }

  /// Get full distribution analysis
  static DistributionResult analyzeDistribution(List<double> data) {
    return DistributionResult(
      mean: mean(data),
      variance: varianceSample(data),
      stdDev: stdDevSample(data),
      skewness: data.length >= 3 ? skewness(data) : 0,
      kurtosis: data.length >= 4 ? kurtosis(data) : 0,
    );
  }

  // ==================== CORRELATION & REGRESSION ====================

  /// Calculate Pearson correlation coefficient
  static double correlation(List<double> x, List<double> y) {
    if (x.length != y.length) {
      throw Exception('Data sets must have same length');
    }
    if (x.length < 2) throw Exception('Need at least 2 data points');

    double meanX = mean(x);
    double meanY = mean(y);

    double sumXY = 0;
    double sumX2 = 0;
    double sumY2 = 0;

    for (int i = 0; i < x.length; i++) {
      double dx = x[i] - meanX;
      double dy = y[i] - meanY;
      sumXY += dx * dy;
      sumX2 += dx * dx;
      sumY2 += dy * dy;
    }

    double denom = math.sqrt(sumX2 * sumY2);
    if (denom == 0) return 0;

    return sumXY / denom;
  }

  /// Calculate covariance
  static double covariance(List<double> x, List<double> y) {
    if (x.length != y.length) {
      throw Exception('Data sets must have same length');
    }
    if (x.length < 2) throw Exception('Need at least 2 data points');

    double meanX = mean(x);
    double meanY = mean(y);

    double sum = 0;
    for (int i = 0; i < x.length; i++) {
      sum += (x[i] - meanX) * (y[i] - meanY);
    }

    return sum / (x.length - 1);
  }

  /// Linear regression (least squares)
  static RegressionResult linearRegression(List<double> x, List<double> y) {
    if (x.length != y.length) {
      throw Exception('Data sets must have same length');
    }
    if (x.length < 2) throw Exception('Need at least 2 data points');

    double meanX = mean(x);
    double meanY = mean(y);

    double sumXY = 0;
    double sumX2 = 0;
    double sumY2 = 0;

    for (int i = 0; i < x.length; i++) {
      double dx = x[i] - meanX;
      double dy = y[i] - meanY;
      sumXY += dx * dy;
      sumX2 += dx * dx;
      sumY2 += dy * dy;
    }

    double slope = sumXY / sumX2;
    double intercept = meanY - slope * meanX;

    // R-squared (coefficient of determination)
    double ssRes = 0;
    double ssTot = sumY2;
    for (int i = 0; i < x.length; i++) {
      double predicted = slope * x[i] + intercept;
      ssRes += (y[i] - predicted) * (y[i] - predicted);
    }
    double rSquared = 1 - (ssRes / ssTot);

    double r = correlation(x, y);

    String sign = intercept >= 0 ? '+' : '-';
    String equation = 'y = ${_format(slope)}x $sign ${_format(intercept.abs())}';

    return RegressionResult(
      slope: slope,
      intercept: intercept,
      rSquared: rSquared,
      correlationCoefficient: r,
      equation: equation,
    );
  }

  /// Polynomial regression
  static List<double> polynomialRegression(List<double> x, List<double> y, int degree) {
    if (x.length != y.length) {
      throw Exception('Data sets must have same length');
    }
    if (x.length <= degree) {
      throw Exception('Need more data points than degree');
    }

    int n = x.length;
    int m = degree + 1;

    // Build Vandermonde matrix
    List<List<double>> v = List.generate(
      n,
      (i) => List.generate(m, (j) => math.pow(x[i], j).toDouble()),
    );

    // Solve normal equations: V^T * V * c = V^T * y
    List<List<double>> vtv = List.generate(
      m,
      (i) => List.generate(m, (j) {
        double sum = 0;
        for (int k = 0; k < n; k++) {
          sum += v[k][i] * v[k][j];
        }
        return sum;
      }),
    );

    List<double> vty = List.generate(m, (i) {
      double sum = 0;
      for (int k = 0; k < n; k++) {
        sum += v[k][i] * y[k];
      }
      return sum;
    });

    // Solve using Gaussian elimination
    return _solveLinearSystem(vtv, vty);
  }

  /// Exponential regression: y = a * e^(bx)
  static Map<String, double> exponentialRegression(List<double> x, List<double> y) {
    if (y.any((yi) => yi <= 0)) {
      throw Exception('Exponential regression requires positive y values');
    }

    List<double> lnY = y.map((yi) => math.log(yi)).toList();
    RegressionResult linear = linearRegression(x, lnY);

    double a = math.exp(linear.intercept);
    double b = linear.slope;

    return {
      'a': a,
      'b': b,
      'rSquared': linear.rSquared,
    };
  }

  /// Power regression: y = a * x^b
  static Map<String, double> powerRegression(List<double> x, List<double> y) {
    if (x.any((xi) => xi <= 0) || y.any((yi) => yi <= 0)) {
      throw Exception('Power regression requires positive values');
    }

    List<double> lnX = x.map((xi) => math.log(xi)).toList();
    List<double> lnY = y.map((yi) => math.log(yi)).toList();
    RegressionResult linear = linearRegression(lnX, lnY);

    double a = math.exp(linear.intercept);
    double b = linear.slope;

    return {
      'a': a,
      'b': b,
      'rSquared': linear.rSquared,
    };
  }

  // ==================== PROBABILITY DISTRIBUTIONS ====================

  /// Normal distribution PDF
  static double normalPDF(double x, {double mean = 0, double stdDev = 1}) {
    double z = (x - mean) / stdDev;
    return math.exp(-0.5 * z * z) / (stdDev * math.sqrt(2 * math.pi));
  }

  /// Normal distribution CDF (approximation)
  static double normalCDF(double x, {double mean = 0, double stdDev = 1}) {
    double z = (x - mean) / stdDev;
    return 0.5 * (1 + _erf(z / math.sqrt(2)));
  }

  /// Inverse normal CDF (approximation)
  static double normalInverseCDF(double p, {double mean = 0, double stdDev = 1}) {
    if (p <= 0 || p >= 1) throw Exception('p must be between 0 and 1');

    // Rational approximation
    double a1 = -3.969683028665376e1;
    double a2 = 2.209460984245205e2;
    double a3 = -2.759285104469687e2;
    double a4 = 1.383577518672690e2;
    double a5 = -3.066479806614716e1;
    double a6 = 2.506628277459239e0;

    double b1 = -5.447609879822406e1;
    double b2 = 1.615858368580409e2;
    double b3 = -1.556989798598866e2;
    double b4 = 6.680131188771972e1;
    double b5 = -1.328068155288572e1;

    double c1 = -7.784894002430293e-3;
    double c2 = -3.223964580411365e-1;
    double c3 = -2.400758277161838e0;
    double c4 = -2.549732539343734e0;
    double c5 = 4.374664141464968e0;
    double c6 = 2.938163982698783e0;

    double d1 = 7.784695709041462e-3;
    double d2 = 3.224671290700398e-1;
    double d3 = 2.445134137142996e0;
    double d4 = 3.754408661907416e0;

    double pLow = 0.02425;
    double pHigh = 1 - pLow;

    double q, r;

    if (p < pLow) {
      q = math.sqrt(-2 * math.log(p));
      return mean + stdDev * (((((c1 * q + c2) * q + c3) * q + c4) * q + c5) * q + c6) /
          ((((d1 * q + d2) * q + d3) * q + d4) * q + 1);
    } else if (p <= pHigh) {
      q = p - 0.5;
      r = q * q;
      return mean + stdDev * (((((a1 * r + a2) * r + a3) * r + a4) * r + a5) * r + a6) * q /
          (((((b1 * r + b2) * r + b3) * r + b4) * r + b5) * r + 1);
    } else {
      q = math.sqrt(-2 * math.log(1 - p));
      return mean + stdDev * -(((((c1 * q + c2) * q + c3) * q + c4) * q + c5) * q + c6) /
          ((((d1 * q + d2) * q + d3) * q + d4) * q + 1);
    }
  }

  /// Z-score
  static double zScore(double x, double mean, double stdDev) {
    return (x - mean) / stdDev;
  }

  /// Binomial probability
  static double binomialProbability(int n, int k, double p) {
    if (k < 0 || k > n) return 0;
    return _combination(n, k) * math.pow(p, k) * math.pow(1 - p, n - k);
  }

  /// Poisson probability
  static double poissonProbability(double lambda, int k) {
    if (k < 0) return 0;
    return math.pow(lambda, k) * math.exp(-lambda) / _factorial(k);
  }

  // ==================== HELPER FUNCTIONS ====================

  /// Error function (erf) approximation
  static double _erf(double x) {
    double a1 = 0.254829592;
    double a2 = -0.284496736;
    double a3 = 1.421413741;
    double a4 = -1.453152027;
    double a5 = 1.061405429;
    double p = 0.3275911;

    int sign = x < 0 ? -1 : 1;
    x = x.abs();

    double t = 1.0 / (1.0 + p * x);
    double y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * math.exp(-x * x);

    return sign * y;
  }

  /// Factorial
  static double _factorial(int n) {
    if (n <= 1) return 1;
    double result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  /// Combination nCr
  static double _combination(int n, int r) {
    if (r > n - r) r = n - r;
    double result = 1;
    for (int i = 0; i < r; i++) {
      result = result * (n - i) / (i + 1);
    }
    return result;
  }

  /// Solve linear system using Gaussian elimination
  static List<double> _solveLinearSystem(List<List<double>> a, List<double> b) {
    int n = a.length;

    // Augmented matrix
    List<List<double>> aug = List.generate(
      n,
      (i) => [...a[i], b[i]],
    );

    // Forward elimination
    for (int i = 0; i < n; i++) {
      int maxRow = i;
      for (int k = i + 1; k < n; k++) {
        if (aug[k][i].abs() > aug[maxRow][i].abs()) {
          maxRow = k;
        }
      }

      List<double> temp = aug[i];
      aug[i] = aug[maxRow];
      aug[maxRow] = temp;

      for (int k = i + 1; k < n; k++) {
        double factor = aug[k][i] / aug[i][i];
        for (int j = i; j <= n; j++) {
          aug[k][j] -= factor * aug[i][j];
        }
      }
    }

    // Back substitution
    List<double> x = List.filled(n, 0);
    for (int i = n - 1; i >= 0; i--) {
      x[i] = aug[i][n];
      for (int j = i + 1; j < n; j++) {
        x[i] -= aug[i][j] * x[j];
      }
      x[i] /= aug[i][i];
    }

    return x;
  }

  static String _format(double n) {
    if (n == n.roundToDouble()) return n.toInt().toString();
    return n.toStringAsFixed(4);
  }
}
