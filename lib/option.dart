import 'package:fpdt/either.dart' as E;
import 'package:fpdt/function.dart';
import 'package:fpdt/tuple.dart';

/// Returns an [Option] that resolves to a [None].
/// Represents a value that does not exists.
Option<T> none<T>() => const None();

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
Option<T> fromNullable<T>(T? value) => value != null ? some(value) : none();

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
    predicate(value) ? some(value) : none();

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
T? toNullable<T>(Option<T> option) => option._fold(() => null, (v) => v);

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
Option<T> Function(Option<T> option) alt<T>(Lazy<Option<T>> f) => fold(f, some);

/// Unwrap the [Option]'s value if it is [Some], otherwise it calls the `orElse`
/// function to determine the fallback value.
///
/// ```
/// expect(
///   some('hello').chain(getOrElse(() => 'fallback')),
///   some('hello'),
/// );
/// expect(
///   none().chain(getOrElse(() => 'fallback')),
///   some('fallback'),
/// );
/// ```
T Function(Option<T> option) getOrElse<T>(Lazy<T> orElse) =>
    fold(orElse, identity);

/// Transform the wrapped value if the [O.Option] is a [O.Some], using the
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
    fold(none, (value) => Some(f(value)));

/// Execute a side effect on the wrapped value, if the [O.Option] is a [O.Some].
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

Option<R> Function(Option<A> optionA) map2K<A, B, R>(
  Option<B> optionB,
  R Function(A a, B b) f,
) =>
    (optionA) => map2(f)(optionA, optionB);

Option<R> Function(Option<A> optionA) map3K<A, B, C, R>(
  Option<B> optionB,
  Option<C> optionC,
  R Function(A a, B b, C c) f,
) =>
    (optionA) => map3(f)(optionA, optionB, optionC);

Option<R> Function(Tuple2<Option<A>, Option<B>> tuple) mapTuple2<A, B, R>(
  R Function(A a, B b) f,
) =>
    (t) => map2(f)(t.first, t.second);

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
    fold(none, f);

Option<T> Function(Option<T> option) filter<T>(
  bool Function(T value) predicate,
) =>
    flatMap(fromPredicateK(predicate));

bool isNone<T>(Option<T> option) => option._isNone();
bool isSome<T>(Option<T> option) => option._isSome();

Option<T> tryCatch<T>(T Function() f) {
  try {
    return some(f());
  } catch (_) {
    return none();
  }
}

Option<B> Function(A a) tryCatchK<A, B>(B Function(A value) f) =>
    (a) => tryCatch(() => f(a));

Option<B> Function(Option<A> a) chainTryCatchK<A, B>(B Function(A value) f) =>
    flatMap(tryCatchK(f));

Option<B> Function(A value) fromNullableK<A, B>(
  B? Function(A value) f,
) =>
    (a) => fromNullable(f(a));

Option<B> Function(Option<A> option) chainNullableK<A, B>(
  B? Function(A value) f,
) =>
    flatMap(fromNullableK(f));

Option<R> fromEither<L, R>(E.Either<L, R> either) =>
    either.chain(E.fold((_) => none(), some));

Option<A> flatten<A>(Option<Option<A>> option) => option._fold(none, (o) => o);

abstract class Option<T> {
  const Option();

  R _fold<R>(R Function() ifNone, R Function(T value) ifSome);
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
  bool operator ==(other) => other is Some && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class None<T> extends Option<T> {
  const None();

  @override
  R _fold<R>(R Function() ifNone, R Function(T value) ifSome) => ifNone();

  @override
  bool _isSome() => false;

  @override
  bool _isNone() => true;

  @override
  bool operator ==(other) => other is None;

  @override
  int get hashCode => 0;
}
