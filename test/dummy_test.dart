import 'package:dartcheck/generators.dart';
import 'package:test/test.dart';

void main() {
  group('Hello My Dear!', () {
    group('String', () {
      test('Not crazy', () {
        expect(1, 1);
      });
      forAll(Gen.string).test('Starts with', (s){
        expect(s, s);
      });
    });
  });
}