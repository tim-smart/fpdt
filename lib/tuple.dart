Tuple2<A, B> tuple2<A, B>(A a, B b) => Tuple2(a, b);
Tuple3<A, B, C> tuple3<A, B, C>(A a, B b, C c) => Tuple3(a, b, c);

class Tuple2<A, B> {
  const Tuple2(this.first, this.second);

  final A first;
  final B second;

  Tuple2<A, B> copyWith({
    A? first,
    B? second,
  }) =>
      Tuple2(first ?? this.first, second ?? this.second);

  @override
  String toString() => 'Tuple2($first, $second)';

  @override
  bool operator ==(Object other) =>
      (other is Tuple2) && other.first == first && other.second == second;

  @override
  int get hashCode => first.hashCode ^ second.hashCode;
}

class Tuple3<A, B, C> {
  const Tuple3(this.first, this.second, this.third);

  final A first;
  final B second;
  final C third;

  Tuple3<A, B, C> copyWith({
    A? first,
    B? second,
    C? third,
  }) =>
      Tuple3(first ?? this.first, second ?? this.second, third ?? this.third);

  @override
  String toString() => 'Tuple3($first, $second, $third)';

  @override
  bool operator ==(Object other) =>
      (other is Tuple3) &&
      other.first == first &&
      other.second == second &&
      other.third == third;

  @override
  int get hashCode => first.hashCode ^ second.hashCode ^ third.hashCode;
}
