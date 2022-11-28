import 'dart:async';

import 'package:fpdt/fpdt.dart';
import 'package:fpdt/option.dart' as O;
import 'package:fpdt/task.dart' as T;

export 'package:fpdt/task.dart' show delay, sequence, sequenceSeq;

/// Represents a [Task] that resolves to an [Option].
/// Useful for creating async operations that might return nothing.
///
/// Can also be represented by `Task<Option<A>>`.
typedef TaskOption<A> = Future<Option<A>> Function();

/// Returns a [TaskOption] that resolves to [Some].
TaskOption<A> some<A>(A a) => T.value(O.some(a));

/// Returns a [TaskOption] that resolves to [None].
TaskOption<A> none<A>() => T.value(O.none());

/// Create a [TaskOption] from a value that could be `null`. If it is not `null`,
/// then it will resolve to [Some]. `null` values become [None].
///
/// ```
/// expect(
///   await fromNullable('hello')(),
///   O.some('hello'),
/// );
/// expect(
///   await fromNullable(null)(),
///   O.none(),
/// );
/// ```
TaskOption<A> fromNullable<A>(A? a) => T.value(O.fromNullable(a));

/// A [fromNullable] variant that enforces the input type.
/// Useful for function composition.
TaskOption<A> Function(A? value) fromNullableWith<A>() => fromNullable;

/// A chainable [fromNullable] variant that flattens nullable values into an
/// [Option].
///
/// ```
/// expect(
///   await some('hello').chain(chainNullable)(),
///   O.some('hello'),
/// );
/// expect(
///   await some(null).chain(chainNullable)(),
///   O.none(),
/// );
/// ```
TaskOption<A> chainNullable<A>(TaskOption<A?> taskOption) =>
    taskOption.chain(flatMap(fromNullable));

/// A [fromNullable] variant that allows for external values to be passed in.
///
/// ```
/// final greaterThanFive = fromNullableK((int i) => i > 5 ? i : null);
/// expect(
///   await greaterThanFive(10)(),
///   O.some(10),
/// );
/// expect(
///   await greaterThanFive(3)(),
///   O.none(),
/// );
/// ```
TaskOption<B> Function(A value) fromNullableK<A, B>(B? Function(A a) f) =>
    (a) => fromNullable(f(a));

/// A chainable [fromNullable] variant that transforms the given [TaskOption]
/// into a nullable value, then flattens the result.
///
/// ```
/// expect(
///   await some('hello').chain(chainNullableK((s) => '$s world'))(),
///   O.some('hello world'),
/// );
/// expect(
///   await some('hello').chain(chainNullableK((s) => null))(),
///   O.none(),
/// );
/// ```
TaskOption<B> Function(TaskOption<A> value) chainNullableK<A, B>(
  B? Function(A a) f,
) =>
    flatMap(fromNullableK(f));

/// Replaces the [TaskOption] with one that resolves to a [Some] wrapping the
/// given value.
///
/// ```
/// expect(
///   await some(123).chain(pure('hello'))(),
///   O.some('hello'),
/// );
/// ```
TaskOption<B> Function(TaskOption<A> taskOption) pure<A, B>(B b) =>
    (taskOption) => some(b);

/// Returns a [TaskOption] that resolves to the given [Option].
TaskOption<A> fromOption<A>(Option<A> option) => T.value(option);

/// Returns a [Some] or [None] if the predicate returns `true` or `false`
/// respectively.
TaskOption<A> fromPredicate<A>(
  A value,
  bool Function(A value) predicate,
) =>
    T.value(O.fromPredicate(value, predicate));

/// Returns a [Some] or [None] if the predicate returns `true` or `false`
/// respectively.
TaskOption<A> Function(A a) fromPredicateK<A>(
  bool Function(A value) predicate,
) =>
    (a) => fromPredicate(a, predicate);

/// Returns a [TaskOption] that resolves to an [Option] from the given [Either].
/// [Left] values become [None], [Right] values are wrapped in [Some].
TaskOption<R> fromEither<L, R>(Either<L, R> either) =>
    T.value(O.fromEither(either));

/// Wraps the value from a [Task] in a [Some].
TaskOption<A> fromTask<A>(Task<A> task) => task.chain(T.map(O.some));

/// Transforms the [TaskOption] into a [Task], using the given `onNone` and `onSome`
/// callbacks.
///
/// ```
/// expect(
///   await some('hello').chain(fold(
///     () => 'none',
///     (s) => '$s world',
///   ))(),
///   'hello world',
/// );
/// expect(
///   await none().chain(fold(
///     () => 'none',
///     (s) => '$s world',
///   ))(),
///   'none',
/// );
/// ```
Task<B> Function(TaskOption<A> taskOption) fold<A, B>(
  B Function() onNone,
  B Function(A value) onSome,
) =>
    T.map(O.fold(onNone, onSome));

/// Runs the given task, and wraps the result with [Some].
/// If it throws and error, it will return [None].
///
/// ```
/// expect(
///   await tryCatch(() async => 'hello')(),
///   O.some('hello'),
/// );
/// expect(
///   await tryCatch(() async => throw 'fail')(),
///   O.none(),
/// );
/// ```
TaskOption<A> tryCatch<A>(Lazy<FutureOr<A>> task) =>
    () => Future.sync(task).then(
          O.some,
          onError: (err, stack) => kNone,
        );

/// Transform the given [TaskOption] into a new [TaskOption], if it resolves to
/// a [Some] value.
///
/// ```
/// expect(
///   await some(123).chain(flatMap((i) => some('got: $i')))(),
///   O.some('got: 123'),
/// );
/// // Transform into a [None] [TaskOption].
/// expect(
///   await some(123).chain(flatMap((i) => none()))(),
///   O.none(),
/// );
/// // Does nothing for [None] values.
/// expect(
///   await none().chain(flatMap((i) => some('got: $i')))(),
///   O.none(),
/// );
/// ```
TaskOption<B> Function(TaskOption<A> taskOption) flatMap<A, B>(
  TaskOption<B> Function(A value) f,
) =>
    T.flatMap(O.fold(none, f));

/// A variant of [flatMap] that appends the result to a tuple.
TaskOption<Tuple2<A, A2>> Function(TaskOption<A> o) flatMapTuple2<A, A2>(
  TaskOption<A2> Function(A a) f,
) =>
    flatMap((a) => f(a).p(map((b) => tuple2(a, b))));

/// A variant of [flatMap] that appends the result to a tuple.
TaskOption<Tuple3<A, A2, A3>> Function(TaskOption<Tuple2<A, A2>> o)
    flatMapTuple3<A, A2, A3>(
  TaskOption<A3> Function(Tuple2<A, A2> a) f,
) =>
        flatMap((a) => f(a).p(map((a3) => tuple3(a.first, a.second, a3))));

TaskOption<B> Function(TaskOption<A> taskOption) flatMapTask<A, B>(
  Task<B> Function(A value) f,
) =>
    flatMap((a) => fromTask(f(a)));

/// Similar to [flatMap], except [Some] values are discarded.
///
/// expect(
///   await some(123).chain(flatMapFirst((i) => some('got: $i')))(),
///   O.some(123),
/// );
/// expect(
///   await some(123).chain(flatMapFirst((i) => none()))(),
///   O.none(),
/// );
/// ```
TaskOption<A> Function(TaskOption<A> taskOption) flatMapFirst<A>(
  TaskOption<dynamic> Function(A value) f,
) =>
    flatMap((r) => f(r).chain(map((_) => r)));

/// If the [TaskOption] resolves to [None], then the [alt]ernative [TaskOption]
/// will be used.
///
/// The inverse of [flatMap].
///
/// ```
/// expect(
///   await none().chain(alt(() => some('hello')))(),
///   O.some('hello'),
/// );
/// ```
TaskOption<A> Function(TaskOption<A> taskOption) alt<A>(
  TaskOption<A> Function() onNone,
) =>
    T.flatMap(O.fold(onNone, some));

/// A variant of [alt], which accepts the replacement [TaskOption] directly.
TaskOption<A> Function(TaskOption<A> taskOption) orElse<A>(
  TaskOption<A> task,
) =>
    alt(() => task);

/// Transforms the [TaskOption] into a [Task], by unwrapping the [Some] value or
/// using the `orElse` value if it resolves to [None].
///
/// ```
/// expect(
///   await some('hello').chain(getOrElse(() => 'fallback'))(),
///   'hello',
/// );
/// expect(
///   await none().chain(getOrElse(() => 'fallback'))(),
///   'fallback',
/// );
/// ```
Task<A> Function(TaskOption<A> taskOption) getOrElse<A>(
  A Function() orElse,
) =>
    T.map(O.getOrElse(orElse));

/// A variant of [tryCatch], that allows external values to be passed in.
///
/// ```
/// final catcher = tryCatchK((int i) => i > 5 ? i : throw 'too small!');
///
/// expect(
///   await catcher(10)(),
///   O.some(10),
/// );
/// expect(
///   await catcher(3)(),
///   O.none(),
/// );
/// ```
TaskOption<B> Function(A value) tryCatchK<A, B>(
  FutureOr<B> Function(A value) task,
) =>
    (a) => tryCatch(() => task(a));

/// A chainable variant of [tryCatchK], that unwraps the given [TaskOption].
///
/// ```
/// final catcher = chainTryCatchK((int i) => i > 5 ? i : throw 'too small!');
///
/// expect(
///   await some(10).chain(catcher)(),
///   O.some(10),
/// );
/// expect(
///   await some(3).chain(catcher)(),
///   O.none(),
/// );
/// ```
TaskOption<B> Function(TaskOption<A> taskOption) chainTryCatchK<A, B>(
  FutureOr<B> Function(A value) task,
) =>
    flatMap(tryCatchK(task));

/// Transforms a [TaskOption] value if it resolves to [Some].
TaskOption<B> Function(TaskOption<A> taskOption) map<A, B>(
  B Function(A value) f,
) =>
    T.map(O.map(f));

/// Perform a side effect if the [TaskOption] is a [Some].
TaskOption<A> Function(TaskOption<A> taskOption) tap<A>(
  FutureOr<void> Function(A value) f,
) =>
    T.tap(O.fold(() {}, f));

/// Conditionally transform the [TaskOption] to a [None], using the given
/// predicate.
///
/// ```
/// expect(
///   await some(10).chain(filter((i) => i > 5))(),
///   O.some(10),
/// );
/// expect(
///   await some(3).chain(filter((i) => i > 5))(),
///   O.none(),
/// );
/// ```
TaskOption<A> Function(TaskOption<A> taskOption) filter<A>(
  bool Function(A value) predicate,
) =>
    T.map(O.filter(predicate));

typedef _DoAdapter = Future<A> Function<A>(TaskOption<A>);

Future<A> _doAdapter<A>(TaskOption<A> task) => task().then(O.fold(
      () => throw kNone,
      (a) => a,
    ));

typedef DoFunction<A> = Future<A> Function(_DoAdapter $);

// ignore: non_constant_identifier_names
TaskOption<A> Do<A>(DoFunction<A> f) => () => f(_doAdapter).then(
      O.some,
      onError: (_) => kNone,
    );
