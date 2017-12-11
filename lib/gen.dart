import 'package:dartcheck/rand.dart';
import 'package:dartcheck/random_state.dart';
import 'package:shuttlecock/shuttlecock.dart';

/// A monadic wrapper for a random state used to generate random values.
class Gen<T> extends Monad<T> {

  /// A random representation of the internal state.
  final RandomState<T> sample;

  /// Creates a new generator given a random state as a sample.
  Gen(this.sample);

  /// Monadic unit.
  factory Gen.unit(T t) => new Gen(new RandomState.unit(t));

  @override
  Gen<U> app<U>(Gen<Function1<T, U>> app) =>
      new Gen(sample.app(app.sample));

  @override
  Gen<U> flatMap<U>(Function1<T, Gen<U>> f) =>
      new Gen(sample.flatMap((t) => f(t).sample));

  @override
  Gen<U> map<U>(Function1<T, U> f) =>
      new Gen(sample.map(f));

  /// Generates an infinite stream of vales given a generator and a random seed.
  StreamMonad<T> toStream(Rand r) =>
      new StreamMonad
          .unfoldOf(sample.run(r), (p) => new Option(sample.run(p.second)))
          .map((p) => p.first);

  /// A static wrapper for unit constructor.
  static Gen<S> cnst<S>(S s) => new GenConst.unit(s);

  /// Returns a new generator for boolean values
  static Gen<bool> boolean() => new Gen(RandomState.boolean());

  /// Returns a new generator for integer values greater than a given start
  /// and less than a given end.
  static Gen<int> chooseInt(int start, int exclusiveEnd) =>
      new Gen(
          RandomState
              .nonNegativeInt()
              .map((n) => start + (n % (exclusiveEnd - start)))
      );
}

/// Constant generator used as an optimization to avoid streams with several
/// events when only one event is needed.
class GenConst<T> extends Gen<T> {

  /// Creates a new generator given a random state as a sample.
  GenConst(sample) : super(sample);

  /// Monadic unit.
  factory GenConst.unit(T t) => new GenConst(new RandomState.unit(t));

  @override
  StreamMonad<T> toStream(Rand r) =>
      new StreamMonad.of(sample.run(r).first);
}