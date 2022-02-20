import 'dart:async';

import 'package:fpdt/fpdt.dart';
import 'package:fpdt/either.dart' as E;
import 'package:fpdt/reader.dart' as Rd;
import 'package:fpdt/reader_task.dart' as RT;
import 'package:fpdt/task_either.dart' as TE;

typedef ReaderTaskEither<R, E, A> = TaskEither<E, A> Function(R);

/// Projects a value from the global context in a [ReaderTaskEither].
ReaderTaskEither<R, E, R> ask<R, E>() => Rd.asks(TE.right);

/// Projects a value from the global context in a [ReaderTaskEither].
ReaderTaskEither<R, E, A> asks<R, E, A>(A Function(R r) f) =>
    (r) => TE.right(f(r));

/// Projects a [TE.right] value in a [ReaderTaskEither].
ReaderTaskEither<R, E, A> right<R, E, A>(A a) => Rd.of(TE.right(a));

/// Projects a [TE.left] value in a [ReaderTaskEither].
ReaderTaskEither<R, E, A> left<R, E, A>(E e) => Rd.of(TE.left(e));

Future<A> Function(R r) toFuture<R, A>(ReaderTaskEither<R, dynamic, A> f) =>
    (r) => f(r).chain(TE.fold(
          (l) => throw l,
          identity,
        ))();

/// Convert a [ReaderTaskEither] into a [Future<void>], that runs the side effect on
/// [Left].
Future<void> Function(C) Function(ReaderTaskEither<C, L, dynamic>)
    toFutureVoid<C, L>(
  void Function(L value) onLeft,
) =>
        (f) => (c) => f(c).chain(TE.fold(
              onLeft,
              (_) {},
            ))();

/// Replace the [ReaderTaskEither] with one that resolves to an [Right] containing
/// the given value.
ReaderTaskEither<C, L, R2> Function(ReaderTaskEither<C, L, R>)
    pure<C, L, R, R2>(R2 a) => (readerTaskEither) => right(a);

/// Create a [ReaderTaskEither] from an [Option]. If it is [None], then the
/// [ReaderTaskEither] will resolve to a [Left] containing the result from executing
/// `onNone`.
ReaderTaskEither<C, L, R> Function(Option<R> option) fromOption<C, L, R>(
  L Function(C) onNone,
) =>
    (o) => (c) => o.chain(TE.fromOption(() => onNone(c)));

/// Create a [TaskEither] from a nullable value. `onNone` is executed if the
/// given value is `null`.
ReaderTaskEither<C, L, R> fromNullable<C, L, R>(
  R? Function(C) value,
  L Function(C) onNone,
) =>
    (r) => TE.fromNullable(value(r), () => onNone(r));

/// Create a [TaskEither] from a nullable value. `onNone` is executed if the
/// value (given to the returned function) is `null`.
ReaderTaskEither<C, L, R> Function(A value) fromNullableK<C, A, L, R>(
  R? Function(A value) Function(C) f,
  L Function(A value) Function(C) onNone,
) =>
    (a) => fromNullable((r) => f(r)(a), (c) => onNone(c)(a));

/// Chainable variant of [fromNullableK].
ReaderTaskEither<C, L, R2> Function(
  ReaderTaskEither<C, L, R> taskEither,
) chainNullableK<C, L, R, R2>(
  R2? Function(R right) Function(C) f,
  L Function(R right) Function(C) onNone,
) =>
    flatMap(fromNullableK(f, onNone));

/// Returns a [ReaderTaskEither] that resolves to the given [Either].
ReaderTaskEither<C, L, R> fromEither<C, L, R>(Either<L, R> either) =>
    (r) => TE.fromEither(either);

/// Transforms a [Reader] into a [ReaderTaskEither], wrapping the result in an [Right].
ReaderTaskEither<C, L, R> fromReader<C, L, R>(Reader<C, R> f) =>
    (r) => TE.right(f(r));

/// Transforms a [ReaderTask] into a [ReaderTaskEither], wrapping the result in an [Right].
ReaderTaskEither<C, L, R> fromReaderTask<C, L, R>(ReaderTask<C, R> f) =>
    f.compose(TE.fromTask);

/// Transforms a [Task] into a [ReaderTaskEither], wrapping the result in an [Right].
ReaderTaskEither<C, L, R> fromTask<C, L, R>(Task<R> task) =>
    (r) => TE.fromTask(task);

/// Returns a [ReaderTaskEither] that resolves to the given [TaskEither].
ReaderTaskEither<C, L, R> fromTaskEither<C, L, R>(
        TaskEither<L, R> taskEither) =>
    (c) => taskEither;

/// Runs the given task, and returns the result as an [Right].
/// If it throws an error, the the error is passed to `onError`, which determines
/// the [Left] value.
ReaderTaskEither<C, L, R> tryCatch<C, L, R>(
  FutureOr<R> Function() task,
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
    (r) => () async {
          try {
            return E.right(await task());
          } catch (err, stack) {
            return E.left(onError(err, stack));
          }
        };

/// Unwraps the [Either] value, returning a [ReaderTask] that resolves to the
/// result.
///
/// `onRight` is run if the value is an [Right], and `onLeft` for [Left].
ReaderTask<R, B> Function(ReaderTaskEither<R, L, A>) fold<R, L, A, B>(
  B Function(L left) onLeft,
  B Function(A right) onRight,
) =>
    RT.map(E.fold(onLeft, onRight));

/// Composes computations in sequence, using the return value from the previous
/// computation.
ReaderTaskEither<C, L, R2> Function(ReaderTaskEither<C, L, R1>)
    map<C, L, R1, R2>(
  R2 Function(R1 a) f,
) =>
        RT.map(E.map(f));

/// Composes computations in sequence, using the return value from the previous
/// computation.
ReaderTaskEither<C, L, R2> Function(ReaderTaskEither<C, L, R1>)
    flatMap<C, L, R1, R2>(
  ReaderTaskEither<C, L, R2> Function(R1 a) f,
) =>
        RT.flatMap(E.fold(left, f));

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
ReaderTaskEither<C, L, R> Function(ReaderTaskEither<C, L, R> taskEither)
    filter<C, L, R>(
  bool Function(R value) predicate,
  L Function(R value) orElse,
) =>
        RT.map(E.filter(predicate, orElse));

/// If the given [ReaderTaskEither] is an [Left], then unwrap the result and transform
/// it into an [alt]ernative [ReaderTaskEither].
ReaderTaskEither<C, L, R> Function(ReaderTaskEither<C, L, R>) alt<C, L, R>(
  ReaderTaskEither<C, L, R> Function(L left) orElse,
) =>
    RT.flatMap(E.fold(orElse, right));

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
        RT.map(E.getOrElse(onLeft));

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
    RT.tap(E.fold(identity, f));

/// Pause execution of the task by the given [Duration].
ReaderTaskEither<C, L, R> Function(ReaderTaskEither<C, L, R>) delay<C, L, R>(
        Duration d) =>
    (f) => f.compose(TE.delay(d));

ReaderTaskEither<C, L, IList<R>> Function(Iterable<A>)
    traverseIterable<A, C, L, R>(
  ReaderTaskEither<C, L, R> Function(A a) f,
) =>
        (as) => (c) => as.map((a) => f(a)(c)).chain(TE.sequence);

ReaderTaskEither<C, L, IList<R>> Function(Iterable<A>)
    traverseIterableSeq<A, C, L, R>(
  ReaderTaskEither<C, L, R> Function(A a) f,
) =>
        (as) => (c) => as.map((a) => f(a)(c)).chain(TE.sequenceSeq);

ReaderTaskEither<C, L, IList<R>> sequence<C, L, R>(
        Iterable<ReaderTaskEither<C, L, R>> arr) =>
    arr.chain(traverseIterable(identity));

ReaderTaskEither<C, L, IList<R>> sequenceSeq<C, L, R>(
        Iterable<ReaderTaskEither<C, L, R>> arr) =>
    arr.chain(traverseIterableSeq(identity));
