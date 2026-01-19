import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modern_calculator/core/constants/app_colors.dart';
import 'package:modern_calculator/core/services/equation_solver.dart';

class EquationsScreen extends StatefulWidget {
  const EquationsScreen({super.key});

  @override
  State<EquationsScreen> createState() => _EquationsScreenState();
}

class _EquationsScreenState extends State<EquationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _result = '';
  bool _hasError = false;

  // Polynomial equation controllers
  final _linearA = TextEditingController(text: '1');
  final _linearB = TextEditingController(text: '0');

  final _quadA = TextEditingController(text: '1');
  final _quadB = TextEditingController(text: '0');
  final _quadC = TextEditingController(text: '0');

  final _cubicA = TextEditingController(text: '1');
  final _cubicB = TextEditingController(text: '0');
  final _cubicC = TextEditingController(text: '0');
  final _cubicD = TextEditingController(text: '0');

  final _quarticA = TextEditingController(text: '1');
  final _quarticB = TextEditingController(text: '0');
  final _quarticC = TextEditingController(text: '0');
  final _quarticD = TextEditingController(text: '0');
  final _quarticE = TextEditingController(text: '0');

  // System of equations controllers (2x2)
  final _sys2a1 = TextEditingController(text: '1');
  final _sys2b1 = TextEditingController(text: '0');
  final _sys2c1 = TextEditingController(text: '0');
  final _sys2a2 = TextEditingController(text: '0');
  final _sys2b2 = TextEditingController(text: '1');
  final _sys2c2 = TextEditingController(text: '0');

  // System of equations controllers (3x3)
  final _sys3a1 = TextEditingController(text: '1');
  final _sys3b1 = TextEditingController(text: '0');
  final _sys3c1 = TextEditingController(text: '0');
  final _sys3d1 = TextEditingController(text: '0');
  final _sys3a2 = TextEditingController(text: '0');
  final _sys3b2 = TextEditingController(text: '1');
  final _sys3c2 = TextEditingController(text: '0');
  final _sys3d2 = TextEditingController(text: '0');
  final _sys3a3 = TextEditingController(text: '0');
  final _sys3b3 = TextEditingController(text: '0');
  final _sys3c3 = TextEditingController(text: '1');
  final _sys3d3 = TextEditingController(text: '0');

  final List<_EquationType> _equationTypes = [
    _EquationType('linear', 'Linear', 'ax + b = 0', Icons.show_chart),
    _EquationType('quadratic', 'Quadratic', 'ax² + bx + c = 0', Icons.auto_graph),
    _EquationType('cubic', 'Cubic', 'ax³ + bx² + cx + d = 0', Icons.timeline),
    _EquationType('quartic', 'Quartic', 'ax⁴ + bx³ + cx² + dx + e = 0', Icons.ssid_chart),
    _EquationType('system2', '2×2 System', 'Two variables', Icons.grid_3x3),
    _EquationType('system3', '3×3 System', 'Three variables', Icons.grid_4x4),
  ];

  String _selectedType = 'quadratic';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _solve() {
    try {
      String resultStr = '';

      switch (_selectedType) {
        case 'linear':
          double a = double.tryParse(_linearA.text) ?? 0;
          double b = double.tryParse(_linearB.text) ?? 0;
          EquationResult result = EquationSolver.solveLinear(a, b);
          resultStr = '${result.equation}\n\n${result.type}\n\n${result.toString()}';
          break;

        case 'quadratic':
          double a = double.tryParse(_quadA.text) ?? 0;
          double b = double.tryParse(_quadB.text) ?? 0;
          double c = double.tryParse(_quadC.text) ?? 0;
          EquationResult result = EquationSolver.solveQuadratic(a, b, c);
          resultStr = '${result.equation}\n\n${result.type}\n\n${result.toString()}';
          break;

        case 'cubic':
          double a = double.tryParse(_cubicA.text) ?? 0;
          double b = double.tryParse(_cubicB.text) ?? 0;
          double c = double.tryParse(_cubicC.text) ?? 0;
          double d = double.tryParse(_cubicD.text) ?? 0;
          EquationResult result = EquationSolver.solveCubic(a, b, c, d);
          resultStr = '${result.equation}\n\n${result.type}\n\n${result.toString()}';
          break;

        case 'quartic':
          double a = double.tryParse(_quarticA.text) ?? 0;
          double b = double.tryParse(_quarticB.text) ?? 0;
          double c = double.tryParse(_quarticC.text) ?? 0;
          double d = double.tryParse(_quarticD.text) ?? 0;
          double e = double.tryParse(_quarticE.text) ?? 0;
          EquationResult result = EquationSolver.solveQuartic(a, b, c, d, e);
          resultStr = '${result.equation}\n\n${result.type}\n\n${result.toString()}';
          break;

        case 'system2':
          double a1 = double.tryParse(_sys2a1.text) ?? 0;
          double b1 = double.tryParse(_sys2b1.text) ?? 0;
          double c1 = double.tryParse(_sys2c1.text) ?? 0;
          double a2 = double.tryParse(_sys2a2.text) ?? 0;
          double b2 = double.tryParse(_sys2b2.text) ?? 0;
          double c2 = double.tryParse(_sys2c2.text) ?? 0;

          Map<String, double>? result = EquationSolver.solve2x2System(
            a1, b1, c1, a2, b2, c2,
          );

          if (result != null) {
            resultStr = 'System of Equations:\n'
                '${_formatCoef(a1)}x + ${_formatCoef(b1)}y = ${_formatCoef(c1)}\n'
                '${_formatCoef(a2)}x + ${_formatCoef(b2)}y = ${_formatCoef(c2)}\n\n'
                'Solution:\nx = ${_formatNum(result['x']!)}\ny = ${_formatNum(result['y']!)}';
          } else {
            resultStr = 'No unique solution exists (system is singular)';
          }
          break;

        case 'system3':
          double a1 = double.tryParse(_sys3a1.text) ?? 0;
          double b1 = double.tryParse(_sys3b1.text) ?? 0;
          double c1 = double.tryParse(_sys3c1.text) ?? 0;
          double d1 = double.tryParse(_sys3d1.text) ?? 0;
          double a2 = double.tryParse(_sys3a2.text) ?? 0;
          double b2 = double.tryParse(_sys3b2.text) ?? 0;
          double c2 = double.tryParse(_sys3c2.text) ?? 0;
          double d2 = double.tryParse(_sys3d2.text) ?? 0;
          double a3 = double.tryParse(_sys3a3.text) ?? 0;
          double b3 = double.tryParse(_sys3b3.text) ?? 0;
          double c3 = double.tryParse(_sys3c3.text) ?? 0;
          double d3 = double.tryParse(_sys3d3.text) ?? 0;

          Map<String, double>? result = EquationSolver.solve3x3System(
            a1, b1, c1, d1,
            a2, b2, c2, d2,
            a3, b3, c3, d3,
          );

          if (result != null) {
            resultStr = 'System of Equations:\n'
                '${_formatCoef(a1)}x + ${_formatCoef(b1)}y + ${_formatCoef(c1)}z = ${_formatCoef(d1)}\n'
                '${_formatCoef(a2)}x + ${_formatCoef(b2)}y + ${_formatCoef(c2)}z = ${_formatCoef(d2)}\n'
                '${_formatCoef(a3)}x + ${_formatCoef(b3)}y + ${_formatCoef(c3)}z = ${_formatCoef(d3)}\n\n'
                'Solution:\nx = ${_formatNum(result['x']!)}\ny = ${_formatNum(result['y']!)}\nz = ${_formatNum(result['z']!)}';
          } else {
            resultStr = 'No unique solution exists (system is singular)';
          }
          break;
      }

      setState(() {
        _result = resultStr;
        _hasError = false;
      });

      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
        _hasError = true;
      });
      HapticFeedback.heavyImpact();
    }
  }

  String _formatNum(double n) {
    if (n == n.roundToDouble()) return n.toInt().toString();
    return n.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  String _formatCoef(double c) {
    if (c == c.roundToDouble()) return c.toInt().toString();
    return c.toStringAsFixed(2);
  }

  void _clearAll() {
    _linearA.text = '1';
    _linearB.text = '0';
    _quadA.text = '1';
    _quadB.text = '0';
    _quadC.text = '0';
    _cubicA.text = '1';
    _cubicB.text = '0';
    _cubicC.text = '0';
    _cubicD.text = '0';
    _quarticA.text = '1';
    _quarticB.text = '0';
    _quarticC.text = '0';
    _quarticD.text = '0';
    _quarticE.text = '0';
    _sys2a1.text = '1';
    _sys2b1.text = '0';
    _sys2c1.text = '0';
    _sys2a2.text = '0';
    _sys2b2.text = '1';
    _sys2c2.text = '0';
    _sys3a1.text = '1';
    _sys3b1.text = '0';
    _sys3c1.text = '0';
    _sys3d1.text = '0';
    _sys3a2.text = '0';
    _sys3b2.text = '1';
    _sys3c2.text = '0';
    _sys3d2.text = '0';
    _sys3a3.text = '0';
    _sys3b3.text = '0';
    _sys3c3.text = '1';
    _sys3d3.text = '0';
    setState(() {
      _result = '';
      _hasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Equation Type Selector
          _buildTypeSelector(isDark),
          const SizedBox(height: 16),

          // Coefficient Input
          _buildCoefficientInput(isDark),
          const SizedBox(height: 16),

          // Action Buttons
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
                  'Solve',
                  Icons.calculate,
                  _solve,
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

  Widget _buildTypeSelector(bool isDark) {
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
            'Equation Type',
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
            children: _equationTypes.map((type) {
              bool isSelected = _selectedType == type.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedType = type.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.equationsGradient : null,
                    color: isSelected
                        ? null
                        : (isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(8)),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.equations.withAlpha(77),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type.icon,
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            type.label,
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
                      const SizedBox(height: 2),
                      Text(
                        type.formula,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? Colors.white70
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight),
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

  Widget _buildCoefficientInput(bool isDark) {
    switch (_selectedType) {
      case 'linear':
        return _buildLinearInput(isDark);
      case 'quadratic':
        return _buildQuadraticInput(isDark);
      case 'cubic':
        return _buildCubicInput(isDark);
      case 'quartic':
        return _buildQuarticInput(isDark);
      case 'system2':
        return _buildSystem2Input(isDark);
      case 'system3':
        return _buildSystem3Input(isDark);
      default:
        return _buildQuadraticInput(isDark);
    }
  }

  Widget _buildLinearInput(bool isDark) {
    return _buildInputCard(
      isDark,
      'Linear Equation: ax + b = 0',
      [
        _buildCoefRow(isDark, [
          _buildCoefField(isDark, 'a', _linearA, AppColors.equations),
          const Text('x + ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          _buildCoefField(isDark, 'b', _linearB, AppColors.equations),
          const Text(' = 0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ]),
      ],
    );
  }

  Widget _buildQuadraticInput(bool isDark) {
    return _buildInputCard(
      isDark,
      'Quadratic Equation: ax² + bx + c = 0',
      [
        _buildCoefRow(isDark, [
          _buildCoefField(isDark, 'a', _quadA, AppColors.equations),
          const Text('x² + ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          _buildCoefField(isDark, 'b', _quadB, AppColors.equations),
          const Text('x + ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          _buildCoefField(isDark, 'c', _quadC, AppColors.equations),
          const Text(' = 0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ]),
      ],
    );
  }

  Widget _buildCubicInput(bool isDark) {
    return _buildInputCard(
      isDark,
      'Cubic Equation: ax³ + bx² + cx + d = 0',
      [
        _buildCoefRow(isDark, [
          _buildCoefField(isDark, 'a', _cubicA, AppColors.equations),
          const Text('x³ + ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          _buildCoefField(isDark, 'b', _cubicB, AppColors.equations),
          const Text('x² + ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 8),
        _buildCoefRow(isDark, [
          _buildCoefField(isDark, 'c', _cubicC, AppColors.equations),
          const Text('x + ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          _buildCoefField(isDark, 'd', _cubicD, AppColors.equations),
          const Text(' = 0', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ]),
      ],
    );
  }

  Widget _buildQuarticInput(bool isDark) {
    return _buildInputCard(
      isDark,
      'Quartic Equation: ax⁴ + bx³ + cx² + dx + e = 0',
      [
        _buildCoefRow(isDark, [
          _buildCoefField(isDark, 'a', _quarticA, AppColors.equations, width: 50),
          const Text('x⁴+', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          _buildCoefField(isDark, 'b', _quarticB, AppColors.equations, width: 50),
          const Text('x³+', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          _buildCoefField(isDark, 'c', _quarticC, AppColors.equations, width: 50),
          const Text('x²', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 8),
        _buildCoefRow(isDark, [
          const Text('+', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          _buildCoefField(isDark, 'd', _quarticD, AppColors.equations, width: 60),
          const Text('x + ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          _buildCoefField(isDark, 'e', _quarticE, AppColors.equations, width: 60),
          const Text(' = 0', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ]),
      ],
    );
  }

  Widget _buildSystem2Input(bool isDark) {
    return _buildInputCard(
      isDark,
      '2×2 System of Linear Equations',
      [
        _buildSystemRow(isDark, [
          _buildCoefField(isDark, 'a₁', _sys2a1, AppColors.equations, width: 55),
          const Text('x + ', style: TextStyle(fontSize: 14)),
          _buildCoefField(isDark, 'b₁', _sys2b1, AppColors.equations, width: 55),
          const Text('y = ', style: TextStyle(fontSize: 14)),
          _buildCoefField(isDark, 'c₁', _sys2c1, AppColors.info, width: 55),
        ]),
        const SizedBox(height: 8),
        _buildSystemRow(isDark, [
          _buildCoefField(isDark, 'a₂', _sys2a2, AppColors.equations, width: 55),
          const Text('x + ', style: TextStyle(fontSize: 14)),
          _buildCoefField(isDark, 'b₂', _sys2b2, AppColors.equations, width: 55),
          const Text('y = ', style: TextStyle(fontSize: 14)),
          _buildCoefField(isDark, 'c₂', _sys2c2, AppColors.info, width: 55),
        ]),
      ],
    );
  }

  Widget _buildSystem3Input(bool isDark) {
    return _buildInputCard(
      isDark,
      '3×3 System of Linear Equations',
      [
        _buildSystemRow(isDark, [
          _buildCoefField(isDark, 'a₁', _sys3a1, AppColors.equations, width: 45),
          const Text('x+', style: TextStyle(fontSize: 12)),
          _buildCoefField(isDark, 'b₁', _sys3b1, AppColors.equations, width: 45),
          const Text('y+', style: TextStyle(fontSize: 12)),
          _buildCoefField(isDark, 'c₁', _sys3c1, AppColors.equations, width: 45),
          const Text('z=', style: TextStyle(fontSize: 12)),
          _buildCoefField(isDark, 'd₁', _sys3d1, AppColors.info, width: 45),
        ]),
        const SizedBox(height: 6),
        _buildSystemRow(isDark, [
          _buildCoefField(isDark, 'a₂', _sys3a2, AppColors.equations, width: 45),
          const Text('x+', style: TextStyle(fontSize: 12)),
          _buildCoefField(isDark, 'b₂', _sys3b2, AppColors.equations, width: 45),
          const Text('y+', style: TextStyle(fontSize: 12)),
          _buildCoefField(isDark, 'c₂', _sys3c2, AppColors.equations, width: 45),
          const Text('z=', style: TextStyle(fontSize: 12)),
          _buildCoefField(isDark, 'd₂', _sys3d2, AppColors.info, width: 45),
        ]),
        const SizedBox(height: 6),
        _buildSystemRow(isDark, [
          _buildCoefField(isDark, 'a₃', _sys3a3, AppColors.equations, width: 45),
          const Text('x+', style: TextStyle(fontSize: 12)),
          _buildCoefField(isDark, 'b₃', _sys3b3, AppColors.equations, width: 45),
          const Text('y+', style: TextStyle(fontSize: 12)),
          _buildCoefField(isDark, 'c₃', _sys3c3, AppColors.equations, width: 45),
          const Text('z=', style: TextStyle(fontSize: 12)),
          _buildCoefField(isDark, 'd₃', _sys3d3, AppColors.info, width: 45),
        ]),
      ],
    );
  }

  Widget _buildInputCard(bool isDark, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.equations,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCoefRow(bool isDark, List<Widget> children) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildSystemRow(bool isDark, List<Widget> children) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildCoefField(
    bool isDark,
    String label,
    TextEditingController controller,
    Color accentColor, {
    double width = 60,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: isDark ? AppColors.inputBgDark : AppColors.inputBgLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: accentColor.withAlpha(77)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: accentColor.withAlpha(77)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 12,
            color: accentColor,
          ),
        ),
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
          gradient: isSecondary ? null : AppColors.equationsGradient,
          color: isSecondary
              ? (isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(8))
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSecondary
              ? null
              : [
                  BoxShadow(
                    color: AppColors.equations.withAlpha(77),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? (_hasError
                    ? AppColors.error.withAlpha(26)
                    : AppColors.equations.withAlpha(26))
                : (_hasError
                    ? AppColors.error.withAlpha(26)
                    : AppColors.equations.withAlpha(26)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hasError
                  ? AppColors.error.withAlpha(77)
                  : AppColors.equations.withAlpha(77),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _hasError ? Icons.error_outline : Icons.check_circle_outline,
                    color: _hasError ? AppColors.error : AppColors.equations,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _hasError ? 'Error' : 'Solution',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _hasError ? AppColors.error : AppColors.equations,
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

class _EquationType {
  final String id;
  final String label;
  final String formula;
  final IconData icon;

  _EquationType(this.id, this.label, this.formula, this.icon);
}
