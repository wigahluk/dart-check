dart-check
==========

An experimental library for using property checking techniques in the Dart language inspired by [QuickCheck](https://hackage.haskell.org/package/QuickCheck) and [ScalaCheck](https://www.scalacheck.org/).

## Features

* Works with `dart.test` framework and incorporates a similar syntax to it.
* Random values are reproducible as **QuickCheck** or **ScalaCheck**.
* Monadic generators featuring **shuttlecock** _Monad_ contract. 

## Usage

You can use `dart-check` similarly to the way you use tests right now with `dart.test`:

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

An important difference is that, in contrast with regular `Dart test` test void functions, `Property.test` uses a function that does take one argument, this argument correspond to the generator used to build the _Property_. 

## Limitations

* Limited number of generators.
* Number of cases and shrinking steps are not yet configurable.
* Random generators use `Dart.Random` internally which is not suitable for cryptographic purposes. I can't think on any reason why this would be an issue, but if it is, you'll probably want to use some other tool.

## Contributing

First of all, thanks for helping!

The steps are pretty much the same as in any other project: 

* Clone this repo:
    ```
    $ git clone git@github.com:wigahluk/dart-check.git
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
