import 'dart:async';

import 'package:fpdt/either.dart' as E;
import 'package:fpdt/fpdt.dart';
import 'package:fpdt/task_either.dart' as TE;
import 'package:fpdt/unit.dart' as U;

class ReaderTaskEither<R, E, A> implements Reader<R, TaskEither<E, A>> {
  final TaskEither<E, A> Function(R r) _task;
  ReaderTaskEither(this._task);
  @override
  TaskEither<E, A> call(R r) => _task(r);
}

/// Projects a value from the global context in a [ReaderTaskEither].
ReaderTaskEither<R, E, R> ask<R, E>() => ReaderTaskEither((r) => TE.right(r));

/// Projects a value from the global context in a [ReaderTaskEither].
ReaderTaskEither<R, E, A> asks<R, E, A>(A Function(R r) f) =>
    ReaderTaskEither((r) => TE.right(f(r)));

/// Projects a [TE.right] value in a [ReaderTaskEither].
ReaderTaskEither<R, E, A> right<R, E, A>(A a) =>
    ReaderTaskEither((r) => TE.right(a));

/// Projects a [TE.left] value in a [ReaderTaskEither].
ReaderTaskEither<R, E, A> left<R, E, A>(E e) =>
    ReaderTaskEither((r) => TE.left(e));

ReaderTaskEither<R, E, Unit> unit<R, E>() => right(U.unit);

Future<A> Function(R r) toFuture<R, E, A>(ReaderTaskEither<R, E, A> f) =>
    (r) => TE.toFuture(f(r));

/// Convert a [ReaderTaskEither] into a [Future<void>], that runs the side effect on
/// [Left].
Future<void> Function(C) Function(ReaderTaskEither<C, L, dynamic>)
    toFutureVoid<C, L>(
  void Function(L value) onLeft,
) =>
        (f) => (c) => f(c).p(TE.toFutureVoid(onLeft));

/// Replace the [ReaderTaskEither] with one that resolves to an [Right] containing
/// the given value.
ReaderTaskEither<C, L, R2> Function(ReaderTaskEither<C, L, R>)
    pure<C, L, R, R2>(R2 a) => (readerTaskEither) => right(a);

/// If the function returns true, then the resolved [Either] will be a [Right]
/// containing the given `value`.
///
/// If the function returns `false`, then the resolved [Either] will be a [Left]
/// containing the value returned from executing the `orElse` function.
ReaderTaskEither<C, L, R> fromPredicate<C, L, R>(
  R r,
  bool Function(R r) f,
  L Function(R r) orElse,
) =>
    fromEither(E.fromPredicate(r, f, orElse));

/// If the function returns true, then the resolved [Either] will be a [Right]
/// containing the given `value`.
///
/// If the function returns `false`, then the resolved [Either] will be a [Left]
/// containing the value returned from executing the `orElse` function.
ReaderTaskEither<C, L, R> Function(R r) fromPredicateK<C, L, R>(
  bool Function(R r) f,
  L Function(R r) orElse,
) =>
    (r) => fromPredicate(r, f, orElse);

/// Create a [ReaderTaskEither] from an [Option]. If it is [None], then the
/// [ReaderTaskEither] will resolve to a [Left] containing the result from executing
/// `onNone`.
ReaderTaskEither<C, L, R> Function(Option<R> option) fromOption<C, L, R>(
  L Function() onNone,
) =>
    (o) => ReaderTaskEither((c) => o.chain(TE.fromOption(onNone)));

/// Create a [TaskEither] from a nullable value. `onNone` is executed if the
/// given value is `null`.
ReaderTaskEither<C, L, R> fromNullable<C, L, R>(
  R? value,
  L Function() onNone,
) =>
    ReaderTaskEither((_) => TE.fromNullable(value, onNone));

/// Create a [TaskEither] from a nullable value. `onNone` is executed if the
/// value (given to the returned function) is `null`.
ReaderTaskEither<C, L, R> Function(A value) fromNullableK<C, L, R, A>(
  R? Function(A value) f,
  L Function(A value) onNone,
) =>
    (a) => fromNullable(f(a), () => onNone(a));

/// Chainable variant of [fromNullableK].
ReaderTaskEither<C, L, R2> Function(
  ReaderTaskEither<C, L, R> taskEither,
) chainNullableK<C, L, R, R2>(
  R2? Function(R right) f,
  L Function(R right) onNone,
) =>
    flatMap(fromNullableK(f, onNone));

/// Returns a [ReaderTaskEither] that resolves to the given [Either].
ReaderTaskEither<C, L, R> fromEither<C, L, R>(Either<L, R> either) =>
    ReaderTaskEither((r) => TE.fromEither(either));

/// Transforms a [Reader] into a [ReaderTaskEither], wrapping the result in an [Right].
ReaderTaskEither<C, L, R> fromReader<C, L, R>(Reader<C, R> f) =>
    ReaderTaskEither((r) => TE.right(f(r)));

/// Transforms a [ReaderTask] into a [ReaderTaskEither], wrapping the result in an [Right].
ReaderTaskEither<C, L, R> fromReaderTask<C, L, R>(ReaderTask<C, R> f) =>
    ReaderTaskEither(f.call.compose(TE.fromTask));

/// Transforms a [Task] into a [ReaderTaskEither], wrapping the result in an [Right].
ReaderTaskEither<C, L, R> fromTask<C, L, R>(Task<R> task) =>
    ReaderTaskEither((r) => TE.fromTask(task));

/// Returns a [ReaderTaskEither] that resolves to the given [TaskEither].
ReaderTaskEither<C, L, R> fromTaskEither<C, L, R>(
  TaskEither<L, R> taskEither,
) =>
    ReaderTaskEither((c) => taskEither);

/// Runs the given task, and returns the result as an [Right].
/// If it throws an error, the the error is passed to `onError`, which determines
/// the [Left] value.
ReaderTaskEither<C, L, R> tryCatch<C, L, R>(
  FutureOr<R> Function() task,
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
    ReaderTaskEither((r) => TE.tryCatch(task, onError));

/// Unwraps the [Either] value, returning a [ReaderTask] that resolves to the
/// result.
///
/// `onRight` is run if the value is an [Right], and `onLeft` for [Left].
ReaderTask<R, B> Function(ReaderTaskEither<R, L, A>) fold<R, L, A, B>(
  B Function(L left) onLeft,
  B Function(A right) onRight,
) =>
    (fa) => ReaderTask((r) => fa(r).p(TE.fold(onLeft, onRight)));

ReaderTaskEither<C, L, R2> Function(
  ReaderTaskEither<C, L, R1> task,
) zipRight<C, L, R1, R2>(
  ReaderTaskEither<C, L, R2> chain,
) =>
    flatMap((_) => chain);

ReaderTaskEither<C, L, R2> Function(
  ReaderTaskEither<C, L, R1> task,
) as<C, L, R1, R2>(
  R2 r2,
) =>
    zipRight(right(r2));

ReaderTaskEither<C, L, Unit> asUnit<C, L, R>(
  ReaderTaskEither<C, L, R> task,
) =>
    task.p(as(U.unit));

/// Composes computations in sequence, using the return value from the previous
/// computation.
ReaderTaskEither<C, L, R2> Function(
  ReaderTaskEither<C, L, R1>,
) map<C, L, R1, R2>(
  R2 Function(R1 a) f,
) =>
    (fa) => ReaderTaskEither(fa.call.compose(TE.map(f)));

/// Composes computations in sequence, using the return value from the previous
/// computation.
ReaderTaskEither<C, L2, R> Function(ReaderTaskEither<C, L1, R>)
    mapLeft<C, L1, L2, R>(
  L2 Function(L1 a) f,
) =>
        (fa) => ReaderTaskEither(fa.call.compose(TE.mapLeft(f)));

/// Composes computations in sequence, using the return value from the previous
/// computation.
ReaderTaskEither<C, L, R2> Function(ReaderTaskEither<C, L, R1>)
    flatMap<C, L, R1, R2>(
  ReaderTaskEither<C, L, R2> Function(R1 a) f,
) =>
        (fa) => ReaderTaskEither((r) => fa(r).p(TE.flatMap((a) => f(a)(r))));

/// A variant of [flatMap] that appends the result to a tuple.
ReaderTaskEither<C, L, Tuple2<R, R2>> Function(ReaderTaskEither<C, L, R> fa)
    flatMapTuple2<C, L, R, R2>(
  ReaderTaskEither<C, L, R2> Function(R value) f,
) =>
        flatMap((r) => f(r).p(map((r2) => tuple2(r, r2))));

/// A variant of [flatMap] that appends the result to a tuple.
ReaderTaskEither<C, L, Tuple3<R, R2, R3>> Function(
    ReaderTaskEither<C, L, Tuple2<R, R2>> fa) flatMapTuple3<C, L, R, R2, R3>(
  ReaderTaskEither<C, L, R3> Function(Tuple2<R, R2> a) f,
) =>
    flatMap((r) => f(r).p(map((r3) => tuple3(r.first, r.second, r3))));

ReaderTaskEither<C, L, R2> Function(ReaderTaskEither<C, L, R1>)
    flatMapReader<C, L, R1, R2>(
  Reader<C, R2> Function(R1 a) f,
) =>
        flatMap(f.compose(fromReader));

ReaderTaskEither<C, L, R2> Function(ReaderTaskEither<C, L, R1>)
    flatMapReaderTask<C, L, R1, R2>(
  ReaderTask<C, R2> Function(R1 a) f,
) =>
        flatMap(f.compose(fromReaderTask));

ReaderTaskEither<C, L, R2> Function(ReaderTaskEither<C, L, R1>)
    flatMapTask<C, L, R1, R2>(
  Task<R2> Function(R1 a) f,
) =>
        flatMap(f.compose(fromTask));

ReaderTaskEither<C, L, R2> Function(ReaderTaskEither<C, L, R1>)
    flatMapTaskEither<C, L, R1, R2>(
  TaskEither<L, R2> Function(R1 a) f,
) =>
        flatMap(f.compose(fromTaskEither));

ReaderTaskEither<C, L, R2> Function(ReaderTaskEither<C, L, R1>)
    flatMapEither<C, L, R1, R2>(
  Either<L, R2> Function(R1 a) f,
) =>
        flatMap(f.compose(fromEither));

ReaderTaskEither<C, L, B> Function(ReaderTaskEither<C, L, A>)
    flatMapOption<C, L, A, B>(
  Option<B> Function(A a) f,
  L Function(A a) onNone,
) =>
        flatMap((a) => f(a).p(fromOption(() => onNone(a))));

/// Composes computations in sequence, using the return value from the previous
/// computation. Discarding the result.
ReaderTaskEither<C, L, R> Function(ReaderTaskEither<C, L, R>)
    flatMapFirst<C, L, R>(
  ReaderTaskEither<C, L, dynamic> Function(R a) f,
) =>
        flatMap((r) => f(r).chain(map((_) => r)));

ReaderTaskEither<C, L, R> Function(ReaderTaskEither<C, L, R>)
    flatMapFirstTask<C, L, R>(
  Task<dynamic> Function(R a) f,
) =>
        flatMapFirst(f.compose(fromTask));

ReaderTaskEither<C, L, R> Function(ReaderTaskEither<C, L, R>)
    flatMapFirstTaskEither<C, L, R>(
  TaskEither<L, dynamic> Function(R a) f,
) =>
        flatMapFirst(f.compose(fromTaskEither));

ReaderTaskEither<C, L, R> Function(ReaderTaskEither<C, L, R>)
    flatMapFirstEither<C, L, R>(
  Either<L, dynamic> Function(R a) f,
) =>
        flatMapFirst(f.compose(fromEither));

/// Conditionally filter the [ReaderTaskEither], transforming [Right] values to [Left].
ReaderTaskEither<C, L, R> Function(
  ReaderTaskEither<C, L, R> taskEither,
) filter<C, L, R>(
  bool Function(R value) predicate,
  L Function(R value) orElse,
) =>
    (fa) => ReaderTaskEither((r) => fa(r).p(TE.filter(predicate, orElse)));

/// If the given [ReaderTaskEither] is an [Left], then unwrap the result and transform
/// it into an [alt]ernative [ReaderTaskEither].
ReaderTaskEither<C, L, R> Function(ReaderTaskEither<C, L, R>) alt<C, L, R>(
  ReaderTaskEither<C, L, R> Function(L left) orElse,
) =>
    (fa) => ReaderTaskEither((r) => fa(r).p(TE.alt((l) => orElse(l)(r))));

/// Similar to [alt], but the alternative [ReaderTaskEither] is given directly.
ReaderTaskEither<C, L, R> Function(ReaderTaskEither<C, L, R>) orElse<C, L, R>(
  ReaderTaskEither<C, L, R> orElse,
) =>
    alt((_) => orElse);

/// Unwrap the [Either] value. Resolves to the unwrapped [Right] value, but
/// if the [ReaderTaskEither] is an [Left], the `onLeft` callback determines the
/// fallback value.
ReaderTask<C, R> Function(ReaderTaskEither<C, L, R> taskEither)
    getOrElse<C, L, R>(
  R Function(L left) onLeft,
) =>
        (fa) => ReaderTask(fa.call.c(TE.getOrElse(onLeft)));

/// A variant of [tryCatch] that accepts an external parameter.
ReaderTaskEither<C, L, R> Function(A value) tryCatchK<C, A, L, R>(
  FutureOr<R> Function(A value) task,
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
    (a) => tryCatch(() => task(a), onError);

/// A variant of [tryCatch] that accepts two external parameters.
ReaderTaskEither<C, L, R> Function(A a, B b) tryCatchK2<A, B, C, L, R>(
  FutureOr<R> Function(A a, B b) task,
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
    (a, b) => tryCatch(() => task(a, b), onError);

/// A chainable variant of [tryCatchK].
ReaderTaskEither<C, L, R2> Function(ReaderTaskEither<C, L, R>)
    chainTryCatchK<C, L, R, R2>(
  FutureOr<R2> Function(R value) task,
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
        flatMap(tryCatchK(task, onError));

/// Run a side effect on a [Right] value. The side effect can optionally return
/// a [Future].
ReaderTaskEither<C, L, R> Function(ReaderTaskEither<C, L, R>) tap<C, L, R>(
  FutureOr<void> Function(R value) f,
) =>
    (fa) => ReaderTaskEither(fa.call.compose(TE.tap(f)));

/// Run a side effect on a [Left] value. The side effect can optionally return
/// a [Future].
ReaderTaskEither<C, L, R> Function(ReaderTaskEither<C, L, R>) tapLeft<C, L, R>(
  FutureOr<void> Function(L value) f,
) =>
    (fa) => ReaderTaskEither(fa.call.compose(TE.tapLeft(f)));

/// Pause execution of the task by the given [Duration].
ReaderTaskEither<C, L, R> Function(ReaderTaskEither<C, L, R>) delay<C, L, R>(
  Duration d,
) =>
    (fa) => ReaderTaskEither(fa.call.compose(TE.delay(d)));

ReaderTaskEither<C, L, IList<R>> Function(
    Iterable<A>) traverseIterable<A, C, L, R>(
  ReaderTaskEither<C, L, R> Function(A a) f,
) =>
    (as) => ReaderTaskEither((c) => as.map((a) => f(a)(c)).chain(TE.sequence));

ReaderTaskEither<C, L, IList<R>> Function(
    Iterable<A>) traverseIterableSeq<A, C, L, R>(
  ReaderTaskEither<C, L, R> Function(A a) f,
) =>
    (as) =>
        ReaderTaskEither((c) => as.map((a) => f(a)(c)).chain(TE.sequenceSeq));

ReaderTaskEither<C, L, IList<R>> sequence<C, L, R>(
  Iterable<ReaderTaskEither<C, L, R>> arr,
) =>
    arr.chain(traverseIterable(identity));

ReaderTaskEither<C, L, IList<R>> sequenceSeq<C, L, R>(
  Iterable<ReaderTaskEither<C, L, R>> arr,
) =>
    arr.chain(traverseIterableSeq(identity));

typedef _DoAdapter<C, L> = FutureOr<R> Function<R>(ReaderTaskEither<C, L, R>);

_DoAdapter<C, L> _doAdapter<C, L>(C c) => <R>(task) => task(c)().flatMap(E.fold(
      (l) => Future.error(Left(l)),
      (a) => a,
    ));

typedef DoFunction<C, L, R> = Future<R> Function(
  _DoAdapter<C, L> $,
  C context,
);

// ignore: non_constant_identifier_names
ReaderTaskEither<C, L, R> Do<C, L, R>(DoFunction<C, L, R> f) =>
    ReaderTaskEither(
      (c) => TaskEither(
        Task(
          () => f(_doAdapter<C, L>(c), c).then(
            (a) => E.right(a),
            onError: (e) => E.left<L, R>(e.value),
          ),
        ),
      ),
    );
