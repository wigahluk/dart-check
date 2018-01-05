import 'dart:math';

import 'package:dartcheck/pair.dart';

/// Represents a random generator based on the Dart Random class
class Rand {
  final int _seed;

  // ignore: public_member_api_docs
  Rand({seed: 1}) : _seed = seed;

  /// Produces a boolean with a new generator
  Pair<bool, Rand> boolValue() => new Pair(_nextBool(), next());

  /// Produces a double with a new generator
  Pair<double, Rand> doubleValue() => new Pair(_nextDouble(), next());

  /// Produces the next Random generator
  Rand next() => new Rand(seed: _nextValue());

  /// Produces the state of this generator
  Pair<int, Rand> value() => new Pair(_seed, next());

  bool _nextBool() => new Random(_seed).nextBool();

  double _nextDouble() => new Random(_seed).nextDouble();

  int _nextValue() => new Random(_seed).nextInt(pow(2, 32));
}
