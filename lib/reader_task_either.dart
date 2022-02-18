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
  FutureOr<R> Function(C) task,
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
    (r) => () async {
          try {
            return E.right(await task(r));
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
