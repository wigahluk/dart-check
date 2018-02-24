[![Build Status](https://travis-ci.org/wigahluk/dart-check.svg?branch=master)](https://travis-ci.org/wigahluk/dart-check)

dart-check
==========

An experimental library for using property checking techniques in the Dart language inspired by [QuickCheck](https://hackage.haskell.org/package/QuickCheck) and [ScalaCheck](https://www.scalacheck.org/).

## Features

* Works with `dart.test` framework and incorporates a similar syntax to it.
* Random values are reproducible like in **QuickCheck** or **ScalaCheck**. This means that every time a test is ran it will use the same values.
* _For advanced users:_ Monadic generators featuring **shuttlecock** _Monad_ contract. You don't need to know what a _Monad_ is in order to use **dart-check** but if you know what they are, you will find _generators_ pretty familiar.

## Property-Based Testing

The idea of a _property_ is close to that one of a program _specification_ where you describe how a program should behave instead of what should it do given a particular input as ina traditional unit test.

Lets look at one example: imagine that you are implementing the function `double divide(double a, double b)` which returns the result of `a` divided by `b`. In a traditional unit test you would write probably something like:

```dart
test('divide and multiply', () {
  final c = divide(2, 3) * 3;
  expect(2, 2);
});
```

There are two issues with this approach:

* You are only testing one particular case
* There is the corner case where `b == 0` that is not covered.

The idea of a specification is that you can state the behavior of your program like:

_For all `a` and `b`, if `c == divide(a, b)` then `a == c * b`_

In the _property-based testing_ jargon, a property is basically an executable specification and you may write something like:

```dart
forAll(Gen.zip2(Gen.double, Gen.double)).test('divide and multiply', (pair) {
  final c = divide(pair.item1, pair.item2) * pair.item2;
  expect(c, pair.item1);
});
```

The main idea is that you don't need to provide a specific example, instead you provide an abstract specification of what should be the behavior of your program.

There is a problem though which is that in practice it is pretty complex to verify your program in such an abstract way. Instead we use what is also called a _parametrized test_ which is: generate as many values as possible of the kind of values you are interested, in our example these would be pairs of `double`, and run the test against them.

This is exactly what **dart-check** allows you to do.

To generate these values we use what is called a _generator_ which does exactly that, generates values of some type as `Int` or `String`. The generated values should be randomized to improve the possibility of catching errors in the code and should be as much as needed, to make one test more exhaustive we can simply increase the amount of values it will use to test. 

This idea was originally implemented in **QuickCheck** for **Haskell** and has been reimplemented for almost all popular languages. One of these implementations is **ScalaCheck** for **Scala** which I have used as an inspiration for **dart-check** as Scala shares more with Dart and was easier to adapt concepts from than what Haskell would be.

As with QuickCheck and ScalaCheck, the main ingredients in **dart-check** are the _generator combinators_ that allow developers to build new generators from simple and pre-canned ones.

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

## Known Issues

* Limited number of generators.
* Number of cases and shrinking steps are not yet configurable.
* Shrinking function is lost after `map` or `flatMap`. We are working on it.
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
