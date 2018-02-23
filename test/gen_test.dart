import 'package:dartcheck/gen.dart';
import 'package:tuple/tuple.dart';
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
      Tuple2<T, Rand> runGen<T>(Gen<T> gen) => gen.sample.run(referenceRand);

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

    group('Srinkers', () {
      test('Boolean shrinking', () async {
        final g = Gen.boolean();
        final s1 = await g.shrink(true).toList();
        final s2 = await g.shrink(false).toList();
        expect(s1.length, 0);
        expect(s2.length, 0);
      });

      test('Constant shrinking', () async {
        final g = Gen.cnst(10);
        final s = await g.shrink(15).toList();
        expect(s.length, 0);
      });

      test('Int in range shrinking', () async {
        final g = Gen.chooseInt(10, 100);
        final s = await g.shrink(15).toList()
          ..forEach((item) {
            expect(item, inInclusiveRange(10, 14));
          });
        expect(s, [10, 13, 14]);
        expect(s.length, 3);
      });
    });

    group('Basic Generators', () {
      test('unit wraps a value', () {
        final value = 'hello monad';
        final seed = new Rand();
        final one = new Gen.unit(value);
        expect(one.sample.run(seed).item1, value);
      });

      test('cnst is the same as unit', () {
        final value = 'hello monad';
        final seed = new Rand();
        final one = Gen.cnst(value);
        expect(one.sample.run(seed).item1, value);
      });

      test('boolean generates booleans', () {
        final seed1 = new Rand();
        final seed2 = seed1.next();
        final g = Gen.boolean();
        // We are lucky and the first two seeds generate two different booleans :)
        expect(g.sample.run(seed1).item1, true);
        expect(g.sample.run(seed2).item1, false);
      });

      test('chooseInt generates integers in range', () async {
        final seed = new Rand();
        final values =
            await Gen.chooseInt(10, 1000).toStream(seed).take(100).toList();
        for (var v in values) {
          expect(v, greaterThan(9));
          expect(v, lessThan(1000));
        }
      });

      test('chooseDouble generates dpubles in range', () async {
        final seed = new Rand();
        final values = await Gen
            .chooseDouble(10.0, 1000.0)
            .toStream(seed)
            .take(100)
            .toList();
        for (var v in values) {
          expect(v, greaterThan(9));
          expect(v, lessThan(1000));
        }
      });

      test('sequence of two generators is a generator of a pair', () async {
        final seed = new Rand();
        final gen1 = Gen.chooseInt(1, 101);
        final gen2 = Gen.chooseInt(101, 200);
        final values =
            await Gen.sequence([gen1, gen2]).toStream(seed).take(100).toList();
        for (var v in values) {
          expect(v[0], greaterThan(0));
          expect(v[0], lessThan(101));
          expect(v[1], greaterThan(100));
          expect(v[1], lessThan(201));
          expect(v.length, 2);
        }
      });

      test('Sequence of T with listOfN', () async {
        final seed = new Rand();
        final gen = Gen.chooseInt(1, 101);
        final values =
            await Gen.listOfN(gen, 10).toStream(seed).take(100).toList();
        for (var v in values) {
          expect(v.length, lessThan(11));
          for (var c in v) {
            expect(c, lessThan(101));
            expect(c, greaterThan(0));
          }
        }
      });
    });

    group('Character Generators', () {
      test('charNum generates one numeric char', () async {
        final seed = new Rand();
        final values = await Gen.numChar().toStream(seed).take(100).toList();
        for (var v in values) {
          expect(v, matches('[0-9]'));
          expect(v.length, 1);
        }
      });

      test('alphaUpperChar generates one upper case alpha char', () async {
        final seed = new Rand();
        final values =
            await Gen.alphaUpperChar().toStream(seed).take(100).toList();
        for (var v in values) {
          expect(v, matches('[A-Z]'));
          expect(v.length, 1);
        }
      });

      test('alphaLowerChar generates one lower case alpha char', () async {
        final seed = new Rand();
        final values =
            await Gen.alphaLowerChar().toStream(seed).take(100).toList();
        for (var v in values) {
          expect(v, matches('[a-z]'));
          expect(v.length, 1);
        }
      });
    });

    group('String Generators', () {
      test('Numeric string', () async {
        final seed = new Rand();
        final values = await Gen.numStr().toStream(seed).take(100).toList();
        for (var v in values) {
          expect(v, matches('^[0-9]*\$'));
        }
      });

      test('Alpha upper string', () async {
        final seed = new Rand();
        final values =
            await Gen.alphaUpperStr().toStream(seed).take(100).toList();
        for (var v in values) {
          expect(v, matches('^[A-Z]*\$'));
        }
      });

      test('Alpha lower string', () async {
        final seed = new Rand();
        final values =
            await Gen.alphaLowerStr().toStream(seed).take(100).toList();
        for (var v in values) {
          expect(v, matches('^[a-z]*\$'));
        }
      });
    });
  });
}

Gen<int> _f(s) => new Gen.unit(stringToLength(s));

Gen<String> _g(s) => new Gen.unit(decorate(s));

Gen<T> _returnMonad<T>(T value) => new Gen.unit(value);
