
///
Property<T> forAll<T>(Generator<T> gen) => new Property<T>();

///
class Generator<T> {}

///
class Gen {
  static final string = new Generator<String>();
}

///
class Property<T> {
  ///
  void test(String description, body(T t)) {}
}