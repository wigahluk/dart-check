dart-check
==========

A monadic QuickCheck inspired library for Dart

```dart

// Usage?

void main() {
    group('String', () {
        forAll(Gen.string).test('Starts with', (String s){
          expect(s, s);
        });
    });  
}

```