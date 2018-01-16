import 'package:quiver_hashcode/hashcode.dart';
import 'package:shuttlecock/shuttlecock.dart';

/// A convenience Pair class.

class Pair<A, B> {
  /// First element of this tuple
  final A first;

  /// Second element of this tuple
  final B second;

  /// Creates a new pair
  Pair(this.first, this.second);

  @override
  int get hashCode => hash2(first.hashCode, second.hashCode);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pair && other.first == first && other.second == second;

  /// Map acting on the first coordinate
  Pair<C, B> mapFirst<C>(Function1<A, C> f) => new Pair(f(first), second);

  @override
  String toString() => '($first, $second)';
}
