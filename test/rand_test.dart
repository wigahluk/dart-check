import 'package:dartcheck/rand.dart';
import 'package:test/test.dart';

void main() {
  group('Rand', () {
    test('two instances with same seed should produce the same values', () {
      final r1 = new Rand().next().value().first;
      final r2 = new Rand().next().value().first;
      expect(r1, r2);
    });

    test('two instances with same seed should produce the same doubles', () {
      final r1 = new Rand().next().doubleValue().first;
      final r2 = new Rand().next().doubleValue().first;
      expect(r1, r2);
    });

    test('two instances with same seed should produce the same booleans', () {
      final r1 = new Rand().next().boolValue().first;
      final r2 = new Rand().next().boolValue().first;
      expect(r1, r2);
    });

    test('two consecutive instances should have different values', () {
      final r = new Rand().next();
      final r1 = r.value().first;
      final r2 = r.next().value().first;
      expect(r1, isNot(r2));
    });

    test('two consecutive instances should have different doubles', () {
      final r = new Rand().next();
      final r1 = r.doubleValue().first;
      final r2 = r.next().doubleValue().first;
      expect(r1, isNot(r2));
    });

    test('two consecutive instances should have different booleans', () {
      final r = new Rand().next();
      final r1 = r.boolValue().first;
      final r2 = r.next().boolValue().first;
      expect(r1, isNot(r2));
    });
  });
}