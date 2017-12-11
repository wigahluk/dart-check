import 'package:dartcheck/rand.dart';
import 'package:dartcheck/random_state.dart';
import 'package:test/test.dart';

void main() {
  group('Random State', () {
    test('unit wraps a value', () {
      final value = 'hello monad';
      final seed = new Rand();
      final one = new RandomState.unit(value);
      expect(one.run(seed).first, value);
    });

    test('map identity', () {
      final seed = new Rand();
      final one = new RandomState.unit('hello monad');
      final two = one.map((a) => a);
      expect(one.run(seed).first, two.run(seed).first);
    });

    test('unit is flatMap identity', () {
      final seed = new Rand();
      final one = new RandomState.unit('hello monad');
      final two = one.flatMap((a) => new RandomState.unit(a));
      expect(one.run(seed).first, two.run(seed).first);
    });
  });
}