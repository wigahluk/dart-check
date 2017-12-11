dart-check
==========

A library for using property checking techniques in the Dart language inspired by QuickCheck and ScalaCheck.

## Features

* Works with `dart.test` framework and incorporates a similar syntax to it.
* Random values are reproducible as QuickCheck or ScalaCheck.
* Monadic generators featuring **shuttlecock** Monad contract. 

## Usage

Yoou can use `dart-check` similarly to the way you use tests right now with `dart.test`:

```dart
void main() {
    group('String are reversable', () {
        forAll(Gen.string).test('Reversing', (s){
          expect(s, s);
        });
    });  
}
```

The `forAll` function takes a _Generator_ and returns a _Property_ which has a method `test` that you can use very similarly to the regular `test` function from `dart.test`.

```haskell
forAll :: Gen a -> Prop a
```

An important difference is that, in contrast with regular `test` test void functions, `Property.test` uses a function that does takes arguments, this arguments correspond to the generators used to build the _Property_. 


## Contributing

First of all, thanks for helping!

The steps are pretty much the same as in any other project: 

* Clone this repo:
    ```
    $ git clon egit@github.com:wogahluk/dart-check.git
    ```
* Get dependencies:
    ```
    $ pub get
    ```
* Do your change
* Be sure your code passes all tests (and that you added new ones for your change):
    ```
    $ pub run test
    ```
