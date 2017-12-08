import 'package:dartcheck/rand.dart';
import 'package:test/test.dart';

void main() {
  group('Rand', () {
    test('two instances with the same seed should produce the same numbers', () {
      final r1 = new Rand().next().value().first;
      final r2 = new Rand().next().value().first;
      expect(r1, r2);
    });
  });
}