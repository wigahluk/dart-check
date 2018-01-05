import 'package:dartcheck/gen.dart';
import 'package:dartcheck/prop.dart';
import 'package:test/test.dart';

void main() {
  group('For all', () {
    forAll(Gen.boolean()).test('booleans behave as booleans', (b) {
      expect(true && b, b);
      expect(false || b, b);
    });

    forAll(Gen.chooseInt(10, 100)).test('Integers in range are in range', (n) {
      expect(n, lessThan(101));
      expect(n, greaterThan(9));
    });
  });

  group('Constant', () {
    var count = 0;
    forAll(Gen.cnst('Hello')).test('runs only once', (s) {
      count++;
      expect(count, 1);
    });

    forAll(Gen.cnst('Hello')).test('when a constant is always the same', (s) {
      expect(s, 'Hello');
    });
  });
}
