import 'package:dartcheck/rand.dart';
import 'package:dartcheck/random_state.dart';
import 'package:shuttlecock/shuttlecock.dart';
import 'package:test/test.dart';

import 'testing_functions.dart';

void main() {
  // Category laws tests adapted from Shuttlecock
  group('Category laws', () {
    // We are testing categorical laws only with the first generated value.
    final referenceRand = new Rand();

    group('applicative', () {
      test('pure identity', () {
        // ignore: omit_local_variable_types
        final RandomState<Function1<String, String>> pureIdentity =
            _returnMonad(identity);
        final monadInstance = _returnMonad(helloWorld);

        expect(monadInstance.app(pureIdentity).run(referenceRand),
            monadInstance.run(referenceRand));
      });

      test('pure f app pure x', () {
        final pureStringToLength = _returnMonad(stringToLength);
        final monadInstance = _returnMonad(helloWorld);

        expect(monadInstance.app(pureStringToLength).run(referenceRand),
            _returnMonad(stringToLength(helloWorld)).run(referenceRand));
      });

      test('interchange', () {
        final pureStringToLength = _returnMonad(stringToLength);
        final pureEval = _returnMonad(eval(helloWorld));
        final monadInstance = _returnMonad(helloWorld);

        expect(monadInstance.app(pureStringToLength).run(referenceRand),
            pureStringToLength.app(pureEval).run(referenceRand));
      });

      test('composition', () {
        final pureStringToLength = _returnMonad(stringToLength);
        final pureDecorate = _returnMonad(decorate);
        final pureComposition = _returnMonad(compose(decorate, stringToLength));
        final monadInstance = _returnMonad(helloWorld);

        expect(
            monadInstance
                .app(pureStringToLength)
                .app(pureDecorate)
                .run(referenceRand),
            monadInstance.app(pureComposition).run(referenceRand));
        expect(
            monadInstance
                .app(pureStringToLength
                    .app(_returnMonad(curry(compose, decorate))))
                .run(referenceRand),
            monadInstance
                .app(pureStringToLength)
                .app(pureDecorate)
                .run(referenceRand));
      });

      test('map apply', () {
        final pureStringToLength = _returnMonad(stringToLength);
        final monadInstance = _returnMonad(helloWorld);
        expect(monadInstance.app(pureStringToLength).run(referenceRand),
            monadInstance.map(stringToLength).run(referenceRand));
      });
    });

    test('map identity', () {
      final monadInstance = _returnMonad(helloWorld);
      final bound = monadInstance.map(identity);

      expect(bound.run(referenceRand), monadInstance.run(referenceRand));
    });

    test('map composition', () {
      final monadInstance = _returnMonad(helloWorld);
      final bound = monadInstance.map(stringToLength).map(decorate);
      final composedBound =
          monadInstance.map(compose(decorate, stringToLength));

      expect(bound.run(referenceRand), composedBound.run(referenceRand));
    });

    test('map flatMap composition', () {
      final monadInstance = _returnMonad(helloWorld);
      final flatMap =
          monadInstance.flatMap((s) => _returnMonad(stringToLength(s)));
      final map = monadInstance.map(stringToLength);

      expect(flatMap.run(referenceRand), map.run(referenceRand));
    });

    test('return flatMap f', () {
      final monadInstance = _returnMonad(helloWorld);
      final bound = monadInstance.flatMap(_f);

      expect(bound.run(referenceRand), _f(helloWorld).run(referenceRand));
    });

    test('m flatMap return', () {
      final monadInstance = _returnMonad(helloWorld);
      final bound = monadInstance.flatMap(_returnMonad);

      expect(bound.run(referenceRand), monadInstance.run(referenceRand));
    });

    test('composition', () {
      final monadInstance = _returnMonad(helloWorld);
      final bound = monadInstance.flatMap(_f).flatMap(_g);
      final composedBound = monadInstance.flatMap((s) => _f(s).flatMap(_g));

      expect(bound.run(referenceRand), composedBound.run(referenceRand));
    });
  });

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

RandomState<int> _f(s) => new RandomState.unit(stringToLength(s));

RandomState<String> _g(s) => new RandomState.unit(decorate(s));

RandomState<T> _returnMonad<T>(T value) => new RandomState.unit(value);
