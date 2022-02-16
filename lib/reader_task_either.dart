import 'package:fpdt/fpdt.dart';
import 'package:fpdt/either.dart' as E;
import 'package:fpdt/reader_task.dart' as RT;
import 'package:fpdt/task_either.dart' as TE;

typedef ReaderTaskEither<R, E, A> = TaskEither<E, A> Function(R);

/// Projects a value from the global context in a [ReaderTaskEither].
ReaderTaskEither<R, E, R> ask<R, E>() => (R r) => TE.right(r);

/// Projects a value from the global context in a [ReaderTaskEither].
ReaderTaskEither<R, E, A> asks<R, E, A>(A Function(R r) f) =>
    (r) => TE.right(f(r));

/// Projects a [TE.right] value in a [ReaderTaskEither].
ReaderTaskEither<R, E, A> right<R, E, A>(A a) => (r) => TE.right(a);

/// Projects a [TE.left] value in a [ReaderTaskEither].
ReaderTaskEither<R, E, A> left<R, E, A>(E e) => (r) => TE.left(e);

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

/// Conditionally filter the [ReaderTaskEither], transforming [Right] values to [Left].
ReaderTaskEither<C, L, R> Function(ReaderTaskEither<C, L, R> taskEither)
    filter<C, L, R>(
  bool Function(R value) predicate,
  L Function(R value) orElse,
) =>
        RT.map(E.filter(predicate, orElse));
