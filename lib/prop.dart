import 'package:dartcheck/gen.dart';
import 'package:dartcheck/rand.dart';
import 'package:shuttlecock/shuttlecock.dart';
import 'package:test/test.dart' as dart_test;

/// Returns a new Prop that can be used to run tests for a generator
Prop forAll<T>(Gen<T> gen) => new Prop(gen);

/// Type alias for tes bodies.
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
    // We need to run everything within the Dart test closure as it keeps track
    // of global state variables and can fail if asserts are executed without
    // the proper values.
    var count = 0;
    dart_test.test(name, () async {
      // TODO: The number of generated cases should be configurable
      final tryOrFailure = await _stream().take(100).map((genValue) {
        count++;
        return _tryOrFailure(testBody, genValue);
      }).firstWhere((o) => o.isNotEmpty, defaultValue: () => new None());
      _failDartTest(tryOrFailure, count);
    });
  }

  StreamMonad<T> _stream() => _gen.toStream(new Rand());

  static void _failDartTest(
      Option<dart_test.TestFailure> failure, int attemptCount) {
    if (failure.isNotEmpty) {
      final newMessage =
          '${failure.first.message}\n(Failed after $attemptCount attempts)';
      // TODO: wrap original Failure to avoid loosing any context.
      throw new dart_test.TestFailure(newMessage); // ignore: only_throw_errors
    }
  }

  static Option<dart_test.TestFailure> _tryOrFailure<T>(
      TestBody testBody, T t) {
    try {
      testBody(t);
      return new None();
    } on dart_test.TestFailure catch (e) {
      return new Some(e);
    }
  }
}
