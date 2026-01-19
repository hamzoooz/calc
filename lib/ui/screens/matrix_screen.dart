import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modern_calculator/core/constants/app_colors.dart';
import 'package:modern_calculator/core/services/matrix_service.dart';

class MatrixScreen extends StatefulWidget {
  const MatrixScreen({super.key});

  @override
  State<MatrixScreen> createState() => _MatrixScreenState();
}

class _MatrixScreenState extends State<MatrixScreen> {
  int _matrixARows = 2;
  int _matrixACols = 2;
  int _matrixBRows = 2;
  int _matrixBCols = 2;

  List<List<TextEditingController>> _controllersA = [];
  List<List<TextEditingController>> _controllersB = [];

  String _result = '';
  String _selectedOperation = 'add';
  bool _showMatrixB = true;

  final List<_MatrixOperation> _operations = [
    _MatrixOperation('add', 'A + B', Icons.add),
    _MatrixOperation('subtract', 'A - B', Icons.remove),
    _MatrixOperation('multiply', 'A × B', Icons.close),
    _MatrixOperation('transpose', 'Aᵀ', Icons.swap_horiz),
    _MatrixOperation('determinant', 'det(A)', Icons.crop_square),
    _MatrixOperation('inverse', 'A⁻¹', Icons.flip),
    _MatrixOperation('trace', 'tr(A)', Icons.show_chart),
    _MatrixOperation('rank', 'rank(A)', Icons.format_list_numbered),
    _MatrixOperation('eigenvalues', 'λ', Icons.auto_graph),
    _MatrixOperation('power', 'Aⁿ', Icons.superscript),
  ];

  final TextEditingController _powerController = TextEditingController(text: '2');

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _controllersA = List.generate(
      _matrixARows,
      (i) => List.generate(_matrixACols, (j) => TextEditingController(text: '0')),
    );
    _controllersB = List.generate(
      _matrixBRows,
      (i) => List.generate(_matrixBCols, (j) => TextEditingController(text: '0')),
    );
  }

  void _updateMatrixASize(int rows, int cols) {
    setState(() {
      _matrixARows = rows;
      _matrixACols = cols;
      _controllersA = List.generate(
        rows,
        (i) => List.generate(cols, (j) {
          if (i < _controllersA.length && j < _controllersA[0].length) {
            return _controllersA[i][j];
          }
          return TextEditingController(text: '0');
        }),
      );
    });
  }

  void _updateMatrixBSize(int rows, int cols) {
    setState(() {
      _matrixBRows = rows;
      _matrixBCols = cols;
      _controllersB = List.generate(
        rows,
        (i) => List.generate(cols, (j) {
          if (i < _controllersB.length && j < _controllersB[0].length) {
            return _controllersB[i][j];
          }
          return TextEditingController(text: '0');
        }),
      );
    });
  }

  Matrix _getMatrixA() {
    List<List<double>> data = [];
    for (int i = 0; i < _matrixARows; i++) {
      List<double> row = [];
      for (int j = 0; j < _matrixACols; j++) {
        row.add(double.tryParse(_controllersA[i][j].text) ?? 0);
      }
      data.add(row);
    }
    return Matrix(data);
  }

  Matrix _getMatrixB() {
    List<List<double>> data = [];
    for (int i = 0; i < _matrixBRows; i++) {
      List<double> row = [];
      for (int j = 0; j < _matrixBCols; j++) {
        row.add(double.tryParse(_controllersB[i][j].text) ?? 0);
      }
      data.add(row);
    }
    return Matrix(data);
  }

  void _calculate() {
    try {
      Matrix a = _getMatrixA();
      Matrix b = _getMatrixB();
      String resultStr = '';

      switch (_selectedOperation) {
        case 'add':
          Matrix result = MatrixService.add(a, b);
          resultStr = 'A + B =\n${result.toString()}';
          break;
        case 'subtract':
          Matrix result = MatrixService.subtract(a, b);
          resultStr = 'A - B =\n${result.toString()}';
          break;
        case 'multiply':
          Matrix result = MatrixService.multiply(a, b);
          resultStr = 'A × B =\n${result.toString()}';
          break;
        case 'transpose':
          Matrix result = MatrixService.transpose(a);
          resultStr = 'Aᵀ =\n${result.toString()}';
          break;
        case 'determinant':
          double det = MatrixService.determinant(a);
          resultStr = 'det(A) = ${_formatNumber(det)}';
          break;
        case 'inverse':
          Matrix result = MatrixService.inverse(a);
          resultStr = 'A⁻¹ =\n${result.toString()}';
          break;
        case 'trace':
          double tr = MatrixService.trace(a);
          resultStr = 'tr(A) = ${_formatNumber(tr)}';
          break;
        case 'rank':
          int r = MatrixService.rank(a);
          resultStr = 'rank(A) = $r';
          break;
        case 'eigenvalues':
          List<double> eigenvals = MatrixService.eigenvalues(a);
          resultStr = 'Eigenvalues:\n${eigenvals.map((e) => 'λ = ${_formatNumber(e)}').join('\n')}';
          break;
        case 'power':
          int n = int.tryParse(_powerController.text) ?? 2;
          Matrix result = MatrixService.power(a, n);
          resultStr = 'A^$n =\n${result.toString()}';
          break;
      }

      setState(() {
        _result = resultStr;
      });

      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
      });
      HapticFeedback.heavyImpact();
    }
  }

  String _formatNumber(double n) {
    if (n == n.roundToDouble()) return n.toInt().toString();
    return n.toStringAsFixed(4);
  }

  void _clearAll() {
    for (var row in _controllersA) {
      for (var ctrl in row) {
        ctrl.text = '0';
      }
    }
    for (var row in _controllersB) {
      for (var ctrl in row) {
        ctrl.text = '0';
      }
    }
    setState(() {
      _result = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine if matrix B should be shown based on operation
    _showMatrixB = ['add', 'subtract', 'multiply'].contains(_selectedOperation);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Operation selector
          _buildOperationSelector(isDark),
          const SizedBox(height: 16),

          // Matrix A
          _buildMatrixSection(
            isDark,
            'Matrix A',
            _matrixARows,
            _matrixACols,
            _controllersA,
            (r, c) => _updateMatrixASize(r, c),
            AppColors.matrix,
          ),
          const SizedBox(height: 16),

          // Matrix B (conditional)
          if (_showMatrixB) ...[
            _buildMatrixSection(
              isDark,
              'Matrix B',
              _matrixBRows,
              _matrixBCols,
              _controllersB,
              (r, c) => _updateMatrixBSize(r, c),
              AppColors.equations,
            ),
            const SizedBox(height: 16),
          ],

          // Power input for power operation
          if (_selectedOperation == 'power')
            _buildPowerInput(isDark),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  isDark,
                  'Clear',
                  Icons.clear_all,
                  _clearAll,
                  isSecondary: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildActionButton(
                  isDark,
                  'Calculate',
                  Icons.calculate,
                  _calculate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Result
          if (_result.isNotEmpty) _buildResultCard(isDark),
        ],
      ),
    );
  }

  Widget _buildOperationSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.inputBorderDark : AppColors.inputBorderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operation',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _operations.map((op) {
              bool isSelected = _selectedOperation == op.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedOperation = op.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.matrixGradient : null,
                    color: isSelected ? null : (isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(8)),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppColors.matrix.withAlpha(77),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        op.icon,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        op.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.textDark : AppColors.textLight),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixSection(
    bool isDark,
    String title,
    int rows,
    int cols,
    List<List<TextEditingController>> controllers,
    Function(int, int) onSizeChanged,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.inputBorderDark : AppColors.inputBorderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
              Row(
                children: [
                  _buildSizeSelector(isDark, 'Rows', rows, (v) => onSizeChanged(v, cols)),
                  const SizedBox(width: 12),
                  _buildSizeSelector(isDark, 'Cols', cols, (v) => onSizeChanged(rows, v)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMatrixGrid(isDark, rows, cols, controllers, accentColor),
        ],
      ),
    );
  }

  Widget _buildSizeSelector(bool isDark, String label, int value, Function(int) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(8),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: value > 1 ? () => onChanged(value - 1) : null,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.remove, size: 16,
                    color: value > 1
                        ? (isDark ? AppColors.textDark : AppColors.textLight)
                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
              ),
              InkWell(
                onTap: value < 5 ? () => onChanged(value + 1) : null,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.add, size: 16,
                    color: value < 5
                        ? (isDark ? AppColors.textDark : AppColors.textLight)
                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatrixGrid(
    bool isDark,
    int rows,
    int cols,
    List<List<TextEditingController>> controllers,
    Color accentColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: accentColor.withAlpha(77),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: List.generate(rows, (i) {
          return Row(
            children: List.generate(cols, (j) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.all(2),
                  child: TextField(
                    controller: controllers[i][j],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? AppColors.inputBgDark : AppColors.inputBgLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildPowerInput(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.inputBorderDark : AppColors.inputBorderLight,
        ),
      ),
      child: Row(
        children: [
          Text(
            'Power (n):',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _powerController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? AppColors.inputBgDark : AppColors.inputBgLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    bool isDark,
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool isSecondary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isSecondary ? null : AppColors.matrixGradient,
          color: isSecondary
              ? (isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(8))
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSecondary ? null : [
            BoxShadow(
              color: AppColors.matrix.withAlpha(77),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSecondary
                  ? (isDark ? AppColors.textDark : AppColors.textLight)
                  : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSecondary
                    ? (isDark ? AppColors.textDark : AppColors.textLight)
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(bool isDark) {
    bool isError = _result.startsWith('Error');

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? (isError ? AppColors.error.withAlpha(26) : AppColors.matrix.withAlpha(26))
                : (isError ? AppColors.error.withAlpha(26) : AppColors.matrix.withAlpha(26)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isError ? AppColors.error.withAlpha(77) : AppColors.matrix.withAlpha(77),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: isError ? AppColors.error : AppColors.matrix,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isError ? 'Error' : 'Result',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isError ? AppColors.error : AppColors.matrix,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SelectableText(
                _result,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatrixOperation {
  final String id;
  final String label;
  final IconData icon;

  _MatrixOperation(this.id, this.label, this.icon);
}
