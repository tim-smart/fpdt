import 'package:fpdt/fpdt.dart';
import 'package:fpdt/option.dart' as O;

/// Returns an [Either] that resolves to a [Left] value.
Either<L, R> left<L, R>(L value) => Left(value);

/// Returns an [Either] that resolves to a [Right] value.
Either<L, R> right<L, R>(R value) => Right(value);

class UnwrapException<L> implements Exception {
  UnwrapException(this.value);

  final L value;

  @override
  String toString() => value.toString();
}

/// Unwraps the value of an [Either], throwing if the value is [Left].
R unwrap<R>(Either<dynamic, R> either) => either._fold(
      (l) => throw UnwrapException(l),
      identity,
    );

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
bool isLeft<L, R>(Either<L, R> either) => either._isLeft;

/// Returns `true` if the [Either] is a [Right].
bool isRight<L, R>(Either<L, R> either) => either._isRight;

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
    fold(left, f.compose(right));

/// Transforms the wrapped value if the [Either] is a [Left].
///
/// ```
/// expect(
///   left('fail').chain(mapLeft((s) => '${s}ure')),
///   equals(left('failure')),
/// );
/// ```
Either<L2, R> Function(Either<L1, R> either) mapLeft<L1, L2, R>(
  L2 Function(L1 value) f,
) =>
    fold(f.compose(left), right);

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

/// Transforms [Right] values with the given function, that returns another [Either].
/// The resulting [Either] is then flattened / replaces the existing value.
///
/// ```
/// expect(
///   right('hello').chain(flatMap((s) => right('$s world!'))),
///   right('hello world!'),
/// );
/// expect(
///   right('hello').chain(flatMap((s) => left('fail'))),
///   left('fail'),
/// );
/// ```
Either<L, NR> Function(Either<L, R> either) flatMap<L, R, NR>(
  Either<L, NR> Function(R value) f,
) =>
    fold(left, f);

/// A variant of [flatMap] that appends the result to a tuple.
Either<L, Tuple2<R, R2>> Function(Either<L, R> either) flatMapTuple2<L, R, R2>(
  Either<L, R2> Function(R value) f,
) =>
    fold(left, (r) => f(r).p(map((r2) => tuple2(r, r2))));

/// A variant of [flatMap] that appends the result to a tuple.
Either<L, Tuple3<R, R2, R3>> Function(Either<L, Tuple2<R, R2>> either)
    flatMapTuple3<L, R, R2, R3>(
  Either<L, R3> Function(Tuple2<R, R2> a) f,
) =>
        fold(left, (t) => f(t).p(map((r3) => tuple3(t.first, t.second, r3))));

/// Runs the given function, and the result is wrapped in a [Right].
/// If it raises an error, then the `onError` callback determines the [Left]
/// value.
///
/// ```
/// expect(
///   tryCatch(() => 123, (err, stack) => 'fail'),
///   right(123),
/// );
/// expect(
///   tryCatch(() => throw 'error', (err, stack) => 'fail'),
///   left('fail'),
/// );
/// ```
Either<L, R> tryCatch<L, R>(
  Lazy<R> f,
  L Function(dynamic error, StackTrace stack) onError,
) {
  try {
    return right(f());
  } catch (err, stack) {
    return left(onError(err, stack));
  }
}

/// Runs the given function, and the result is wrapped in a [Right].
/// If it raises an error, then the `onError` callback determines the [Left]
/// value.
///
/// The function accepts an externally passed value.
///
/// ```
/// final catcher = tryCatchK(
///   (int i) => i > 5 ? i : throw 'error',
///   (err, stack) => 'number too small',
/// );
///
/// expect(
///   catcher(10),
///   right(10),
/// );
/// expect(
///   catcher(3),
///   left('number too small'),
/// );
/// ```
Either<L, R> Function(A value) tryCatchK<A, L, R>(
  R Function(A value) f,
  L Function(dynamic error, StackTrace stack) onError,
) =>
    (value) => tryCatch(() => f(value), onError);

/// Runs the given function, and the result is wrapped in a [Right].
/// If it raises an error, then the `onError` callback determines the [Left]
/// value.
///
/// The returned function accepts an [Either], and the transformation is only
/// run if is a [Right] value.
///
/// ```
/// final catcher = chainTryCatchK(
///   (int i) => i > 5 ? i : throw 'error',
///   (err, stack) => 'number too small',
/// );
///
/// expect(
///   right(10).chain(catcher),
///   right(10),
/// );
/// expect(
///   right(3).chain(catcher),
///   left('number too small'),
/// );
/// ```
Either<L, R2> Function(Either<L, R> value) chainTryCatchK<L, R, R2>(
  R2 Function(R right) f,
  L Function(dynamic error, StackTrace stack) onError,
) =>
    flatMap(tryCatchK(f, onError));

/// Recieves an [Either], and if it is a [Left] value replaces it with an
/// [alt]ernative [Either] determined by executing the `onLeft` callback.
///
/// ```
/// expect(
///   left('fail').chain(alt((s) => right('caught the $s'))),
///   right('caught the fail'),
/// );
/// expect(
///   right('yay').chain(alt((s) => right('caught the $s'))),
///   right('yay'),
/// );
/// ```
Either<L, R> Function(Either<L, R> either) alt<L, R>(
  Either<L, R> Function(L left) onLeft,
) =>
    fold(onLeft, right);

/// Maybe converts an [Either] to a [Left], determined by the given `predicate`.
///
/// ```
/// final greaterThanFiveFilter = filter(
///   (int i) => i > 5,
///   (i) => '$i is too small',
/// );
///
/// expect(
///   right(10).chain(greaterThanFiveFilter),
///   right(10),
/// );
/// expect(
///   right(3).chain(greaterThanFiveFilter),
///   left('3 is too small'),
/// );
/// ```
Either<L, R> Function(Either<L, R> either) filter<L, R>(
  bool Function(R right) predicate,
  L Function(R right) orElse,
) =>
    flatMap(fromPredicateK(predicate, orElse));

/// Unwraps an [Either]. If it is a [Right] value, then it returns the unwrapped
/// value. If it is a [Left], then the `onLeft` callback determines the fallback.
///
/// ```
/// expect(
///   right('hello').chain(getOrElse((left) => 'fallback')),
///   'hello',
/// );
/// expect(
///   left('fail').chain(getOrElse((left) => 'fallback')),
///   'fallback',
/// );
/// ```
R Function(Either<L, R> either) getOrElse<L, R>(
  R Function(L left) onLeft,
) =>
    fold(onLeft, identity);

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

/// Converts an [Option] into an [Either].
/// If the [Option] is [Some], then a [Right] is returned with the wrapped
/// value.
/// Otherwise, `onNone` will determine the [Left] value to return.
///
/// ```
/// expect(
///   O.some('hello').chain(fromOption(() => 'fail')),
///   right('hello'),
/// );
/// expect(
///   O.none().chain(fromOption(() => 'fail')),
///   left('fail'),
/// );
/// ```
Either<L, R> Function(Option<R> option) fromOption<L, R>(
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

/// A [fromNullable] variant that enforces the left and right types.
/// Useful for function composition.
///
/// ```
/// final transform = fromNullableWith<String, int>(() => 'number was missing')
///   .compose(map((i) => i * 2));
///
/// expect(transform(1), right(2));
/// expect(transform(null), left('number was missing'));
/// ```
Either<L, R> Function(R? value) fromNullableWith<L, R>(
  Lazy<L> orElse,
) =>
    (value) => fromNullable(value, orElse);

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

/// Transform an iterable of [Either], into an [Either] containing an [IList] of
/// the results.
Either<L, IList<R2>> Function(Iterable<R1>) traverse<L, R1, R2>(
  Either<L, R2> Function(R1 a) f,
) =>
    (as) => as.fold(
          right(IList()),
          (acc, a) => acc._fold(
            (_) => acc,
            (bs) => f(a)._fold(
              (l) => left(l),
              (b) => right(bs.add(b)),
            ),
          ),
        );

/// Transform an iterable of [Either], into an [Either] containing an [IList] of
/// the results.
Either<L, IList<R>> sequence<L, R>(
  Iterable<Either<L, R>> arr,
) =>
    arr.chain(traverse(identity));

/// Represents a value than can be one of two things - [Left] or [Right].
///
/// Commonly used for function results that can either be an error, or the
/// intended value.
abstract class Either<L, R> {
  const Either();

  bool get _isLeft;
  bool get _isRight;

  A _fold<A>(A Function(L left) ifLeft, A Function(R value) ifRight);
}

class Left<L, R> extends Either<L, R> {
  const Left(this.value);
  final L value;

  @override
  T _fold<T>(T Function(L left) ifLeft, T Function(R value) ifRight) =>
      ifLeft(value);

  @override
  final _isLeft = true;

  @override
  final _isRight = false;

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
  final _isLeft = false;

  @override
  final _isRight = true;

  @override
  String toString() => 'Right($value)';

  @override
  bool operator ==(other) => other is Right && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
