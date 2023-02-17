import 'dart:async';

import 'package:fpdt/either.dart' as either;
import 'package:fpdt/fpdt.dart';
import 'package:fpdt/future_or.dart';
import 'package:fpdt/option.dart' as option;
import 'package:fpdt/task.dart' as task;
import 'package:fpdt/unit.dart' as U;

/// Represents a [Task] that resolves to an [Either].
/// The underlying type is a [Function] that returns a [FutureOr<Either>].
class TaskEither<L, R> implements Task<Either<L, R>> {
  final Task<Either<L, R>> _task;
  TaskEither(this._task);
  @override
  FutureOr<Either<L, R>> call() => _task();
}

/// Create a [TaskEither] that resolves to an [Right].
TaskEither<L, R> right<L, R>(R a) =>
    TaskEither(task.value(either.right<L, R>(a)));

/// Create a [TaskEither] that resolves to an [Left].
TaskEither<L, R> left<L, R>(L a) =>
    TaskEither(task.value(either.left<L, R>(a)));

TaskEither<L, Unit> unit<L>() => right(U.unit);

/// Convert a [TaskEither] into a [Future], that throws an error on [Left].
Future<R> toFuture<L, R>(TaskEither<L, R> taskEither) =>
    Future.sync(taskEither.call).then(either.fold(
      (_) => Future.error(_ as dynamic),
      identity,
    ));

/// Convert a [TaskEither] into a [Future<void>], that runs the side effect on
/// [Left].
Future<void> Function(TaskEither<L, dynamic> taskEither) toFutureVoid<L>(
  void Function(L value) onLeft,
) =>
    (te) => Future.sync(te.chain(fold(onLeft, (_) {})).call);

/// Replace the [TaskEither] with one that resolves to an [Right] containing
/// the given value.
TaskEither<L, R2> Function(TaskEither<L, R> taskEither) pure<L, R, R2>(R2 a) =>
    (taskEither) => right(a);

/// If the function returns true, then the resolved [Either] will be a [Right]
/// containing the given `value`.
///
/// If the function returns `false`, then the resolved [Either] will be a [Left]
/// containing the value returned from executing the `orElse` function.
TaskEither<L, R> fromPredicate<L, R>(
  R r,
  bool Function(R r) f,
  L Function(R r) orElse,
) =>
    fromEither(either.fromPredicate(r, f, orElse));

/// If the function returns true, then the resolved [Either] will be a [Right]
/// containing the given `value`.
///
/// If the function returns `false`, then the resolved [Either] will be a [Left]
/// containing the value returned from executing the `orElse` function.
TaskEither<L, R> Function(R r) fromPredicateK<L, R>(
  bool Function(R r) f,
  L Function(R r) orElse,
) =>
    (r) => fromPredicate(r, f, orElse);

/// Create a [TaskEither] from an [Option]. If it is [None], then the
/// [TaskEither] will resolve to a [Left] containing the result from executing
/// `onNone`.
TaskEither<L, R> Function(Option<R> option) fromOption<L, R>(
  L Function() onNone,
) =>
    either.fromOption<L, R>(onNone).compose(fromEither);

/// Create a [TaskEither] from a nullable value. `onNone` is executed if the
/// given value is `null`.
TaskEither<L, R> fromNullable<L, R>(
  R? value,
  L Function() onNone,
) =>
    option.fromNullable(value).chain(fromOption(onNone));

/// Create a [TaskEither] from a nullable value. `onNone` is executed if the
/// value (given to the returned function) is `null`.
TaskEither<L, R> Function(A value) fromNullableK<A, L, R>(
  R? Function(A value) f,
  L Function(A value) onNone,
) =>
    (a) => fromNullable(f(a), () => onNone(a));

/// Chainable variant of [fromNullableK].
TaskEither<L, R2> Function(
  TaskEither<L, R> taskEither,
) chainNullableK<L, R, R2>(
  R2? Function(R right) f,
  L Function(R right) onNone,
) =>
    flatMap(fromNullableK(f, onNone));

/// Returns a [TaskEither] that resolves to the given [Either].
///
/// ```
/// expect(
///   await fromEither(E.right('hello'))(),
///   E.right('hello'),
/// );
/// ```
TaskEither<L, R> fromEither<L, R>(Either<L, R> either) =>
    TaskEither(task.value(either));

/// Runs the given task, and returns the result as an [Right].
/// If it throws an error, the the error is passed to `onError`, which determines
/// the [Left] value.
///
/// ```
/// expect(
///   await tryCatch(() => 'hello', (err, stack) => 'fail')(),
///   E.right('hello'),
/// );
/// expect(
///   await tryCatch(() => throw 'error', (err, stack) => 'fail')(),
///   E.left('fail'),
/// );
/// ```
TaskEither<L, R> tryCatch<L, R>(
  Lazy<FutureOr<R>> task,
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
    TaskEither(Task(() => fromThrowable(
          task,
          onSuccess: either.right,
          onError: (err, stack) => either.left<L, R>(onError(err, stack)),
        )));

/// Transforms a [Task] into a [TaskEither], wrapping the result in an [Right].
///
/// ```
/// expect(
///   await fromTask(T.value('hello'))(),
///   E.right('hello'),
/// );
/// ```
TaskEither<L, R> fromTask<L, R>(Task<R> fa) =>
    TaskEither(Task(() => fa().flatMap(either.right)));

/// Unwraps the [Either] value, returning a [Task] that resolves to the
/// result.
///
/// `onRight` is run if the value is an [Right], and `onLeft` for [Left].
///
/// ```
/// expect(
///   await right('hello').chain(fold(
///     (left) => 'left value',
///     (right) => 'right value',
///   ))(),
///   'right value',
/// );
/// expect(
///   await left('fail').chain(fold(
///     (left) => 'left value',
///     (right) => 'right value',
///   ))(),
///   'left value',
/// );
/// ```
Task<A> Function(TaskEither<L, R> taskEither) fold<L, R, A>(
  A Function(L left) onLeft,
  A Function(R right) onRight,
) =>
    task.map(either.fold(onLeft, onRight));

/// If the given [TaskEither] is an [Right], then unwrap the result and transform
/// it into another [TaskEither].
///
/// ```
/// expect(
///   await right(123).chain(flatMap((i) => right('got: $i')))(),
///   E.right('got: 123'),
/// );
/// expect(
///   await right(123).chain(flatMap((i) => left('fail')))(),
///   E.left('fail'),
/// );
/// ```
TaskEither<L, R2> Function(TaskEither<L, R> taskEither) flatMap<L, R, R2>(
  TaskEither<L, R2> Function(R value) f,
) =>
    (fa) => TaskEither(
          fa.p(task.flatMap(either.fold((_) => left<L, R2>(_), f))),
        );

TaskEither<E, Tuple2<A, B>> Function(TaskEither<E, A>) flatMapTuple2<E, A, B>(
        TaskEither<E, B> Function(A a) f) =>
    flatMap((a) => f(a).p(map((b) => tuple2(a, b))));

TaskEither<E, Tuple3<A, B, C>> Function(TaskEither<E, Tuple2<A, B>>)
    flatMapTuple3<E, A, B, C>(TaskEither<E, C> Function(Tuple2<A, B> a) f) =>
        flatMap((a) => f(a).p(map((c) => tuple3(a.first, a.second, c))));

TaskEither<L, R2> Function(TaskEither<L, R1> task) call<L, R1, R2>(
  TaskEither<L, R2> chain,
) =>
    flatMap((_) => chain);

TaskEither<L, R2> Function(TaskEither<L, R1> task) zipRight<L, R1, R2>(
  TaskEither<L, R2> chain,
) =>
    (fa) => TaskEither(fa.p(task.call(chain)));

TaskEither<L, R2> Function(TaskEither<L, R1> task) as<L, R1, R2>(
  R2 r2,
) =>
    zipRight(right(r2));

TaskEither<L, Unit> asUnit<L, R>(TaskEither<L, R> task) => task.p(as(U.unit));

/// If the given [TaskEither] is an [Right], then unwrap the result and transform
/// it into another [TaskEither] - but only keep [Left] results.
///
/// ```
/// expect(
///   await right(123).chain(flatMapFirst((i) => right('got: $i')))(),
///   E.right(123),
/// );
/// expect(
///   await right(123).chain(flatMapFirst((i) => left('fail')))(),
///   E.left('fail'),
/// );
/// ```
TaskEither<L, R> Function(TaskEither<L, R> taskEither) flatMapFirst<L, R>(
  TaskEither<L, dynamic> Function(R value) f,
) =>
    flatMap((r) => f(r).chain(map((_) => r)));

/// If the given [TaskEither] is an [Left], then unwrap the result and transform
/// it into an [alt]ernative [TaskEither].
///
/// ```
/// expect(
///   await right(123).chain(flatMap((i) => right('got: $i')))(),
///   E.right('got: 123'),
/// );
/// expect(
///   await right(123).chain(flatMap((i) => left('fail')))(),
///   E.left('fail'),
/// );
/// ```
TaskEither<L, R> Function(TaskEither<L, R> taskEither) alt<L, R>(
  TaskEither<L, R> Function(L left) orElse,
) =>
    (fa) => TaskEither(
          fa.p(task.flatMap(either.fold(orElse, (_) => right<L, R>(_)))),
        );

/// Similar to [alt], but the alternative [TaskEither] is given directly.
TaskEither<L, R> Function(TaskEither<L, R> taskEither) orElse<L, R>(
  TaskEither<L, R> orElse,
) =>
    alt((_) => orElse);

/// Unwrap the [Either] value. Resolves to the unwrapped [Right] value, but
/// if the [TaskEither] is an [Left], the `onLeft` callback determines the
/// fallback value.
///
/// ```
/// expect(
///   await right('hello').chain(getOrElse(() => 'fallback'))(),
///   'hello',
/// );
/// expect(
///   await left('fail').chain(getOrElse(() => 'fallback'))(),
///   'fallback',
/// );
/// ```
Task<R> Function(TaskEither<L, R> taskEither) getOrElse<L, R>(
  R Function(L left) onLeft,
) =>
    task.map(either.getOrElse(onLeft));

/// A variant of [tryCatch] that accepts an external parameter.
///
/// ```
/// final readFile = tryCatchK(
///   (File file) => file.read(),
///   (err, stack) => 'Failed to read file',
/// );
///
/// expect(
///   await readFile(File('exists.txt')),
///   right('contents'),
/// );
/// expect(
///   await readFile(File('does not exist.txt')),
///   left('Failed to read file'),
/// );
/// ```
TaskEither<L, R> Function(A value) tryCatchK<A, L, R>(
  FutureOr<R> Function(A value) task,
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
    (a) => tryCatch(() => task(a), onError);

/// A variant of [tryCatch] that accepts two external parameters.
///
/// ```
/// final readFileChunk = tryCatchK2(
///   (File file, int bytes) => file.read(bytes),
///   (err, stack) => 'Failed to read file',
/// );
///
/// expect(
///   await readFileChunk(File('exists.txt'), 5),
///   right('hello'),
/// );
/// expect(
///   await readFileChunk(File('does not exist.txt'), 5),
///   left('Failed to read file'),
/// );
/// ```
TaskEither<L, R> Function(A a, B b) tryCatchK2<A, B, L, R>(
  FutureOr<R> Function(A a, B b) task,
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
    (a, b) => tryCatch(() => task(a, b), onError);

/// A chainable variant of [tryCatchK].
///
/// ```
/// expect(
///   await right('hello').chain(chainTryCatchK(
///     (s) => '$s world',
///     (err, stack) => 'fail',
///   ))(),
///   E.right('hello world'),
/// );
/// expect(
///   await right('hello').chain(chainTryCatchK(
///     (s) => throw 'error',
///     (err, stack) => 'fail',
///   ))(),
///   E.left('fail'),
/// );
/// ```
TaskEither<L, R2> Function(
  TaskEither<L, R> taskEither,
) chainTryCatchK<L, R, R2>(
  FutureOr<R2> Function(R value) task,
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
    flatMap(tryCatchK(task, onError));

/// Transform a [TaskEither]'s value if it is [Right].
///
/// ```
/// expect(
///   await right('hello').chain(map((s) => '$s world'))(),
///   E.right('hello world'),
/// );
/// expect(
///   await left('fail').chain(map((s) => '$s world'))(),
///   E.left('fail'),
/// );
/// ```
TaskEither<L, R2> Function(TaskEither<L, R> taskEither) map<L, R, R2>(
  R2 Function(R value) f,
) =>
    (fa) => TaskEither(fa.p(task.map(either.map(f))));

/// Transform a [TaskEither]'s value if it is [Left].
///
/// ```
/// expect(
///   await left('fail').chain(mapLeft((s) => '${s}ure'))(),
///   E.left('failure'),
/// );
/// ```
TaskEither<L2, R> Function(TaskEither<L1, R> taskEither) mapLeft<L1, L2, R>(
  L2 Function(L1 value) f,
) =>
    (fa) => TaskEither(fa.p(task.map(either.mapLeft(f))));

/// Run a side effect on a [Right] value. The side effect can optionally return
/// a [Future].
TaskEither<L, R> Function(TaskEither<L, R> taskEither) tap<L, R>(
  FutureOr<void> Function(R value) f,
) =>
    (fa) => TaskEither(fa.p(task.tap(either.fold(identity, f))));

/// Run a side effect on a [Left] value. The side effect can optionally return
/// a [Future].
TaskEither<L, R> Function(TaskEither<L, R> taskEither) tapLeft<L, R>(
  FutureOr<void> Function(L value) f,
) =>
    (fa) => TaskEither(fa.p(task.tap(either.fold(f, identity))));

/// Conditionally filter the [TaskEither], transforming [Right] values to [Left].
///
/// ```
/// expect(
///   await right('hello').chain(filter(
///     (s) => s == 'hello',
///     (s) => '$s was not hello',
///   ))(),
///   E.right('hello'),
/// );
/// expect(
///   await right('asdf').chain(filter(
///     (s) => s == 'hello',
///     (s) => '$s was not hello',
///   ))(),
///   E.left('asdf was not hello'),
/// );
/// ```
TaskEither<L, R> Function(TaskEither<L, R> taskEither) filter<L, R>(
  bool Function(R value) predicate,
  L Function(R value) orElse,
) =>
    (fa) => TaskEither(fa.p(task.map(either.filter(predicate, orElse))));

TaskEither<L, IList<B>> Function(Iterable<A>) traverseIterable<L, A, B>(
  TaskEither<L, B> Function(A a) f,
) =>
    (as) => TaskEither(
        as.p(task.traverseIterable(f)).p(task.map(either.traverse(identity))));

TaskEither<L, IList<B>> Function(Iterable<A>) traverseIterableSeq<L, A, B>(
  TaskEither<L, B> Function(A a) f,
) =>
    (as) => TaskEither(Task(() => as.fold<FutureOr<Either<L, IList<B>>>>(
          either.right(IList()),
          (acc, a) => acc.flatMap(
            (eb) => eb.chain(
              either.fold(
                (_) => acc,
                (bs) => f(a)().flatMap(either.fold(
                  (l) => either.left(l),
                  (b) => either.right(bs.add(b)),
                )),
              ),
            ),
          ),
        )));

TaskEither<L, IList<A>> sequence<L, A>(
  Iterable<TaskEither<L, A>> arr,
) =>
    arr.chain(traverseIterable(identity));

TaskEither<L, IList<A>> sequenceSeq<L, A>(
  Iterable<TaskEither<L, A>> arr,
) =>
    arr.chain(traverseIterableSeq(identity));

/// Pause execution of the task by the given [Duration].
TaskEither<L, R> Function(TaskEither<L, R>) delay<L, R>(Duration d) =>
    (fa) => TaskEither(fa.p(task.delay(d)));

typedef _DoAdapter<E> = FutureOr<A> Function<A>(TaskEither<E, A>);

_DoAdapter<L> _doAdapter<L>() => <A>(task) => task().flatMap(either.fold(
      (l) => Future.error(Left(l)),
      identity,
    ));

typedef DoFunction<L, A> = Future<A> Function(_DoAdapter<L> $);

// ignore: non_constant_identifier_names
TaskEither<L, A> Do<L, A>(DoFunction<L, A> f) =>
    TaskEither(Task(() => f(_doAdapter<L>()).then(
          (a) => either.right(a),
          onError: (e) => either.left<L, A>(e.value),
        )));
