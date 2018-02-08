import 'dart:async';

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
  Gen<U> app<U>(Gen<Function1<T, U>> app) => new Gen(sample.app(app.sample));

  @override
  Gen<U> flatMap<U>(Function1<T, Gen<U>> f) =>
      new Gen(sample.flatMap((t) => f(t).sample));

  @override
  Gen<U> map<U>(Function1<T, U> f) => new Gen(sample.map(f));

  /// Generates a stream of shrinked values given a target value.
  /// If no implementation is provided, the stream will be empty.
  StreamMonad<T> shrink(T t) => new StreamMonad.empty();

  /// Generates an infinite stream of vales given a generator and a random seed.
  StreamMonad<T> toStream(Rand r) => new StreamMonad.unfoldOf(
          sample.run(r), (p) => new Option(sample.run(p.second)))
      .map((p) => p.first);

  /// Returns a new generator for boolean values
  static Gen<bool> boolean() => new _GenBool();

  /// Returns a new generator for integer values greater or equal than a given
  /// start and less than a given end.
  static Gen<int> chooseInt(int start, int exclusiveEnd) =>
      new _GenIntInRange(start, exclusiveEnd);

  /// A static wrapper for unit constructor.
  static Gen<S> cnst<S>(S s) => new _GenConst(s);
}

class _GenBool extends Gen<bool> {
  /// Creates a new generator given a random state as a sample.
  _GenBool() : super(RandomState.boolean());

  @override
  StreamMonad<bool> toStream(Rand r) =>
      new StreamMonad(new Stream.fromIterable([true, false]));
}

/// Constant generator used as an optimization to avoid streams with several
/// events when only one event is needed.
class _GenConst<T> extends Gen<T> {
  final T _value;

  /// Creates a new generator given a random state as a sample.
  _GenConst(T value)
      : this._value = value,
        super(new RandomState.unit(value));

  @override
  StreamMonad<T> toStream(Rand r) => new StreamMonad.of(_value);
}

class _GenIntInRange extends Gen<int> {
  final int _start;
  _GenIntInRange(int start, int exclusiveEnd)
      : _start = start,
        super(RandomState.choseInt(start, exclusiveEnd));

  @override
  StreamMonad<int> shrink(int target) => target == _start
      ? new StreamMonad.empty()
      : new StreamMonad.of(_start).unfold((step) => _shrinkStep(target, step));

  Option<int> _shrinkStep(int target, int step) {
    final newStep = ((target + step) / 2).ceil();
    return newStep >= target ? new None() : new Some(newStep);
  }
}
