import 'dart:async';

import 'package:dartcheck/gen.dart';
import 'package:dartcheck/rand.dart';
import 'package:shuttlecock/shuttlecock.dart';
import 'package:test/test.dart' as dart_test;
import 'package:tuple/tuple.dart';

/// Returns a new Prop that can be used to run tests for a generator
Prop forAll<T>(Gen<T> gen) => new Prop(gen);

/// Type alias for test bodies.
typedef void TestBody<T>(T s);

/// Property representation to be verified
class Prop<T> {
  final Gen<T> _gen;

  /// Builds a new Prop given a generator that will be used internally to
  /// produce new random reproducible values.
  Prop(Gen<T> gen) : _gen = gen;

  /// Used similar to the regular dart.test `test` function but receiving a
  /// function that takes arguments, namely, the ones produced randomly by this
  /// Property.
  void test(String name, TestBody testBody) {
    var count = 0;
    final shrinker = new _TestShrinker(testBody, _gen);
    // We need to run everything within the Dart test closure as it keeps track
    // of global state variables and can fail if asserts are executed without
    // the proper values.
    dart_test.test(name, () async {
      // TODO: The number of generated cases should be configurable
      final tryOrFailure = await _stream().take(100).map((genValue) {
        count++;
        return _tryOrFailure(testBody, genValue);
      }).firstWhere((o) => o.isNotEmpty, defaultValue: () => new None());

      await _failDartTest(shrinker, tryOrFailure, count);
    });
  }

  StreamMonad<T> _stream() => _gen.toStream(new Rand());

  Option<_TestFailure<T>> _tryOrFailure(TestBody testBody, T t) {
    try {
      testBody(t);
      return new None();
    } on dart_test.TestFailure catch (e) {
      return new Some(new _TestFailure(t, e));
    }
  }

  static Future<Null> _failDartTest(_TestShrinker shrinker,
      Option<_TestFailure> failure, int attemptCount) async {
    if (failure.isNotEmpty) {
      final newFailure = await shrinker.improve(failure.first, 10);

      // ignore: only_throw_errors
      throw newFailure.failedAfter(attemptCount);
    }
  }
}

class _TestFailure<T> {
  final T value;
  final dart_test.TestFailure _failure;

  _TestFailure(this.value, this._failure);

  dart_test.TestFailure failedAfter(int count) => new dart_test.TestFailure(
      '${_failure.message}\n(Failed after $count attempts)');
}

class _TestShrinker<T> {
  final TestBody<T> testBody;
  final Gen<T> gen;
  _TestShrinker(this.testBody, this.gen);

  FutureMonad<_TestFailure<T>> improve(_TestFailure<T> t, int count) => count <=
          0
      ? new FutureMonad.of(t)
      : improveStep(t).map(
          (p) => p.item2.isEmpty ? p.item1 : improve(p.item2.first, count - 1));

  FutureMonad<Tuple2<_TestFailure<T>, Option<_TestFailure<T>>>> improveStep(
          _TestFailure<T> t) =>
      gen
          .shrink(t.value)
          .map(runOnce)
          .firstWhere((o) => o.isNotEmpty, defaultValue: () => new None())
          .map((o) => new Tuple2(t, o));

  Option<_TestFailure<T>> runOnce(T t) {
    try {
      testBody(t);
      return new None();
    } on dart_test.TestFailure catch (e) {
      return new Some(new _TestFailure(t, e));
    }
  }
}
