import 'package:dartcheck/gen.dart';
import 'package:dartcheck/pair.dart';
import 'package:dartcheck/rand.dart';
import 'package:shuttlecock/shuttlecock.dart';
import 'package:test/test.dart';

import 'testing_functions.dart';

void main() {
  group('Gen', () {
    // Category laws tests adapted from Shuttlecock
    group('Category laws', () {
      // We are testing categorical laws only with the first generated value.
      final referenceRand = new Rand();

      // Runs a generator on the first generated value of the referenceRand.
      Pair<T, Rand> runGen<T>(Gen<T> gen) => gen.sample.run(referenceRand);

      group('applicative', () {
        test('pure identity', () {
          // ignore: omit_local_variable_types
          final Gen<Function1<String, String>> pureIdentity =
              _returnMonad(identity);
          final monadInstance = _returnMonad(helloWorld);

          expect(
              runGen(monadInstance.app(pureIdentity)), runGen(monadInstance));
        });

        test('pure f app pure x', () {
          final pureStringToLength = _returnMonad(stringToLength);
          final monadInstance = _returnMonad(helloWorld);

          expect(runGen(monadInstance.app(pureStringToLength)),
              runGen(_returnMonad(stringToLength(helloWorld))));
        });

        test('interchange', () {
          final pureStringToLength = _returnMonad(stringToLength);
          final pureEval = _returnMonad(eval(helloWorld));
          final monadInstance = _returnMonad(helloWorld);

          expect(runGen(monadInstance.app(pureStringToLength)),
              runGen(pureStringToLength.app(pureEval)));
        });

        test('composition', () {
          final pureStringToLength = _returnMonad(stringToLength);
          final pureDecorate = _returnMonad(decorate);
          final pureComposition =
              _returnMonad(compose(decorate, stringToLength));
          final monadInstance = _returnMonad(helloWorld);

          expect(
              runGen(monadInstance.app(pureStringToLength).app(pureDecorate)),
              runGen(monadInstance.app(pureComposition)));
          expect(
              runGen(monadInstance.app(pureStringToLength
                  .app(_returnMonad(curry(compose, decorate))))),
              runGen(monadInstance.app(pureStringToLength).app(pureDecorate)));
        });

        test('map apply', () {
          final pureStringToLength = _returnMonad(stringToLength);
          final monadInstance = _returnMonad(helloWorld);
          expect(runGen(monadInstance.app(pureStringToLength)),
              runGen(monadInstance.map(stringToLength)));
        });
      });

      test('map identity', () {
        final monadInstance = _returnMonad(helloWorld);
        final bound = monadInstance.map(identity);

        expect(runGen(bound), runGen(monadInstance));
      });

      test('map composition', () {
        final monadInstance = _returnMonad(helloWorld);
        final bound = monadInstance.map(stringToLength).map(decorate);
        final composedBound =
            monadInstance.map(compose(decorate, stringToLength));

        expect(runGen(bound), runGen(composedBound));
      });

      test('map flatMap composition', () {
        final monadInstance = _returnMonad(helloWorld);
        final flatMap =
            monadInstance.flatMap((s) => _returnMonad(stringToLength(s)));
        final map = monadInstance.map(stringToLength);

        expect(runGen(flatMap), runGen(map));
      });

      test('return flatMap f', () {
        final monadInstance = _returnMonad(helloWorld);
        final bound = monadInstance.flatMap(_f);

        expect(runGen(bound), runGen(_f(helloWorld)));
      });

      test('m flatMap return', () {
        final monadInstance = _returnMonad(helloWorld);
        final bound = monadInstance.flatMap(_returnMonad);

        expect(runGen(bound), runGen(monadInstance));
      });

      test('composition', () {
        final monadInstance = _returnMonad(helloWorld);
        final bound = monadInstance.flatMap(_f).flatMap(_g);
        final composedBound = monadInstance.flatMap((s) => _f(s).flatMap(_g));

        expect(runGen(bound), runGen(composedBound));
      });
    });

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

Gen<int> _f(s) => new Gen.unit(stringToLength(s));

Gen<String> _g(s) => new Gen.unit(decorate(s));

Gen<T> _returnMonad<T>(T value) => new Gen.unit(value);
