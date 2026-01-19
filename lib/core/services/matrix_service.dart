import 'dart:math' as math;

/// Matrix class for scientific calculator operations
class Matrix {
  final List<List<double>> data;
  final int rows;
  final int cols;

  Matrix(this.data)
      : rows = data.length,
        cols = data.isNotEmpty ? data[0].length : 0;

  /// Create a matrix from dimensions filled with zeros
  factory Matrix.zeros(int rows, int cols) {
    return Matrix(
      List.generate(rows, (_) => List.filled(cols, 0.0)),
    );
  }

  /// Create an identity matrix
  factory Matrix.identity(int size) {
    List<List<double>> data = List.generate(
      size,
      (i) => List.generate(size, (j) => i == j ? 1.0 : 0.0),
    );
    return Matrix(data);
  }

  /// Create a matrix from a flat list
  factory Matrix.fromFlat(List<double> values, int rows, int cols) {
    if (values.length != rows * cols) {
      throw Exception('Invalid dimensions for flat list');
    }
    List<List<double>> data = [];
    for (int i = 0; i < rows; i++) {
      data.add(values.sublist(i * cols, (i + 1) * cols));
    }
    return Matrix(data);
  }

  /// Get element at position
  double get(int row, int col) => data[row][col];

  /// Set element at position
  void set(int row, int col, double value) {
    data[row][col] = value;
  }

  /// Get a row as a list
  List<double> getRow(int row) => List.from(data[row]);

  /// Get a column as a list
  List<double> getCol(int col) {
    return List.generate(rows, (i) => data[i][col]);
  }

  /// Check if matrix is square
  bool get isSquare => rows == cols;

  /// Matrix addition
  Matrix operator +(Matrix other) {
    if (rows != other.rows || cols != other.cols) {
      throw Exception('Matrix dimensions must match for addition');
    }
    List<List<double>> result = List.generate(
      rows,
      (i) => List.generate(cols, (j) => data[i][j] + other.data[i][j]),
    );
    return Matrix(result);
  }

  /// Matrix subtraction
  Matrix operator -(Matrix other) {
    if (rows != other.rows || cols != other.cols) {
      throw Exception('Matrix dimensions must match for subtraction');
    }
    List<List<double>> result = List.generate(
      rows,
      (i) => List.generate(cols, (j) => data[i][j] - other.data[i][j]),
    );
    return Matrix(result);
  }

  /// Matrix multiplication
  Matrix operator *(Matrix other) {
    if (cols != other.rows) {
      throw Exception('Matrix dimensions invalid for multiplication');
    }
    List<List<double>> result = List.generate(
      rows,
      (i) => List.generate(other.cols, (j) {
        double sum = 0;
        for (int k = 0; k < cols; k++) {
          sum += data[i][k] * other.data[k][j];
        }
        return sum;
      }),
    );
    return Matrix(result);
  }

  /// Scalar multiplication
  Matrix scale(double scalar) {
    List<List<double>> result = List.generate(
      rows,
      (i) => List.generate(cols, (j) => data[i][j] * scalar),
    );
    return Matrix(result);
  }

  /// Matrix transpose
  Matrix transpose() {
    List<List<double>> result = List.generate(
      cols,
      (i) => List.generate(rows, (j) => data[j][i]),
    );
    return Matrix(result);
  }

  /// Calculate determinant (for square matrices)
  double determinant() {
    if (!isSquare) {
      throw Exception('Determinant only defined for square matrices');
    }
    return _determinantRecursive(data);
  }

  double _determinantRecursive(List<List<double>> matrix) {
    int n = matrix.length;
    if (n == 1) return matrix[0][0];
    if (n == 2) {
      return matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0];
    }

    double det = 0;
    for (int j = 0; j < n; j++) {
      det += math.pow(-1, j) * matrix[0][j] * _determinantRecursive(_minor(matrix, 0, j));
    }
    return det;
  }

  List<List<double>> _minor(List<List<double>> matrix, int row, int col) {
    int n = matrix.length;
    List<List<double>> minor = [];
    for (int i = 0; i < n; i++) {
      if (i == row) continue;
      List<double> newRow = [];
      for (int j = 0; j < n; j++) {
        if (j == col) continue;
        newRow.add(matrix[i][j]);
      }
      minor.add(newRow);
    }
    return minor;
  }

  /// Calculate trace (sum of diagonal elements)
  double trace() {
    if (!isSquare) {
      throw Exception('Trace only defined for square matrices');
    }
    double sum = 0;
    for (int i = 0; i < rows; i++) {
      sum += data[i][i];
    }
    return sum;
  }

  /// Matrix inverse using Gauss-Jordan elimination
  Matrix inverse() {
    if (!isSquare) {
      throw Exception('Inverse only defined for square matrices');
    }

    int n = rows;
    double det = determinant();
    if (det == 0) {
      throw Exception('Matrix is singular and cannot be inverted');
    }

    // Create augmented matrix [A|I]
    List<List<double>> augmented = List.generate(
      n,
      (i) => [...data[i], ...List.generate(n, (j) => i == j ? 1.0 : 0.0)],
    );

    // Gauss-Jordan elimination
    for (int i = 0; i < n; i++) {
      // Find pivot
      int maxRow = i;
      for (int k = i + 1; k < n; k++) {
        if (augmented[k][i].abs() > augmented[maxRow][i].abs()) {
          maxRow = k;
        }
      }

      // Swap rows
      List<double> temp = augmented[i];
      augmented[i] = augmented[maxRow];
      augmented[maxRow] = temp;

      // Scale pivot row
      double pivot = augmented[i][i];
      for (int j = 0; j < 2 * n; j++) {
        augmented[i][j] /= pivot;
      }

      // Eliminate column
      for (int k = 0; k < n; k++) {
        if (k != i) {
          double factor = augmented[k][i];
          for (int j = 0; j < 2 * n; j++) {
            augmented[k][j] -= factor * augmented[i][j];
          }
        }
      }
    }

    // Extract inverse matrix
    List<List<double>> result = List.generate(
      n,
      (i) => augmented[i].sublist(n),
    );

    return Matrix(result);
  }

  /// Calculate rank using row echelon form
  int rank() {
    List<List<double>> temp = List.generate(
      rows,
      (i) => List.from(data[i]),
    );

    int rank = 0;
    int row = 0;

    for (int col = 0; col < cols && row < rows; col++) {
      // Find pivot
      int pivotRow = -1;
      for (int i = row; i < rows; i++) {
        if (temp[i][col].abs() > 1e-10) {
          pivotRow = i;
          break;
        }
      }

      if (pivotRow == -1) continue;

      // Swap rows
      List<double> tempRow = temp[row];
      temp[row] = temp[pivotRow];
      temp[pivotRow] = tempRow;

      // Eliminate below
      for (int i = row + 1; i < rows; i++) {
        double factor = temp[i][col] / temp[row][col];
        for (int j = col; j < cols; j++) {
          temp[i][j] -= factor * temp[row][j];
        }
      }

      rank++;
      row++;
    }

    return rank;
  }

  /// LU Decomposition
  Map<String, Matrix> luDecomposition() {
    if (!isSquare) {
      throw Exception('LU decomposition requires square matrix');
    }

    int n = rows;
    Matrix L = Matrix.identity(n);
    Matrix U = Matrix.zeros(n, n);

    for (int i = 0; i < n; i++) {
      // Upper triangular
      for (int j = i; j < n; j++) {
        double sum = 0;
        for (int k = 0; k < i; k++) {
          sum += L.get(i, k) * U.get(k, j);
        }
        U.set(i, j, data[i][j] - sum);
      }

      // Lower triangular
      for (int j = i + 1; j < n; j++) {
        double sum = 0;
        for (int k = 0; k < i; k++) {
          sum += L.get(j, k) * U.get(k, i);
        }
        if (U.get(i, i) == 0) {
          throw Exception('LU decomposition failed: zero pivot');
        }
        L.set(j, i, (data[j][i] - sum) / U.get(i, i));
      }
    }

    return {'L': L, 'U': U};
  }

  /// Eigenvalues for 2x2 and 3x3 matrices (analytical solution)
  List<double> eigenvalues() {
    if (!isSquare) {
      throw Exception('Eigenvalues only defined for square matrices');
    }

    if (rows == 2) {
      // For 2x2: λ² - trace*λ + det = 0
      double tr = trace();
      double det = determinant();
      double discriminant = tr * tr - 4 * det;

      if (discriminant >= 0) {
        double sqrtD = math.sqrt(discriminant);
        return [(tr + sqrtD) / 2, (tr - sqrtD) / 2];
      } else {
        // Complex eigenvalues - return real parts
        return [tr / 2, tr / 2];
      }
    } else if (rows == 3) {
      // For 3x3 using Cardano's formula
      return _eigenvalues3x3();
    } else {
      // For larger matrices, use power iteration approximation
      return _eigenvaluesPowerIteration();
    }
  }

  List<double> _eigenvalues3x3() {
    double a = data[0][0], b = data[0][1], c = data[0][2];
    double d = data[1][0], e = data[1][1], f = data[1][2];
    double g = data[2][0], h = data[2][1], i = data[2][2];

    // Characteristic polynomial: -λ³ + p*λ² + q*λ + r = 0
    double p = a + e + i; // trace
    double q = b * d + c * g + f * h - a * e - a * i - e * i;
    double r = determinant();

    // Convert to depressed cubic: t³ + pt + q = 0
    double p2 = p * p;
    double p3 = p2 * p;
    double pp = q + p2 / 3;
    double qq = 2 * p3 / 27 - p * q / 3 + r;

    // Cardano's formula
    double discriminant = qq * qq / 4 + pp * pp * pp / 27;

    List<double> eigenvalues = [];

    if (discriminant > 0) {
      double sqrtD = math.sqrt(discriminant);
      double u = _cbrt(-qq / 2 + sqrtD);
      double v = _cbrt(-qq / 2 - sqrtD);
      eigenvalues.add(u + v + p / 3);
    } else {
      // Three real roots
      double m = 2 * math.sqrt(-pp / 3);
      double theta = math.acos(3 * qq / (pp * m)) / 3;
      eigenvalues.add(m * math.cos(theta) + p / 3);
      eigenvalues.add(m * math.cos(theta - 2 * math.pi / 3) + p / 3);
      eigenvalues.add(m * math.cos(theta - 4 * math.pi / 3) + p / 3);
    }

    return eigenvalues;
  }

  double _cbrt(double x) {
    return x < 0 ? -math.pow(-x, 1 / 3).toDouble() : math.pow(x, 1 / 3).toDouble();
  }

  List<double> _eigenvaluesPowerIteration() {
    // Simple power iteration for largest eigenvalue
    List<double> v = List.filled(rows, 1.0);
    double eigenvalue = 0;

    for (int iter = 0; iter < 100; iter++) {
      // Matrix-vector multiplication
      List<double> av = List.filled(rows, 0.0);
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          av[i] += data[i][j] * v[j];
        }
      }

      // Find max component
      double maxVal = av.reduce((a, b) => a.abs() > b.abs() ? a : b);
      eigenvalue = maxVal;

      // Normalize
      for (int i = 0; i < rows; i++) {
        v[i] = av[i] / maxVal;
      }
    }

    return [eigenvalue];
  }

  /// Row Echelon Form
  Matrix rowEchelonForm() {
    List<List<double>> result = List.generate(
      rows,
      (i) => List.from(data[i]),
    );

    int lead = 0;
    for (int r = 0; r < rows; r++) {
      if (lead >= cols) break;

      int i = r;
      while (result[i][lead].abs() < 1e-10) {
        i++;
        if (i == rows) {
          i = r;
          lead++;
          if (lead == cols) return Matrix(result);
        }
      }

      // Swap rows
      List<double> temp = result[r];
      result[r] = result[i];
      result[i] = temp;

      // Scale row
      double lv = result[r][lead];
      for (int j = 0; j < cols; j++) {
        result[r][j] /= lv;
      }

      // Eliminate
      for (int j = 0; j < rows; j++) {
        if (j != r) {
          double lv2 = result[j][lead];
          for (int k = 0; k < cols; k++) {
            result[j][k] -= lv2 * result[r][k];
          }
        }
      }

      lead++;
    }

    return Matrix(result);
  }

  /// Calculate matrix power
  Matrix power(int n) {
    if (!isSquare) {
      throw Exception('Matrix power requires square matrix');
    }

    if (n == 0) return Matrix.identity(rows);
    if (n == 1) return Matrix(data);

    if (n < 0) {
      return inverse().power(-n);
    }

    // Binary exponentiation
    Matrix result = Matrix.identity(rows);
    Matrix base = Matrix(data);

    while (n > 0) {
      if (n % 2 == 1) {
        result = result * base;
      }
      base = base * base;
      n ~/= 2;
    }

    return result;
  }

  /// Frobenius norm
  double frobeniusNorm() {
    double sum = 0;
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        sum += data[i][j] * data[i][j];
      }
    }
    return math.sqrt(sum);
  }

  /// Convert to string for display
  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < rows; i++) {
      sb.write('[');
      for (int j = 0; j < cols; j++) {
        double val = data[i][j];
        // Format nicely
        if (val == val.roundToDouble()) {
          sb.write(val.toInt());
        } else {
          sb.write(val.toStringAsFixed(4));
        }
        if (j < cols - 1) sb.write(', ');
      }
      sb.write(']');
      if (i < rows - 1) sb.write('\n');
    }
    return sb.toString();
  }

  /// Convert to flat list
  List<double> toFlat() {
    List<double> flat = [];
    for (var row in data) {
      flat.addAll(row);
    }
    return flat;
  }

  /// Deep copy
  Matrix copy() {
    return Matrix(List.generate(
      rows,
      (i) => List.from(data[i]),
    ));
  }
}

/// Matrix operations service for the calculator
class MatrixService {
  /// Add two matrices
  static Matrix add(Matrix a, Matrix b) => a + b;

  /// Subtract two matrices
  static Matrix subtract(Matrix a, Matrix b) => a - b;

  /// Multiply two matrices
  static Matrix multiply(Matrix a, Matrix b) => a * b;

  /// Scale a matrix by a scalar
  static Matrix scale(Matrix m, double scalar) => m.scale(scalar);

  /// Get transpose of a matrix
  static Matrix transpose(Matrix m) => m.transpose();

  /// Get determinant of a matrix
  static double determinant(Matrix m) => m.determinant();

  /// Get inverse of a matrix
  static Matrix inverse(Matrix m) => m.inverse();

  /// Get trace of a matrix
  static double trace(Matrix m) => m.trace();

  /// Get rank of a matrix
  static int rank(Matrix m) => m.rank();

  /// Get eigenvalues of a matrix
  static List<double> eigenvalues(Matrix m) => m.eigenvalues();

  /// Get row echelon form
  static Matrix rowEchelonForm(Matrix m) => m.rowEchelonForm();

  /// Calculate matrix power
  static Matrix power(Matrix m, int n) => m.power(n);

  /// Calculate Frobenius norm
  static double frobeniusNorm(Matrix m) => m.frobeniusNorm();

  /// LU Decomposition
  static Map<String, Matrix> luDecomposition(Matrix m) => m.luDecomposition();

  /// Solve system Ax = b using LU decomposition
  static List<double> solveSystem(Matrix a, List<double> b) {
    if (!a.isSquare || a.rows != b.length) {
      throw Exception('Invalid dimensions for system solving');
    }

    int n = a.rows;
    Map<String, Matrix> lu = a.luDecomposition();
    Matrix L = lu['L']!;
    Matrix U = lu['U']!;

    // Forward substitution: Ly = b
    List<double> y = List.filled(n, 0.0);
    for (int i = 0; i < n; i++) {
      double sum = 0;
      for (int j = 0; j < i; j++) {
        sum += L.get(i, j) * y[j];
      }
      y[i] = b[i] - sum;
    }

    // Back substitution: Ux = y
    List<double> x = List.filled(n, 0.0);
    for (int i = n - 1; i >= 0; i--) {
      double sum = 0;
      for (int j = i + 1; j < n; j++) {
        sum += U.get(i, j) * x[j];
      }
      x[i] = (y[i] - sum) / U.get(i, i);
    }

    return x;
  }

  /// Create rotation matrix (2D)
  static Matrix rotation2D(double angle, {bool radians = true}) {
    double a = radians ? angle : angle * math.pi / 180;
    return Matrix([
      [math.cos(a), -math.sin(a)],
      [math.sin(a), math.cos(a)],
    ]);
  }

  /// Create rotation matrix around X axis (3D)
  static Matrix rotationX(double angle, {bool radians = true}) {
    double a = radians ? angle : angle * math.pi / 180;
    return Matrix([
      [1, 0, 0],
      [0, math.cos(a), -math.sin(a)],
      [0, math.sin(a), math.cos(a)],
    ]);
  }

  /// Create rotation matrix around Y axis (3D)
  static Matrix rotationY(double angle, {bool radians = true}) {
    double a = radians ? angle : angle * math.pi / 180;
    return Matrix([
      [math.cos(a), 0, math.sin(a)],
      [0, 1, 0],
      [-math.sin(a), 0, math.cos(a)],
    ]);
  }

  /// Create rotation matrix around Z axis (3D)
  static Matrix rotationZ(double angle, {bool radians = true}) {
    double a = radians ? angle : angle * math.pi / 180;
    return Matrix([
      [math.cos(a), -math.sin(a), 0],
      [math.sin(a), math.cos(a), 0],
      [0, 0, 1],
    ]);
  }
}
