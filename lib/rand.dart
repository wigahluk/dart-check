import 'dart:math';

import 'package:tuple/tuple.dart';

/// Represents a random generator based on the Dart Random class
class Rand {
  final int _seed;

  // ignore: public_member_api_docs
  Rand({seed: 1}) : _seed = seed;

  @override
  int get hashCode => _seed.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Rand && other._seed == _seed;

  /// Produces a boolean with a new generator
  Tuple2<bool, Rand> boolValue() => new Tuple2(_nextBool(), next());

  /// Produces a int in range with a new generator
  Tuple2<int, Rand> chooseInt(int min, int max) =>
      new Tuple2(_nextValueInRange(min, max), next());

  /// Produces a double with a new generator
  Tuple2<double, Rand> doubleValue() => new Tuple2(_nextDouble(), next());

  /// Produces the next Random generator
  Rand next() => new Rand(seed: _nextValue());

  /// Produces the state of this generator
  Tuple2<int, Rand> value() => new Tuple2(_seed, next());

  bool _nextBool() => _seededRandom().nextBool();

  double _nextDouble() => _seededRandom().nextDouble();

  int _nextValue() => _seededRandom().nextInt(pow(2, 32));

  int _nextValueInRange(min, max) => _seededRandom().nextInt(max - min) + min;

  Random _seededRandom() => new Random(_seed);
}
