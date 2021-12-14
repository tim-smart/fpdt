library fpdt;

import 'package:fpdt/either.dart' as E;
import 'package:fpdt/function.dart';

Option<T> none<T>() => const None();
Option<T> some<T>(T value) => Some(value);
Option<T> fromNullable<T>(T? value) => value != null ? some(value) : none();

R Function(Option<T> option) fold<T, R>(
  R Function() ifNone,
  R Function(T value) ifSome,
) =>
    (option) => option._fold(ifNone, ifSome);

Option<R> Function(Option<T> option) foldOption<T, R>(
  Option<R> Function() ifNone,
  Option<R> Function(Some<T> value) ifSome,
) =>
    (option) => option._foldOption(ifNone, ifSome);

T? toNullable<T>(Option<T> option) => option._fold(() => null, (v) => v);

E.Either<L, R> Function(Option<R> option) toEither<L, R>(L Function() orElse) =>
    fold(() => E.left(orElse()), E.right);

Option<T> Function(Option<T> option) orElse<T>(
  Option<T> Function() f,
) =>
    foldOption(f, identity);

T Function(Option<T> option) getOrElse<T>(
  T Function() orElse,
) =>
    fold(orElse, identity);

Option<R> Function(Option<T> option) map<T, R>(
  R Function(T value) f,
) =>
    fold(none, (value) => Some(f(value)));

Option<R> Function(Option<A> optionA, Option<B> optionB) map2<A, B, R>(
  R Function(A a, B b) f,
) =>
    (a, b) =>
        a.chain(fold(none, (a) => b.chain(fold(none, (b) => Some(f(a, b))))));

Option<R> Function(
  Option<A> optionA,
  Option<B> optionB,
  Option<C> optionC,
) map3<A, B, C, R>(
  R Function(A a, B b, C c) f,
) =>
    (a, b, c) => a.chain(fold(
        none,
        (a) => b.chain(
            fold(none, (b) => c.chain(fold(none, (c) => Some(f(a, b, c))))))));

Option<R> Function(Option<T> option) flatMap<T, R>(
  Option<R> Function(T value) f,
) =>
    fold(none, f);

Option<T> Function(Option<T> option) filter<T>(
  bool Function(T value) predicate,
) =>
    foldOption(none, (a) => predicate(a.value) ? a : none());

bool isNone<T>(Option<T> option) => option._isNone();
bool isSome<T>(Option<T> option) => option._isSome();

abstract class Option<T> {
  const Option();

  R _fold<R>(R Function() ifNone, R Function(T value) ifSome);
  Option<R> _foldOption<R>(
    Option<R> Function() ifNone,
    Option<R> Function(Some<T> value) ifSome,
  );
  bool _isNone();
  bool _isSome();

  @override
  String toString() => _fold(() => 'None', (a) => 'Some($a)');
}

class Some<T> extends Option<T> {
  const Some(this.value);

  final T value;

  @override
  bool _isSome() => true;

  @override
  bool _isNone() => false;

  @override
  R _fold<R>(R Function() ifNone, R Function(T value) ifSome) => ifSome(value);

  @override
  Option<R> _foldOption<R>(
    Option<R> Function() ifNone,
    Option<R> Function(Some<T> value) ifSome,
  ) =>
      ifSome(this);

  @override
  bool operator ==(other) => other is Some && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class None<T> extends Option<T> {
  const None();

  @override
  R _fold<R>(R Function() ifNone, R Function(T value) ifSome) => ifNone();

  @override
  Option<R> _foldOption<R>(
    Option<R> Function() ifNone,
    Option<R> Function(Some<T> value) ifSome,
  ) =>
      ifNone();

  @override
  bool _isSome() => false;

  @override
  bool _isNone() => true;

  @override
  bool operator ==(other) => other is None;

  @override
  int get hashCode => 0;
}
