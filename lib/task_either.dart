import 'dart:async';

import 'package:fpdt/either.dart' as E;
import 'package:fpdt/function.dart';
import 'package:fpdt/option.dart' as O;
import 'package:fpdt/task.dart' as T;

export 'package:fpdt/task.dart' show tap, delay, sequence, sequenceSeq;

/// Represents a [T.Task] that resolves to an [E.Either].
/// The underlying type is a [Function] that returns a [Future<E.Either>].
typedef TaskEither<L, R> = Future<E.Either<L, R>> Function();

/// Create a [TaskEither] that resolves to an [E.Right].
TaskEither<L, R> right<L, R>(R a) => () => Future.value(E.right(a));

/// Create a [TaskEither] that resolves to an [E.Left].
TaskEither<L, R> left<L, R>(L a) => () => Future.value(E.left(a));

/// Convert a [TaskEither] into a [Future], that throws an error on [E.Left].
Future<R> toFuture<R>(TaskEither<dynamic, R> taskEither) =>
    taskEither.chain(fold(
      (l) => throw l,
      identity,
    ))();

/// Convert a [TaskEither] into a [Future<void>], that runs the side effect on
/// [E.Left].
Future<void> Function(TaskEither<L, dynamic> taskEither) toFutureVoid<L>(
  void Function(L value) onLeft,
) =>
    (te) => te.chain(fold(
          onLeft,
          (_) {},
        ))();

/// Replace the [TaskEither] with one that resolves to an [E.Right] containing
/// the given value.
TaskEither<L, R2> Function(TaskEither<L, R> taskEither) pure<L, R, R2>(R2 a) =>
    (taskEither) => right(a);

/// Create a [TaskEither] from an [O.Option]. If it is [O.None], then the
/// [TaskEither] will resolve to a [E.Left] containing the result from executing
/// `onNone`.
TaskEither<L, R> Function(O.Option<R> option) fromOption<L, R>(
  L Function() onNone,
) =>
    E.fromOption<L, R>(onNone).compose(fromEither);

/// Create a [TaskEither] from a nullable value. `onNone` is executed if the
/// given value is `null`.
TaskEither<L, R> fromNullable<L, R>(
  R? value,
  L Function() onNone,
) =>
    O.fromNullable(value).chain(fromOption(onNone));

/// Create a [TaskEither] from a nullable value. `onNone` is executed if the
/// value (given to the returned function) is `null`.
TaskEither<L, R> Function(R? value) fromNullableK<L, R>(
  L Function() onNone,
) =>
    (r) => fromNullable(r, onNone);

/// Chainable variant of [fromNullableK].
TaskEither<L, R> Function(TaskEither<L, R?> value) chainNullableK<L, R>(
  L Function() onNone,
) =>
    flatMap(fromNullableK(onNone));

TaskEither<L, R> fromEither<L, R>(E.Either<L, R> either) =>
    () => Future.value(either);

TaskEither<L, R> tryCatch<L, R>(
  Lazy<FutureOr<R>> task,
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
    () async {
      try {
        return E.right(await task());
      } catch (err, stack) {
        return E.left(onError(err, stack));
      }
    };

TaskEither<L, R> Function(Lazy<FutureOr<R>> task) fromTask<L, R>(
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
    (task) => tryCatch(task, onError);

T.Task<A> Function(TaskEither<L, R> taskEither) fold<L, R, A>(
  A Function(L left) onLeft,
  A Function(R right) onRight,
) =>
    T.map(E.fold(onLeft, onRight));

TaskEither<L, R2> Function(TaskEither<L, R> taskEither) flatMap<L, R, R2>(
  TaskEither<L, R2> Function(R value) f,
) =>
    T.flatMap(E.fold(left, f));

TaskEither<L, R> Function(TaskEither<L, R> taskEither) alt<L, R>(
  TaskEither<L, R> Function(L left) orElse,
) =>
    T.flatMap(E.fold(orElse, right));

TaskEither<L, R> Function(TaskEither<L, R> taskEither) orElse<L, R>(
  TaskEither<L, R> orElse,
) =>
    alt((_) => orElse);

T.Task<R> Function(TaskEither<L, R> taskEither) getOrElse<L, R>(
  R Function(L left) orElse,
) =>
    T.map(E.getOrElse(orElse));

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

TaskEither<L, R2> Function(
  TaskEither<L, R> taskEither,
) chainTryCatchK<L, R, R2>(
  FutureOr<R2> Function(R value) task,
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
    flatMap(tryCatchK(task, onError));

TaskEither<L, R2> Function(TaskEither<L, R> taskEither) map<L, R, R2>(
  R2 Function(R value) f,
) =>
    T.map(E.map(f));

TaskEither<L, R> Function(TaskEither<L, R> taskEither) filter<L, R>(
  bool Function(R value) predicate,
  L Function(R value) orElse,
) =>
    T.map(E.filter(predicate, orElse));
