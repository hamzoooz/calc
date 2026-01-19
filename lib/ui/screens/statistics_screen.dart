import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modern_calculator/core/constants/app_colors.dart';
import 'package:modern_calculator/core/services/statistics_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _result = '';
  bool _hasError = false;

  // Data input controller
  final _dataController = TextEditingController(text: '1, 2, 3, 4, 5');
  final _data2Controller = TextEditingController(text: '2, 4, 6, 8, 10');
  final _weightsController = TextEditingController(text: '1, 1, 1, 1, 1');

  // Regression controllers
  final _xDataController = TextEditingController(text: '1, 2, 3, 4, 5');
  final _yDataController = TextEditingController(text: '2.1, 4.0, 5.9, 8.1, 9.8');
  int _polynomialDegree = 2;

  // Distribution controllers
  final _distXController = TextEditingController(text: '0');
  final _distMeanController = TextEditingController(text: '0');
  final _distStdDevController = TextEditingController(text: '1');
  final _distPController = TextEditingController(text: '0.5');
  final _distNController = TextEditingController(text: '10');
  final _distKController = TextEditingController(text: '5');
  final _distLambdaController = TextEditingController(text: '3');

  String _selectedCategory = 'basic';
  String _selectedOperation = 'summary';

  final List<_StatCategory> _categories = [
    _StatCategory('basic', 'Basic Stats', Icons.analytics_outlined),
    _StatCategory('dispersion', 'Dispersion', Icons.expand),
    _StatCategory('regression', 'Regression', Icons.trending_up),
    _StatCategory('distribution', 'Distributions', Icons.pie_chart),
  ];

  final Map<String, List<_StatOperation>> _operations = {
    'basic': [
      _StatOperation('summary', 'Full Summary', 'All basic statistics'),
      _StatOperation('mean', 'Mean', 'Arithmetic average'),
      _StatOperation('median', 'Median', 'Middle value'),
      _StatOperation('mode', 'Mode', 'Most frequent'),
      _StatOperation('geometric', 'Geometric Mean', 'Multiplicative average'),
      _StatOperation('harmonic', 'Harmonic Mean', 'Reciprocal average'),
      _StatOperation('weighted', 'Weighted Mean', 'Weighted average'),
      _StatOperation('sum', 'Sum', 'Total sum'),
      _StatOperation('product', 'Product', 'Total product'),
      _StatOperation('count', 'Count', 'Number of items'),
    ],
    'dispersion': [
      _StatOperation('variance', 'Variance', 'Sample variance'),
      _StatOperation('stddev', 'Std Deviation', 'Sample std dev'),
      _StatOperation('range', 'Range', 'Max - Min'),
      _StatOperation('iqr', 'IQR', 'Interquartile range'),
      _StatOperation('mad', 'MAD', 'Mean absolute deviation'),
      _StatOperation('cv', 'Coef. Variation', 'CV = σ/μ'),
      _StatOperation('sem', 'Std Error', 'Standard error of mean'),
      _StatOperation('quartiles', 'Quartiles', 'Q1, Q2, Q3'),
      _StatOperation('percentile', 'Percentile', 'Custom percentile'),
      _StatOperation('five_num', '5-Number Summary', 'Min, Q1, Med, Q3, Max'),
      _StatOperation('skewness', 'Skewness', 'Distribution asymmetry'),
      _StatOperation('kurtosis', 'Kurtosis', 'Tail heaviness'),
    ],
    'regression': [
      _StatOperation('linear', 'Linear Regression', 'y = ax + b'),
      _StatOperation('correlation', 'Correlation', 'Pearson r'),
      _StatOperation('covariance', 'Covariance', 'Joint variability'),
      _StatOperation('polynomial', 'Polynomial Fit', 'Higher order fit'),
      _StatOperation('exponential', 'Exponential Fit', 'y = ae^bx'),
      _StatOperation('power', 'Power Fit', 'y = ax^b'),
    ],
    'distribution': [
      _StatOperation('normal_pdf', 'Normal PDF', 'Probability density'),
      _StatOperation('normal_cdf', 'Normal CDF', 'Cumulative probability'),
      _StatOperation('normal_inv', 'Normal Inverse', 'Quantile function'),
      _StatOperation('z_score', 'Z-Score', 'Standard score'),
      _StatOperation('binomial', 'Binomial', 'P(X=k) for n trials'),
      _StatOperation('poisson', 'Poisson', 'P(X=k) for λ'),
    ],
  };

  final _percentileController = TextEditingController(text: '50');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedCategory = _categories[_tabController.index].id;
          _selectedOperation = _operations[_selectedCategory]!.first.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<double> _parseData(String text) {
    return text
        .split(RegExp(r'[,\s]+'))
        .where((s) => s.trim().isNotEmpty)
        .map((s) => double.tryParse(s.trim()) ?? 0)
        .toList();
  }

  void _calculate() {
    try {
      String resultStr = '';
      List<double> data = _parseData(_dataController.text);

      if (data.isEmpty) {
        throw Exception('Please enter data values');
      }

      switch (_selectedOperation) {
        // Basic Statistics
        case 'summary':
          resultStr = _getFullSummary(data);
          break;
        case 'mean':
          resultStr = 'Mean = ${_formatNum(StatisticsService.mean(data))}';
          break;
        case 'median':
          resultStr = 'Median = ${_formatNum(StatisticsService.median(data))}';
          break;
        case 'mode':
          List<double> modes = StatisticsService.mode(data);
          resultStr = modes.isEmpty
              ? 'No mode (all values unique)'
              : 'Mode = ${modes.map(_formatNum).join(', ')}';
          break;
        case 'geometric':
          resultStr = 'Geometric Mean = ${_formatNum(StatisticsService.geometricMean(data))}';
          break;
        case 'harmonic':
          resultStr = 'Harmonic Mean = ${_formatNum(StatisticsService.harmonicMean(data))}';
          break;
        case 'weighted':
          List<double> weights = _parseData(_weightsController.text);
          resultStr = 'Weighted Mean = ${_formatNum(StatisticsService.weightedMean(data, weights))}';
          break;
        case 'sum':
          resultStr = 'Sum = ${_formatNum(StatisticsService.sum(data))}';
          break;
        case 'product':
          resultStr = 'Product = ${_formatNum(StatisticsService.product(data))}';
          break;
        case 'count':
          resultStr = 'Count = ${data.length}';
          break;

        // Dispersion
        case 'variance':
          resultStr = 'Sample Variance = ${_formatNum(StatisticsService.varianceSample(data))}\n'
              'Population Variance = ${_formatNum(StatisticsService.variancePopulation(data))}';
          break;
        case 'stddev':
          resultStr = 'Sample Std Dev = ${_formatNum(StatisticsService.stdDevSample(data))}\n'
              'Population Std Dev = ${_formatNum(StatisticsService.stdDevPopulation(data))}';
          break;
        case 'range':
          resultStr = 'Range = ${_formatNum(StatisticsService.range(data))}\n'
              'Min = ${_formatNum(StatisticsService.min(data))}\n'
              'Max = ${_formatNum(StatisticsService.max(data))}';
          break;
        case 'iqr':
          resultStr = 'IQR = ${_formatNum(StatisticsService.interquartileRange(data))}';
          break;
        case 'mad':
          resultStr = 'Mean Absolute Deviation = ${_formatNum(StatisticsService.meanAbsoluteDeviation(data))}';
          break;
        case 'cv':
          resultStr = 'Coefficient of Variation = ${_formatNum(StatisticsService.coefficientOfVariation(data) * 100)}%';
          break;
        case 'sem':
          resultStr = 'Standard Error of Mean = ${_formatNum(StatisticsService.standardErrorMean(data))}';
          break;
        case 'quartiles':
          Map<String, double> q = StatisticsService.quartiles(data);
          resultStr = 'Q1 (25th percentile) = ${_formatNum(q['Q1']!)}\n'
              'Q2 (Median) = ${_formatNum(q['Q2']!)}\n'
              'Q3 (75th percentile) = ${_formatNum(q['Q3']!)}';
          break;
        case 'percentile':
          double p = double.tryParse(_percentileController.text) ?? 50;
          resultStr = '${p.toStringAsFixed(0)}th Percentile = ${_formatNum(StatisticsService.percentile(data, p))}';
          break;
        case 'five_num':
          Map<String, double> fns = StatisticsService.fiveNumberSummary(data);
          resultStr = 'Minimum = ${_formatNum(fns['min']!)}\n'
              'Q1 = ${_formatNum(fns['Q1']!)}\n'
              'Median = ${_formatNum(fns['median']!)}\n'
              'Q3 = ${_formatNum(fns['Q3']!)}\n'
              'Maximum = ${_formatNum(fns['max']!)}';
          break;
        case 'skewness':
          resultStr = 'Skewness = ${_formatNum(StatisticsService.skewness(data))}\n\n'
              '< 0: Left-skewed\n= 0: Symmetric\n> 0: Right-skewed';
          break;
        case 'kurtosis':
          resultStr = 'Kurtosis = ${_formatNum(StatisticsService.kurtosis(data))}\n\n'
              '< 0: Light tails (platykurtic)\n= 0: Normal (mesokurtic)\n> 0: Heavy tails (leptokurtic)';
          break;

        // Regression
        case 'linear':
          List<double> x = _parseData(_xDataController.text);
          List<double> y = _parseData(_yDataController.text);
          RegressionResult reg = StatisticsService.linearRegression(x, y);
          resultStr = 'Linear Regression:\n\n'
              '${reg.equation}\n\n'
              'R² = ${_formatNum(reg.rSquared)}\n'
              'r (correlation) = ${_formatNum(reg.correlationCoefficient)}\n\n'
              'Slope = ${_formatNum(reg.slope)}\n'
              'Intercept = ${_formatNum(reg.intercept)}';
          break;
        case 'correlation':
          List<double> x = _parseData(_xDataController.text);
          List<double> y = _parseData(_yDataController.text);
          double r = StatisticsService.correlation(x, y);
          resultStr = 'Pearson Correlation Coefficient\nr = ${_formatNum(r)}\n\n'
              'Interpretation:\n'
              '|r| < 0.3: Weak\n'
              '0.3 ≤ |r| < 0.7: Moderate\n'
              '|r| ≥ 0.7: Strong';
          break;
        case 'covariance':
          List<double> x = _parseData(_xDataController.text);
          List<double> y = _parseData(_yDataController.text);
          resultStr = 'Covariance = ${_formatNum(StatisticsService.covariance(x, y))}';
          break;
        case 'polynomial':
          List<double> x = _parseData(_xDataController.text);
          List<double> y = _parseData(_yDataController.text);
          List<double> coeffs = StatisticsService.polynomialRegression(x, y, _polynomialDegree);
          resultStr = 'Polynomial Regression (degree $_polynomialDegree):\n\n';
          List<String> terms = [];
          for (int i = coeffs.length - 1; i >= 0; i--) {
            if (i == 0) {
              terms.add(_formatNum(coeffs[i]));
            } else if (i == 1) {
              terms.add('${_formatNum(coeffs[i])}x');
            } else {
              terms.add('${_formatNum(coeffs[i])}x^$i');
            }
          }
          resultStr += 'y = ${terms.join(' + ')}';
          break;
        case 'exponential':
          List<double> x = _parseData(_xDataController.text);
          List<double> y = _parseData(_yDataController.text);
          Map<String, double> exp = StatisticsService.exponentialRegression(x, y);
          resultStr = 'Exponential Regression:\n\n'
              'y = ${_formatNum(exp['a']!)} × e^(${_formatNum(exp['b']!)}x)\n\n'
              'R² = ${_formatNum(exp['rSquared']!)}';
          break;
        case 'power':
          List<double> x = _parseData(_xDataController.text);
          List<double> y = _parseData(_yDataController.text);
          Map<String, double> pow = StatisticsService.powerRegression(x, y);
          resultStr = 'Power Regression:\n\n'
              'y = ${_formatNum(pow['a']!)} × x^${_formatNum(pow['b']!)}\n\n'
              'R² = ${_formatNum(pow['rSquared']!)}';
          break;

        // Distributions
        case 'normal_pdf':
          double x = double.tryParse(_distXController.text) ?? 0;
          double mean = double.tryParse(_distMeanController.text) ?? 0;
          double stdDev = double.tryParse(_distStdDevController.text) ?? 1;
          double pdf = StatisticsService.normalPDF(x, mean: mean, stdDev: stdDev);
          resultStr = 'Normal PDF\n\n'
              'f($x) = ${_formatNum(pdf)}\n\n'
              'μ = $mean, σ = $stdDev';
          break;
        case 'normal_cdf':
          double x = double.tryParse(_distXController.text) ?? 0;
          double mean = double.tryParse(_distMeanController.text) ?? 0;
          double stdDev = double.tryParse(_distStdDevController.text) ?? 1;
          double cdf = StatisticsService.normalCDF(x, mean: mean, stdDev: stdDev);
          resultStr = 'Normal CDF\n\n'
              'P(X ≤ $x) = ${_formatNum(cdf)}\n'
              '= ${(cdf * 100).toStringAsFixed(2)}%\n\n'
              'μ = $mean, σ = $stdDev';
          break;
        case 'normal_inv':
          double p = double.tryParse(_distPController.text) ?? 0.5;
          double mean = double.tryParse(_distMeanController.text) ?? 0;
          double stdDev = double.tryParse(_distStdDevController.text) ?? 1;
          double x = StatisticsService.normalInverseCDF(p, mean: mean, stdDev: stdDev);
          resultStr = 'Normal Inverse CDF (Quantile)\n\n'
              'x where P(X ≤ x) = $p\n'
              'x = ${_formatNum(x)}\n\n'
              'μ = $mean, σ = $stdDev';
          break;
        case 'z_score':
          double x = double.tryParse(_distXController.text) ?? 0;
          double mean = double.tryParse(_distMeanController.text) ?? 0;
          double stdDev = double.tryParse(_distStdDevController.text) ?? 1;
          double z = StatisticsService.zScore(x, mean, stdDev);
          resultStr = 'Z-Score\n\n'
              'z = (x - μ) / σ\n'
              'z = ($x - $mean) / $stdDev\n'
              'z = ${_formatNum(z)}';
          break;
        case 'binomial':
          int n = int.tryParse(_distNController.text) ?? 10;
          int k = int.tryParse(_distKController.text) ?? 5;
          double p = double.tryParse(_distPController.text) ?? 0.5;
          double prob = StatisticsService.binomialProbability(n, k, p);
          resultStr = 'Binomial Distribution\n\n'
              'P(X = $k) for n = $n, p = $p\n'
              '= ${_formatNum(prob)}\n'
              '= ${(prob * 100).toStringAsFixed(4)}%';
          break;
        case 'poisson':
          double lambda = double.tryParse(_distLambdaController.text) ?? 3;
          int k = int.tryParse(_distKController.text) ?? 3;
          double prob = StatisticsService.poissonProbability(lambda, k);
          resultStr = 'Poisson Distribution\n\n'
              'P(X = $k) for λ = $lambda\n'
              '= ${_formatNum(prob)}\n'
              '= ${(prob * 100).toStringAsFixed(4)}%';
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

  String _getFullSummary(List<double> data) {
    StringBuffer sb = StringBuffer();
    sb.writeln('Data Summary (n = ${data.length})');
    sb.writeln('${'─' * 30}');
    sb.writeln('Mean: ${_formatNum(StatisticsService.mean(data))}');
    sb.writeln('Median: ${_formatNum(StatisticsService.median(data))}');
    List<double> modes = StatisticsService.mode(data);
    sb.writeln('Mode: ${modes.isEmpty ? 'None' : modes.map(_formatNum).join(', ')}');
    sb.writeln('');
    sb.writeln('Sum: ${_formatNum(StatisticsService.sum(data))}');
    sb.writeln('Min: ${_formatNum(StatisticsService.min(data))}');
    sb.writeln('Max: ${_formatNum(StatisticsService.max(data))}');
    sb.writeln('Range: ${_formatNum(StatisticsService.range(data))}');
    sb.writeln('');
    sb.writeln('Variance: ${_formatNum(StatisticsService.varianceSample(data))}');
    sb.writeln('Std Dev: ${_formatNum(StatisticsService.stdDevSample(data))}');
    if (data.length >= 3) {
      sb.writeln('Skewness: ${_formatNum(StatisticsService.skewness(data))}');
    }
    if (data.length >= 4) {
      sb.writeln('Kurtosis: ${_formatNum(StatisticsService.kurtosis(data))}');
    }
    return sb.toString();
  }

  String _formatNum(double n) {
    if (n.isNaN || n.isInfinite) return n.toString();
    if (n == n.roundToDouble() && n.abs() < 1e10) return n.toInt().toString();
    if (n.abs() > 1e10 || (n.abs() < 1e-6 && n != 0)) {
      return n.toStringAsExponential(4);
    }
    return n.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _clearAll() {
    _dataController.text = '1, 2, 3, 4, 5';
    _data2Controller.text = '2, 4, 6, 8, 10';
    _weightsController.text = '1, 1, 1, 1, 1';
    _xDataController.text = '1, 2, 3, 4, 5';
    _yDataController.text = '2.1, 4.0, 5.9, 8.1, 9.8';
    _distXController.text = '0';
    _distMeanController.text = '0';
    _distStdDevController.text = '1';
    _distPController.text = '0.5';
    _distNController.text = '10';
    _distKController.text = '5';
    _distLambdaController.text = '3';
    _percentileController.text = '50';
    setState(() {
      _result = '';
      _hasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Category Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: AppColors.statisticsGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            padding: const EdgeInsets.all(4),
            tabs: _categories.map((cat) {
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon, size: 14),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(cat.label, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Operation Selector
                _buildOperationSelector(isDark),
                const SizedBox(height: 16),

                // Data Input
                _buildDataInput(isDark),
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
          ),
        ),
      ],
    );
  }

  Widget _buildOperationSelector(bool isDark) {
    List<_StatOperation> ops = _operations[_selectedCategory] ?? [];

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
            children: ops.map((op) {
              bool isSelected = _selectedOperation == op.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedOperation = op.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.statisticsGradient : null,
                    color: isSelected
                        ? null
                        : (isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(8)),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.statistics.withAlpha(77),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    op.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.textDark : AppColors.textLight),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataInput(bool isDark) {
    // Show different inputs based on category
    if (_selectedCategory == 'regression') {
      return _buildRegressionInput(isDark);
    } else if (_selectedCategory == 'distribution') {
      return _buildDistributionInput(isDark);
    } else if (_selectedOperation == 'weighted') {
      return _buildWeightedInput(isDark);
    } else if (_selectedOperation == 'percentile') {
      return _buildPercentileInput(isDark);
    }
    return _buildBasicDataInput(isDark);
  }

  Widget _buildBasicDataInput(bool isDark) {
    return _buildInputCard(isDark, 'Data Values', 'Enter comma-separated numbers', [
      _buildTextField(isDark, _dataController, 'e.g., 1, 2, 3, 4, 5'),
    ]);
  }

  Widget _buildWeightedInput(bool isDark) {
    return _buildInputCard(isDark, 'Weighted Mean', 'Enter data and weights', [
      _buildLabeledField(isDark, 'Values:', _dataController, 'e.g., 1, 2, 3, 4, 5'),
      const SizedBox(height: 8),
      _buildLabeledField(isDark, 'Weights:', _weightsController, 'e.g., 1, 2, 1, 2, 1'),
    ]);
  }

  Widget _buildPercentileInput(bool isDark) {
    return _buildInputCard(isDark, 'Percentile Calculation', 'Enter data and percentile', [
      _buildLabeledField(isDark, 'Values:', _dataController, 'e.g., 1, 2, 3, 4, 5'),
      const SizedBox(height: 8),
      Row(
        children: [
          Text('Percentile:', style: TextStyle(color: isDark ? AppColors.textDark : AppColors.textLight)),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _percentileController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? AppColors.textDark : AppColors.textLight),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? AppColors.inputBgDark : AppColors.inputBgLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                suffixText: '%',
              ),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildRegressionInput(bool isDark) {
    List<Widget> extra = [];
    if (_selectedOperation == 'polynomial') {
      extra.add(const SizedBox(height: 8));
      extra.add(Row(
        children: [
          Text('Degree:', style: TextStyle(color: isDark ? AppColors.textDark : AppColors.textLight)),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: _polynomialDegree,
            dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
            style: TextStyle(color: isDark ? AppColors.textDark : AppColors.textLight),
            items: [2, 3, 4, 5].map((d) => DropdownMenuItem(value: d, child: Text('$d'))).toList(),
            onChanged: (v) => setState(() => _polynomialDegree = v ?? 2),
          ),
        ],
      ));
    }

    return _buildInputCard(isDark, 'Regression Data', 'Enter X and Y values', [
      _buildLabeledField(isDark, 'X values:', _xDataController, 'e.g., 1, 2, 3, 4, 5'),
      const SizedBox(height: 8),
      _buildLabeledField(isDark, 'Y values:', _yDataController, 'e.g., 2.1, 4.0, 5.9, 8.1, 9.8'),
      ...extra,
    ]);
  }

  Widget _buildDistributionInput(bool isDark) {
    List<Widget> fields = [];

    if (['normal_pdf', 'normal_cdf', 'z_score'].contains(_selectedOperation)) {
      fields.addAll([
        _buildLabeledField(isDark, 'x:', _distXController, 'Value'),
        const SizedBox(height: 8),
        _buildLabeledField(isDark, 'μ (mean):', _distMeanController, '0'),
        const SizedBox(height: 8),
        _buildLabeledField(isDark, 'σ (std dev):', _distStdDevController, '1'),
      ]);
    } else if (_selectedOperation == 'normal_inv') {
      fields.addAll([
        _buildLabeledField(isDark, 'p (probability):', _distPController, '0 to 1'),
        const SizedBox(height: 8),
        _buildLabeledField(isDark, 'μ (mean):', _distMeanController, '0'),
        const SizedBox(height: 8),
        _buildLabeledField(isDark, 'σ (std dev):', _distStdDevController, '1'),
      ]);
    } else if (_selectedOperation == 'binomial') {
      fields.addAll([
        _buildLabeledField(isDark, 'n (trials):', _distNController, 'Number of trials'),
        const SizedBox(height: 8),
        _buildLabeledField(isDark, 'k (successes):', _distKController, 'Number of successes'),
        const SizedBox(height: 8),
        _buildLabeledField(isDark, 'p (probability):', _distPController, 'Success probability'),
      ]);
    } else if (_selectedOperation == 'poisson') {
      fields.addAll([
        _buildLabeledField(isDark, 'λ (lambda):', _distLambdaController, 'Expected rate'),
        const SizedBox(height: 8),
        _buildLabeledField(isDark, 'k (occurrences):', _distKController, 'Number of events'),
      ]);
    }

    return _buildInputCard(isDark, 'Distribution Parameters', 'Enter parameters', fields);
  }

  Widget _buildInputCard(bool isDark, String title, String subtitle, List<Widget> children) {
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
              color: AppColors.statistics,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(bool isDark, TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: 16,
        color: isDark ? AppColors.textDark : AppColors.textLight,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? AppColors.inputBgDark : AppColors.inputBgLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _buildLabeledField(
    bool isDark,
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? AppColors.inputBgDark : AppColors.inputBgLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
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
          gradient: isSecondary ? null : AppColors.statisticsGradient,
          color: isSecondary
              ? (isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(8))
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSecondary
              ? null
              : [
                  BoxShadow(
                    color: AppColors.statistics.withAlpha(77),
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
                    : AppColors.statistics.withAlpha(26))
                : (_hasError
                    ? AppColors.error.withAlpha(26)
                    : AppColors.statistics.withAlpha(26)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hasError
                  ? AppColors.error.withAlpha(77)
                  : AppColors.statistics.withAlpha(77),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _hasError ? Icons.error_outline : Icons.check_circle_outline,
                    color: _hasError ? AppColors.error : AppColors.statistics,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _hasError ? 'Error' : 'Result',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _hasError ? AppColors.error : AppColors.statistics,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SelectableText(
                _result,
                style: TextStyle(
                  fontSize: 14,
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

class _StatCategory {
  final String id;
  final String label;
  final IconData icon;

  _StatCategory(this.id, this.label, this.icon);
}

class _StatOperation {
  final String id;
  final String label;
  final String description;

  _StatOperation(this.id, this.label, this.description);
}
