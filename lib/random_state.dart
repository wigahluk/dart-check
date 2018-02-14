import 'package:dartcheck/pair.dart';
import 'package:dartcheck/rand.dart';
import 'package:shuttlecock/shuttlecock.dart';

///
typedef Pair<T, Rand> RunState<T>(Rand rand);

/// Represents a random execution context
///
/// It is similar to the State monad but keeping a
/// random seed under the context.
class RandomState<T> extends Monad<T> {
  /// State is captured in function scope
  final RunState<T> run;

  /// Creates a new instance of state given a function that can build a pair
  /// with the Rand seed and a carrier of changes
  RandomState(this.run);

  /// Monadic unit
  factory RandomState.unit(T t) => new RandomState((r) => new Pair(t, r));

  @override
  RandomState<U> app<U>(RandomState<Function1<T, U>> app) =>
      new RandomState((ran) {
        final pState = run(ran);
        return app.run(pState.second).mapFirst((f) => f(pState.first));
      });

  @override
  RandomState<U> flatMap<U>(Function1<T, RandomState<U>> f) =>
      new RandomState((ran) {
        final p = run(ran);
        return f(p.first).run(p.second);
      });

  @override
  RandomState<U> map<U>(Function1<T, U> f) =>
      flatMap((t) => new RandomState.unit(f(t)));

  /// Returns a new RandomState for boolean values.
  static RandomState<bool> boolean() =>
      new RandomState((ran) => ran.boolValue());

  /// Returns a new RandomState for non negative doubles between zero and 1.
  static RandomState<double> choseDouble(
          [double min = 0.0, double max = 1.0]) =>
      new RandomState((ran) {
        final delta = max - min;
        final p = ran.doubleValue();
        return new Pair(p.first * delta + min, p.second);
      });

  /// Returns a new RandomState for non integers in a range.
  static RandomState<int> choseInt(int min, int max) =>
      new RandomState((ran) => ran.chooseInt(min, max));

  /// Returns a new RandomState for non negative integers.
  ///
  /// This implementation relies on the fact that Random.nextInt
  /// on the Dart SDK returns non negative values.
  static RandomState<int> nonNegativeInt() =>
      new RandomState((ran) => ran.value());
}
