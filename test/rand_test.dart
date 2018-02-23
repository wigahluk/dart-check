import 'package:dartcheck/rand.dart';
import 'package:test/test.dart';

void main() {
  group('Rand', () {
    test('two instances with same seed should produce the same values', () {
      final r1 = new Rand().next().value().item1;
      final r2 = new Rand().next().value().item1;
      expect(r1, r2);
    });

    test('two instances with same seed should produce the same doubles', () {
      final r1 = new Rand().next().doubleValue().item1;
      final r2 = new Rand().next().doubleValue().item1;
      expect(r1, r2);
    });

    test('two instances with same seed should produce the same booleans', () {
      final r1 = new Rand().next().boolValue().item1;
      final r2 = new Rand().next().boolValue().item1;
      expect(r1, r2);
    });

    test('two consecutive instances should have different values', () {
      final r = new Rand().next();
      final r1 = r.value().item1;
      final r2 = r.next().value().item1;
      expect(r1, isNot(r2));
    });

    test('two consecutive instances should have different doubles', () {
      final r = new Rand().next();
      final r1 = r.doubleValue().item1;
      final r2 = r.next().doubleValue().item1;
      expect(r1, isNot(r2));
    });

    test('two consecutive instances should have different booleans', () {
      final r = new Rand().next();
      final r1 = r.boolValue().item1;
      final r2 = r.next().boolValue().item1;
      expect(r1, isNot(r2));
    });
  });
}
