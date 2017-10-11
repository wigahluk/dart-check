import 'package:dartcheck/generators.dart';
import 'package:test/test.dart';

void main() {
  group('', () {
    group('String', () {
      forAll(Gen.string).test('Starts with', (s){
        expect(s, s);
      });
    });
  });
}