import 'package:fpdt/function.dart';
import 'package:fpdt/option.dart' as O;

/// Returns an [Either] that resolves to a [Left] value.
Either<L, R> left<L, R>(L value) => Left(value);

/// Returns an [Either] that resolves to a [Right] value.
Either<L, R> right<L, R>(R value) => Right(value);

/// Transforms an [Either] using the `ifLeft` and `ifRight` functions.
///
/// ```
/// expect(
///   right(1).chain(fold(
///     (_) => -1,
///     (number) => number + 1,
///   )),
///   equals(2),
/// );
/// ```
///
/// ```
/// expect(
///   left('fail').chain(fold(
///     (left) => 'caught: $left',
///     (right) => 'yay!',
///   )),
///   equals('caught: fail'),
/// );
/// ```
T Function(Either<L, R> either) fold<L, R, T>(
  T Function(L left) ifLeft,
  T Function(R right) ifRight,
) =>
    (either) => either._fold(ifLeft, ifRight);

/// Returns `true` if the [Either] is a [Left].
bool isLeft<L, R>(Either<L, R> either) => either._isLeft();

/// Returns `true` if the [Either] is a [Right].
bool isRight<L, R>(Either<L, R> either) => either._isRight();

/// Swaps the [Left] and [Right] type values.
///
/// ```
/// expect(swap(right(123)), equals(left(123)));
/// expect(swap(left('hi')), equals(right('hi')));
/// ```
Either<R, L> swap<L, R>(Either<L, R> either) => either._fold(right, left);

/// Transforms the wrapped value if the [Either] is a [Right].
///
/// ```
/// expect(
///   right(1).chain(map((i) => i * 2)),
///   equals(right(2)),
/// );
/// ```
Either<L, NR> Function(Either<L, R> either) map<L, R, NR>(
  NR Function(R value) f,
) =>
    fold(left, (r) => right(f(r)));

/// Perform a side effect on the [Either], if it is a [Right].
///
/// ```
/// expect(
///   right(1).chain(tap(print)), // Prints '1' to the console
///   equals(right(1)),
/// );
/// ```
Either<L, R> Function(Either<L, R> either) tap<L, R>(
  void Function(R value) f,
) =>
    map((r) {
      f(r);
      return r;
    });

Either<L, NR> Function(Either<L, R> either) flatMap<L, R, NR>(
  Either<L, NR> Function(R value) f,
) =>
    fold(left, f);

Either<dynamic, R> tryCatch<R>(R Function() f) {
  try {
    return right(f());
  } catch (err) {
    return left(err);
  }
}

Either<L, R> Function(Either<L, R> either) alt<L, R>(
  Either<L, R> Function(L left) orElse,
) =>
    fold(orElse, right);

R Function(Either<L, R> either) getOrElse<L, R>(
  R Function(L left) orElse,
) =>
    fold(orElse, identity);

Either<L, R> Function(Either<L, R> either) filter<L, R>(
  bool Function(R right) predicate,
  L Function(R right) orElse,
) =>
    flatMap(fromPredicateK(predicate, orElse));

/// Create an [Either] from a function that returns a [bool].
///
/// If the function returns true, then the returned [Either] will be a [Right]
/// containing the given `value`.
///
/// If the function returns `false`, then the returned [Either] will be a [Left]
/// containing the value returned from executing the `orElse` function.
///
/// ```
/// expect(
///   fromPredicate(2, (i) => i > 1, (_) => 'number too small'),
///   equals(right(2)),
/// );
/// ```
///
/// ```
/// expect(
///   fromPredicate(0, (i) => i > 1, (_) => 'number too small'),
///   equals(left('number too small')),
/// );
/// ```
Either<L, R> fromPredicate<L, R>(
  R value,
  bool Function(R value) predicate,
  L Function(R value) orElse,
) =>
    predicate(value) ? right(value) : left(orElse(value));

/// Wrapper for [fromPredicate], that returns a function which transforms a
/// value into an [Either].
///
/// ```
/// final transform = fromPredicateK(
///   (int number) => number > 1,
///   (_) => 'number too small',
/// );
///
/// expect(transform(2), right(2));
/// expect(transform(0), left('number too small'));
/// ```
Either<L, R> Function(R value) fromPredicateK<L, R>(
  bool Function(R value) predicate,
  L Function(R value) orElse,
) =>
    (r) => fromPredicate(r, predicate, orElse);

Either<L, R> Function(O.Option<R> option) fromOption<L, R>(
  L Function() onNone,
) =>
    O.fold(() => left(onNone()), right);

/// Create an [Either] from a nullable value.
/// If the value is `null`, then the result of the `orElse` function is used
/// as a [Left] value.
///
/// ```
/// expect(
///   fromNullable('hello', () => 'it was null'),
///   right('hello'),
/// );
///
/// expect(
///   fromNullable(null, () => 'it was null'),
///   left('it was null'),
/// );
/// ```
Either<L, R> fromNullable<L, R>(
  R? value,
  Lazy<L> orElse,
) =>
    value != null ? right(value) : left(orElse());

/// A wrapper for [fromNullable], that returns a function that accepts a
/// value to be transformed.
///
/// ```
/// final transform = fromNullableK(
///   (String s) => s == 'hello' ? s : null,
///   () => 'it was not hello',
/// );
///
/// expect(
///   transform('hello'),
///   right('hello'),
/// );
///
/// expect(
///   transform('asdf'),
///   left('it was not hello'),
/// );
/// ```
Either<L, R> Function(A value) fromNullableK<A, L, R>(
  R? Function(A value) f,
  L Function(A value) orElse,
) =>
    (value) => fromNullable(f(value), () => orElse(value));

/// A wrapper for [fromNullableK], that allows for chaining.
///
/// ```
/// expect(
///   right('hello').chain(chainNullableK(
///     (s) => s == 'hello' ? s : null,
///     () => 'it was not hello',
///   )),
///   right('hello'),
/// );
///
/// expect(
///   right('asdf').chain(chainNullableK(
///     (s) => s == 'hello' ? s : null,
///     () => 'it was not hello',
///   )),
///   left('it was not hello'),
/// );
/// ```
Either<L, R2> Function(Either<L, R> value) chainNullableK<L, R, R2>(
  R2? Function(R right) f,
  L Function(R right) orElse,
) =>
    flatMap(fromNullableK(f, orElse));

abstract class Either<L, R> {
  const Either();

  T _fold<T>(T Function(L left) ifLeft, T Function(R value) ifRight);
  bool _isLeft();
  bool _isRight();
}

class Left<L, R> extends Either<L, R> {
  const Left(this.value);
  final L value;

  @override
  T _fold<T>(T Function(L left) ifLeft, T Function(R value) ifRight) =>
      ifLeft(value);

  @override
  bool _isLeft() => true;

  @override
  bool _isRight() => false;

  @override
  String toString() => 'Left($value)';

  @override
  bool operator ==(other) => other is Left && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class Right<L, R> extends Either<L, R> {
  const Right(this.value);
  final R value;

  @override
  T _fold<T>(T Function(L left) ifLeft, T Function(R value) ifRight) =>
      ifRight(value);

  @override
  bool _isLeft() => false;

  @override
  bool _isRight() => true;

  @override
  String toString() => 'Right($value)';

  @override
  bool operator ==(other) => other is Right && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
