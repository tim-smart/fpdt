import 'package:fpdt/either.dart' as E;
import 'package:fpdt/fpdt.dart';

/// A constant version on [None], as `Option<Never>`.
const Option<Never> kNone = None();

/// Returns an [Option] that resolves to a [None].
/// Represents a value that does not exists.
Option<T> none<T>() => kNone;

/// Returns an [Option] that resolves to a [Some], which wraps the given value.
/// Represents a value that does exist.
Option<T> some<T>(T value) => Some(value);

/// Returns an [Option] that returns [Some] or [None], depending on whether it
/// is `null` or not.
///
/// ```
/// expect(fromNullable(123), some(123));
/// expect(fromNullable(null), none());
/// ```
Option<T> fromNullable<T>(T? value) => value != null ? some(value) : kNone;

/// A wrapper around [fromNullable], that allows the type to be enforced.
/// Useful for function composition.
///
/// ```
/// final maybeString = fromNullableWith<String>();
///
/// expect(maybeString('hello'), some('hello'));
/// expect(maybeString(null), none());
/// maybeString(123); // <- compiler error
/// ```
Option<T> Function(T? value) fromNullableWith<T>() => fromNullable;

/// Returns a [Some] or [None] if the predicate returns `true` or `false`
/// respectively.
///
/// ```
/// expect(fromPredicate('hello', (_) => true), some('hello'));
/// expect(fromPredicate('hello', (_) => false), none());
/// expect(fromPredicate('hello', (str) => str == 'hello'), some('hello'));
/// ```
Option<T> fromPredicate<T>(T value, bool Function(T value) predicate) =>
    predicate(value) ? some(value) : kNone;

/// Wrapper around [fromPredicate] that can be curried with the value.
///
/// ```
/// final greaterThanTwo = fromPredicateK((int i) => i > 2);
///
/// expect(greaterThanTwo(3), some(3));
/// expect(greaterThanTwo(1), none());
/// ```
Option<T> Function(T value) fromPredicateK<T>(
  bool Function(T value) predicate,
) =>
    (value) => fromPredicate(value, predicate);

/// Transforms an [Option] into a value, using the `ifNone` and `ifSome`
/// functions.
///
/// ```
/// expect(
///   some(1).chain(fold(
///     () => 'no',
///     (number) => 'got $number',
///   )),
///   'got 1',
/// );
/// expect(
///   none().chain(fold(
///     () => 'no',
///     (number) => 'got $number',
///   )),
///   'no',
/// );
/// ```
B Function(Option<A> option) fold<A, B>(
  B Function() ifNone,
  B Function(A value) ifSome,
) =>
    (option) => option._fold(ifNone, ifSome);

/// Transforms the [Option] into a nullable value. [Some] unwraps to the value,
/// while [None] becomes `null`.
///
/// ```
/// expect(some('hello').chain(toNullable), 'hello');
/// expect(none().chain(toNullable), null);
/// ```
T? toNullable<T>(Option<T> option) => option._fold(() => null, identity);

/// If the [Option] is a [None], then the result of the given function will
/// determine the \[alt\]ernate / replacement [Option].
///
/// If it was [Some], then it does nothing.
///
/// ```
/// expect(
///   none().chain(alt(() => some('fallback'))),
///   some('fallback'),
/// );
/// expect(
///   some('hello').chain(alt(() => some('fallback'))),
///   some('hello'),
/// );
/// ```
Option<T> Function(Option<T> option) alt<T>(Lazy<Option<T>> f) =>
    (option) => isNone(option) ? f() : option;

/// Unwrap the [Option]'s value if it is [Some], otherwise it calls the `orElse`
/// function to determine the fallback value.
///
/// ```
/// expect(
///   some('hello').chain(getOrElse(() => 'fallback')),
///   'hello',
/// );
/// expect(
///   none().chain(getOrElse(() => 'fallback')),
///   'fallback',
/// );
/// ```
T Function(Option<T> option) getOrElse<T>(Lazy<T> orElse) =>
    fold(orElse, identity);

/// Transform the wrapped value if the [Option] is a [Some], using the
/// provided function.
///
/// ```
/// expect(
///   O.some(1).chain(O.map((i) => i * 2)),
///   equals(O.some(2)),
/// );
/// ```
Option<R> Function(Option<T> option) map<T, R>(
  R Function(T value) f,
) =>
    flatMap((a) => some(f(a)));

/// Execute a side effect on the wrapped value, if the [Option] is a [Some].
///
/// ```
/// expect(
///   O.some(1).chain(O.tap(print)), // Prints '1' to the console
///   equals(O.some(1)),
/// );
/// ```
Option<A> Function(Option<A> option) tap<A>(
  void Function(A value) f,
) =>
    map((a) {
      f(a);
      return a;
    });

/// Creates a function that accepts two [Option]'s, and if both of them are [Some],
/// then the transformer function is called with the unwrapped values.
///
/// ```
/// final transform = map2((int a, int b) => a + b);
///
/// expect(transform(some(1), some(2)), some(3));
/// expect(transform(some(1), none()), none());
/// ```
Option<R> Function(Option<A> optionA, Option<B> optionB) map2<A, B, R>(
  R Function(A a, B b) f,
) =>
    (a, b) => a._bindSome((a) => b._bindSome((b) => some(f(a, b))));

/// Creates a function that accepts three [Option]'s, and if they are all [Some],
/// then the transformer function is called with the unwrapped values.
///
/// ```
/// final transform = map3((int a, int b, int c) => a + b + c);
///
/// expect(transform(some(1), some(2), some(3)), some(6));
/// expect(transform(some(1), some(2), none()), none());
/// ```
Option<R> Function(
  Option<A> optionA,
  Option<B> optionB,
  Option<C> optionC,
) map3<A, B, C, R>(
  R Function(A a, B b, C c) f,
) =>
    (a, b, c) => a._bindSome(
        (a) => b._bindSome((b) => c._bindSome((c) => some(f(a, b, c)))));

/// A wrapper around [map2], useful for chaining.
/// The second [Option] is passed as the first argument.
///
/// ```
/// expect(
///   some(1).chain(map2K(some(2), (a, int b) => a + b)),
///   some(3),
/// );
/// expect(
///   some(1).chain(map2K(none(), (a, int b) => a + b)),
///   none(),
/// );
/// ```
Option<R> Function(Option<A> optionA) map2K<A, B, R>(
  Option<B> optionB,
  R Function(A a, B b) f,
) =>
    (optionA) => map2(f)(optionA, optionB);

/// A wrapper around [map3], useful for chaining.
/// The remaining [Option]'s are passed as arguments.
///
/// ```
/// expect(
///   some(1)
///     .chain(map2K(some(2), some(3), (a, int b, int c) => a + b + c)),
///   some(6),
/// );
/// expect(
///   some(1)
///     .chain(map2K(some(2), none(), (a, int b, int c) => a + b + c)),
///   none(),
/// );
/// ```
Option<R> Function(Option<A> optionA) map3K<A, B, C, R>(
  Option<B> optionB,
  Option<C> optionC,
  R Function(A a, B b, C c) f,
) =>
    (optionA) => map3(f)(optionA, optionB, optionC);

/// A variant of [map2], that accepts the two [Option]'s as a [Tuple2].
///
/// ```
/// expect(
///   tuple2(some(1), some(2)).chain(mapTuple2((a, b) => a + b)),
///   some(3),
/// );
/// expect(
///   tuple2(some(1), none()).chain(mapTuple2((a, b) => a + b)),
///   none(),
/// );
/// ```
Option<R> Function(Tuple2<Option<A>, Option<B>> tuple) mapTuple2<A, B, R>(
  R Function(A a, B b) f,
) =>
    (t) => map2(f)(t.first, t.second);

/// A variant of [map3], that accepts the [Option]'s as a [Tuple3].
///
/// ```
/// expect(
///   tuple3(some(1), some(2), some(3)).chain(mapTuple3((a, b, c) => a + b + c)),
///   some(6),
/// );
/// expect(
///   tuple3(some(1), some(2), none()).chain(mapTuple3((a, b, c) => a + b + c)),
///   none(),
/// );
/// ```
Option<R> Function(Tuple3<Option<A>, Option<B>, Option<C>> tuple)
    mapTuple3<A, B, C, R>(
  R Function(A a, B b, C c) f,
) =>
        (t) => map3(f)(t.first, t.second, t.third);

/// Transform the [Option] into another [Option], using the given function.
///
/// ```
/// expect(
///   some(1).chain(flatMap((i) => some(i + 2))),
///   some(3),
/// );
/// expect(
///   some(1).chain(flatMap((i) => none())),
///   none(),
/// );
/// ```
Option<B> Function(Option<A> option) flatMap<A, B>(
  Option<B> Function(A value) f,
) =>
    (o) => o._bindSome(f);

/// A variant of [flatMap] that appends the result to a tuple.
Option<Tuple2<A, A2>> Function(Option<A> o) flatMapTuple2<A, A2>(
  Option<A2> Function(A a) f,
) =>
    flatMap((a) => f(a).p(map((b) => tuple2(a, b))));

/// A variant of [flatMap] that appends the result to a tuple.
Option<Tuple3<A, A2, A3>> Function(Option<Tuple2<A, A2>> o)
    flatMapTuple3<A, A2, A3>(
  Option<A3> Function(Tuple2<A, A2> a) f,
) =>
        flatMap((a) => f(a).p(map((a3) => tuple3(a.first, a.second, a3))));

/// Using the given `predicate`, conditionally convert the [Option] to a [None].
///
/// ```
/// expect(
///   some('hello').chain(filter((s) => s == 'hello')),
///   some('hello'),
/// );
/// expect(
///   some('asdf').chain(filter((s) => s == 'hello')),
///   none(),
/// );
/// ```
Option<T> Function(Option<T> option) filter<T>(
  bool Function(T value) predicate,
) =>
    flatMap(fromPredicateK(predicate));

/// Returns `true` if the [Option] is a [None].
///
/// ```
/// expect(isNone(none()), true);
/// expect(isNone(some()), false);
/// ```
bool isNone<T>(Option<T> option) => option._isNone;

/// Returns `true` if the [Option] is a [Some].
///
/// ```
/// expect(isSome(some()), true);
/// expect(isSome(none()), false);
/// ```
bool isSome<T>(Option<T> option) => option._isSome;

/// Returns the value as a [Some] if the function succeeds.
/// If it raises an exception, then it will return [None].
///
/// ```
/// expect(tryCatch(() => 'hello'), some('hello'));
/// expect(tryCatch(() => throw 'fail'), none());
/// ```
Option<T> tryCatch<T>(T Function() f) {
  try {
    return some(f());
  } catch (_) {
    return kNone;
  }
}

/// A variant of [tryCatch], that allows for passing in external values.
///
/// ```
/// final catcher = tryCatchK((int i) => i > 5 ? throw 'fail' : i);
/// expect(catcher(10), some(10));
/// expect(catcher(3), none());
/// ```
Option<B> Function(A a) tryCatchK<A, B>(B Function(A value) f) =>
    (a) => tryCatch(() => f(a));

/// A variant of [tryCatchK], that allows for passing in an [Option].
/// If the [Option] is [Some], then the value is unwrapped and passed into
/// the function.
///
/// ```
/// expect(
///   some(10).chain(chainTryCatchK((i) => i > 5 ? throw 'fail' : i)),
///   some(10),
/// );
/// expect(
///   some(3).chain(chainTryCatchK((i) => i > 5 ? throw 'fail' : i)),
///   none(),
/// );
/// ```
Option<B> Function(Option<A> a) chainTryCatchK<A, B>(B Function(A value) f) =>
    flatMap(tryCatchK(f));

/// Returns an function that transforms a value and can return a nullable result.
/// If the result is `null`, then [None] is returned. Otherwise it is wrapped in
/// [Some].
///
/// ```
/// final transform = fromNullableK((int i) => i > 5 ? i : null);
///
/// expect(transform(10), some(10));
/// expect(transform(3), none());
/// ```
Option<B> Function(A value) fromNullableK<A, B>(
  B? Function(A value) f,
) =>
    (a) => fromNullable(f(a));

/// Returns an function that transforms an [Option].
/// If the given transformer returns `null`, then [None] is returned.
///
/// ```
/// expect(
///   some(10).chain(chainNullableK((i) => i > 5 ? i : null)),
///   some(10),
/// );
/// expect(
///   some(3).chain(chainNullableK((i) => i > 5 ? i : null)),
///   none(),
/// );
/// ```
Option<B> Function(Option<A> option) chainNullableK<A, B>(
  B? Function(A value) f,
) =>
    flatMap(fromNullableK(f));

/// Transforms an [Either] into an [Option].
/// [Right] becomes [Some], and [Left] becomes [None].
///
/// ```
/// expect(E.right('hello').chain(fromEither), some('hello'));
/// expect(E.left('fail').chain(fromEither), none());
/// ```
Option<R> fromEither<L, R>(Either<L, R> either) =>
    either.chain(E.fold((_) => kNone, some));

/// Flatten's nested [Option] to a single level.
///
/// ```
/// expect(some(some(1)), some(1));
/// expect(some(none()), none());
/// ```
Option<A> flatten<A>(Option<Option<A>> option) => option._bindSome(identity);

/// Represents a value that could be missing - an \[option\]al value.
///
/// If the value is present, then it will be wrapped in a [Some] instance.
/// If the value is missing, then it will represented with a [None] instance.
abstract class Option<T> {
  const Option();

  bool get _isNone;
  bool get _isSome;

  B _fold<B>(B Function() ifNone, B Function(T value) ifSome);
  Option<B> _bindSome<B>(Option<B> Function(T value) ifSome);

  /// Adds support for the `json_serializable` package.
  factory Option.fromJson(
    dynamic json,
    T Function(dynamic json) fromJsonT,
  ) =>
      json != null ? some(fromJsonT(json)) : kNone;

  /// Adds support for the `json_serializable` package.
  Object? toJson(Object? Function(T v) toJsonT);

  @override
  String toString() => _fold(() => 'None', (a) => 'Some($a)');
}

/// Represents a present value. The [value] property contains the wrapped value.
class Some<A> extends Option<A> {
  const Some(this.value);

  final A value;

  @override
  final _isSome = true;

  @override
  final _isNone = false;

  @override
  B _fold<B>(B Function() ifNone, B Function(A value) ifSome) => ifSome(value);

  @override
  Option<B> _bindSome<B>(Option<B> Function(A value) ifSome) => ifSome(value);

  @override
  Object? toJson(Object? Function(A v) toJsonT) => toJsonT(value);

  @override
  bool operator ==(other) => other is Some && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Represents a missing value.
class None<A> extends Option<A> {
  const None();

  @override
  R _fold<R>(R Function() ifNone, R Function(A value) ifSome) => ifNone();

  @override
  Option<B> _bindSome<B>(Option<B> Function(A value) ifSome) => kNone;

  @override
  final _isSome = false;

  @override
  final _isNone = true;

  @override
  Object? toJson(Object? Function(A v) toJsonT) => null;

  @override
  bool operator ==(other) => other is None;

  @override
  int get hashCode => 0;
}

typedef DoAdapter = A Function<A>(Option<A>);

A _doAdapter<A>(Option<A> option) {
  return option._fold(() => throw "none", (value) => value);
}

// ignore: non_constant_identifier_names
Option<A> Do<A>(A Function(DoAdapter $) f) {
  try {
    return Some(f(_doAdapter));
  } catch (_) {
    return kNone;
  }
}
