import 'package:dartcheck/gen.dart';
import 'package:dartcheck/rand.dart';
import 'package:test/test.dart';

void main() {
  group('Gen', () {
    group('Random Stream', () {
      test('two streams with same seed should emit same results', () async {
        final seed = new Rand();
        final g = Gen.chooseInt(10, 1000);
        final s1 = await g.toStream(seed).take(100).toList();
        final s2 = await g.toStream(seed).take(100).toList();
        expect(s1, s2);
      });

      test('two streams with different seed should emit different results',
          () async {
        final seed1 = new Rand();
        final seed2 = seed1.next();
        final g = Gen.chooseInt(10, 1000);
        final s1 = await g.toStream(seed1).take(100).toList();
        final s2 = await g.toStream(seed2).take(100).toList();
        expect(s1, isNot(s2));
      });
    });

    test('unit wraps a value', () {
      final value = 'hello monad';
      final seed = new Rand();
      final one = new Gen.unit(value);
      expect(one.sample.run(seed).first, value);
    });

    test('cnst is the same as unit', () {
      final value = 'hello monad';
      final seed = new Rand();
      final one = Gen.cnst(value);
      expect(one.sample.run(seed).first, value);
    });

    test('boolean generates booleans', () {
      final seed1 = new Rand();
      final seed2 = seed1.next();
      final g = Gen.boolean();
      // We are lucky and the first two seeds generate two different booleans :)
      expect(g.sample.run(seed1).first, true);
      expect(g.sample.run(seed2).first, false);
    });

    /// This test is actually only testing the first value of the generator and
    /// is only used for testing basic behavior. Real tests should use Props
    /// with multiple generators.
    test('chooseInt generates integers in range', () {
      final seed1 = new Rand();
      final g = Gen.chooseInt(10, 1000);
      expect(g.sample.run(seed1).first, greaterThan(9));
      expect(g.sample.run(seed1).first, lessThan(1000));
    });
  });
}
