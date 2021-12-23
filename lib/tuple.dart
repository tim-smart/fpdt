import 'package:fpdt/fpdt.dart';

Tuple2<A, B> tuple2<A, B>(A a, B b) => Tuple2(a, b);
Tuple3<A, B, C> tuple3<A, B, C>(A a, B b, C c) => Tuple3(a, b, c);

class Tuple3<T1, T2, T3> extends Tuple {
  /// Returns the first item of the tuple
  final T1 first;

  /// Returns the second item of the tuple
  final T2 second;

  /// Returns the second item of the tuple
  final T3 third;

  /// Creates a new tuple value with the specified items.
  const Tuple3(this.first, this.second, this.third) : super(3);

  /// Operator access
  Object? operator [](int i) {
    switch (i) {
      case 0:
        return first;
      case 1:
        return second;
      case 2:
        return third;
    }

    throw IndexError(i, this);
  }

  /// Create a new tuple value with the specified list [items].
  factory Tuple3.fromList(List items) {
    if (items.length != 3) {
      throw ArgumentError('items must have length 2');
    }

    return Tuple3<T1, T2, T3>(items[0] as T1, items[1] as T2, items[2] as T3);
  }

  /// Returns a tuple with the first item set to the specified value.
  Tuple3<T1, T2, T3> withItem1(T1 v) => Tuple3<T1, T2, T3>(v, second, third);

  /// Returns a tuple with the second item set to the specified value.
  Tuple3<T1, T2, T3> withItem2(T2 v) => Tuple3<T1, T2, T3>(first, v, third);

  /// Returns a tuple with the third item set to the specified value.
  Tuple3<T1, T2, T3> withItem3(T3 v) => Tuple3<T1, T2, T3>(first, second, v);

  /// Creates a [List] containing the items of this [Tuple3].
  ///
  /// The elements are in item order. The list is variable-length
  /// if [growable] is true.
  List toList({bool growable = false}) =>
      List.from([first, second, third], growable: growable);

  @override
  String toString() => '($first, $second, $third)';

  @override
  bool operator ==(Object other) =>
      other is Tuple3 &&
      other.first == first &&
      other.second == second &&
      other.third == third;

  @override
  int get hashCode => first.hashCode ^ second.hashCode ^ third.hashCode;
}
