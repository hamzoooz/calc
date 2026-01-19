import 'package:flutter_test/flutter_test.dart';
import 'package:modern_calculator/core/services/calculation_engine.dart';

void main() {
  late CalculationEngine engine;

  setUp(() {
    engine = CalculationEngine(useRadians: false);
  });

  group('Basic Operations', () {
    test('addition', () {
      expect(engine.calculate('2+3'), equals('5'));
      expect(engine.calculate('10+20'), equals('30'));
      expect(engine.calculate('0+0'), equals('0'));
      expect(engine.calculate('-5+3'), equals('-2'));
    });

    test('subtraction', () {
      expect(engine.calculate('5-3'), equals('2'));
      expect(engine.calculate('3-5'), equals('-2'));
      expect(engine.calculate('10-0'), equals('10'));
    });

    test('multiplication', () {
      expect(engine.calculate('3×4'), equals('12'));
      expect(engine.calculate('3*4'), equals('12'));
      expect(engine.calculate('5×0'), equals('0'));
      expect(engine.calculate('-3×4'), equals('-12'));
    });

    test('division', () {
      expect(engine.calculate('12÷4'), equals('3'));
      expect(engine.calculate('12/4'), equals('3'));
      expect(engine.calculate('10÷4'), equals('2.5'));
    });

    test('division by zero returns error', () {
      expect(engine.calculate('5÷0'), equals('Error'));
      expect(engine.calculate('5/0'), equals('Error'));
    });
  });

  group('Order of Operations (BODMAS)', () {
    test('multiplication before addition', () {
      expect(engine.calculate('2+3×4'), equals('14'));
      expect(engine.calculate('2×3+4'), equals('10'));
    });

    test('division before subtraction', () {
      expect(engine.calculate('10-6÷2'), equals('7'));
      expect(engine.calculate('12÷4-1'), equals('2'));
    });

    test('complex expressions', () {
      expect(engine.calculate('2+3×4-5'), equals('9'));
      expect(engine.calculate('10÷2+3×4'), equals('17'));
    });
  });

  group('Brackets', () {
    test('brackets override precedence', () {
      expect(engine.calculate('(2+3)×4'), equals('20'));
      expect(engine.calculate('2×(3+4)'), equals('14'));
    });

    test('nested brackets', () {
      expect(engine.calculate('((2+3)×4)'), equals('20'));
      expect(engine.calculate('2×((3+4)×2)'), equals('28'));
    });

    test('multiple bracket groups', () {
      expect(engine.calculate('(2+3)×(4+5)'), equals('45'));
    });
  });

  group('Percentage', () {
    test('simple percentage', () {
      expect(engine.calculate('50%'), equals('0.5'));
      expect(engine.calculate('100%'), equals('1'));
      expect(engine.calculate('25%'), equals('0.25'));
    });

    test('percentage in expression', () {
      expect(engine.calculate('100×50%'), equals('50'));
      expect(engine.calculate('200×25%'), equals('50'));
    });
  });

  group('Power Operations', () {
    test('basic powers', () {
      expect(engine.calculate('2^3'), equals('8'));
      expect(engine.calculate('3^2'), equals('9'));
      expect(engine.calculate('10^0'), equals('1'));
    });

    test('negative base', () {
      expect(engine.calculate('(-2)^2'), equals('4'));
      expect(engine.calculate('(-2)^3'), equals('-8'));
    });

    test('power precedence', () {
      expect(engine.calculate('2×3^2'), equals('18'));
      expect(engine.calculate('2^3×2'), equals('16'));
    });
  });

  group('Scientific Functions (Degrees Mode)', () {
    test('sine function', () {
      engine.useRadians = false;
      expect(double.parse(engine.calculate('sin(0)')), closeTo(0, 0.0001));
      expect(double.parse(engine.calculate('sin(90)')), closeTo(1, 0.0001));
      expect(double.parse(engine.calculate('sin(30)')), closeTo(0.5, 0.0001));
    });

    test('cosine function', () {
      engine.useRadians = false;
      expect(double.parse(engine.calculate('cos(0)')), closeTo(1, 0.0001));
      expect(double.parse(engine.calculate('cos(90)')), closeTo(0, 0.0001));
      expect(double.parse(engine.calculate('cos(60)')), closeTo(0.5, 0.0001));
    });

    test('tangent function', () {
      engine.useRadians = false;
      expect(double.parse(engine.calculate('tan(0)')), closeTo(0, 0.0001));
      expect(double.parse(engine.calculate('tan(45)')), closeTo(1, 0.0001));
    });
  });

  group('Scientific Functions (Radians Mode)', () {
    test('sine function in radians', () {
      engine.useRadians = true;
      expect(double.parse(engine.calculate('sin(0)')), closeTo(0, 0.0001));
      expect(double.parse(engine.calculate('sin(1.5707963267949)')),
          closeTo(1, 0.0001)); // sin(π/2)
    });

    test('cosine function in radians', () {
      engine.useRadians = true;
      expect(double.parse(engine.calculate('cos(0)')), closeTo(1, 0.0001));
      expect(double.parse(engine.calculate('cos(3.14159265359)')),
          closeTo(-1, 0.0001)); // cos(π)
    });
  });

  group('Logarithmic Functions', () {
    test('natural logarithm', () {
      expect(double.parse(engine.calculate('ln(1)')), closeTo(0, 0.0001));
      expect(double.parse(engine.calculate('ln(2.71828182846)')),
          closeTo(1, 0.0001));
    });

    test('common logarithm (base 10)', () {
      expect(double.parse(engine.calculate('log(1)')), closeTo(0, 0.0001));
      expect(double.parse(engine.calculate('log(10)')), closeTo(1, 0.0001));
      expect(double.parse(engine.calculate('log(100)')), closeTo(2, 0.0001));
    });
  });

  group('Square Root', () {
    test('basic square root', () {
      expect(engine.calculate('sqrt(4)'), equals('2'));
      expect(engine.calculate('sqrt(9)'), equals('3'));
      expect(engine.calculate('sqrt(16)'), equals('4'));
      expect(engine.calculate('sqrt(2)'), equals('1.414213562'));
    });

    test('square root symbol', () {
      expect(engine.calculate('√4'), equals('2'));
      expect(engine.calculate('√9'), equals('3'));
    });

    test('negative square root returns error', () {
      expect(engine.calculate('sqrt(-4)'), equals('Error'));
    });
  });

  group('Factorial', () {
    test('basic factorial', () {
      expect(engine.calculate('0!'), equals('1'));
      expect(engine.calculate('1!'), equals('1'));
      expect(engine.calculate('5!'), equals('120'));
      expect(engine.calculate('10!'), equals('3628800'));
    });

    test('factorial in expression', () {
      expect(engine.calculate('3!+2'), equals('8'));
      expect(engine.calculate('2×3!'), equals('12'));
    });
  });

  group('Constants', () {
    test('pi constant', () {
      expect(double.parse(engine.calculate('π')), closeTo(3.14159265359, 0.0001));
      expect(double.parse(engine.calculate('2×π')), closeTo(6.28318530718, 0.0001));
    });

    test('euler constant', () {
      expect(double.parse(engine.calculate('e')), closeTo(2.71828182846, 0.0001));
    });
  });

  group('Implicit Multiplication', () {
    test('number before bracket', () {
      expect(engine.calculate('2(3)'), equals('6'));
      expect(engine.calculate('3(2+1)'), equals('9'));
    });

    test('bracket after bracket', () {
      expect(engine.calculate('(2)(3)'), equals('6'));
      expect(engine.calculate('(2+1)(3+1)'), equals('12'));
    });
  });

  group('Negative Numbers', () {
    test('negative at start', () {
      expect(engine.calculate('-5+3'), equals('-2'));
      expect(engine.calculate('-5×2'), equals('-10'));
    });

    test('negative in brackets', () {
      expect(engine.calculate('(-5)+3'), equals('-2'));
      expect(engine.calculate('2×(-3)'), equals('-6'));
    });
  });

  group('Decimal Numbers', () {
    test('basic decimals', () {
      expect(engine.calculate('1.5+2.5'), equals('4'));
      expect(engine.calculate('3.14×2'), equals('6.28'));
    });

    test('decimal precision', () {
      expect(engine.calculate('1÷3'), equals('0.3333333333'));
    });
  });

  group('Edge Cases', () {
    test('empty expression', () {
      expect(engine.calculate(''), equals('Error'));
    });

    test('single number', () {
      expect(engine.calculate('42'), equals('42'));
      expect(engine.calculate('3.14'), equals('3.14'));
    });

    test('very large numbers', () {
      expect(engine.calculate('999999999+1'), equals('1000000000'));
    });

    test('very small numbers', () {
      expect(engine.calculate('0.000001×0.000001'), isNot(equals('Error')));
    });
  });

  group('Bracket Validation', () {
    test('validates balanced brackets', () {
      expect(engine.validateBrackets('(2+3)×4'), isTrue);
      expect(engine.validateBrackets('((2+3))'), isTrue);
      expect(engine.validateBrackets('(2+3)×(4+5)'), isTrue);
    });

    test('detects unbalanced brackets', () {
      expect(engine.validateBrackets('(2+3'), isFalse);
      expect(engine.validateBrackets('2+3)'), isFalse);
      expect(engine.validateBrackets('((2+3)'), isFalse);
    });
  });

  group('Preview Function', () {
    test('returns result for valid expression', () {
      expect(engine.preview('2+3'), equals('5'));
      expect(engine.preview('10×5'), equals('50'));
    });

    test('returns empty string for incomplete expression', () {
      expect(engine.preview(''), equals('0'));
    });
  });
}
