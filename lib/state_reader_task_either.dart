import 'dart:async';

import 'package:fpdt/fpdt.dart';
import 'package:fpdt/either.dart' as Ei;
import 'package:fpdt/reader_task_either.dart' as RTE;
import 'package:fpdt/task.dart' as T;
import 'package:fpdt/task_either.dart' as TE;

typedef StateReaderTaskEither<S, C, L, R> = ReaderTaskEither<C, L, Tuple2<R, S>>
    Function(S s);

StateReaderTaskEither<S, R, E, A> left<S, R, E, A>(E e) => (s) => RTE.left(e);
StateReaderTaskEither<S, R, E, A> right<S, R, E, A>(A a) =>
    (s) => RTE.right(tuple2(a, s));

StateReaderTaskEither<S, C, L, S> get<S, C, L>() =>
    (s) => RTE.right(tuple2(s, s));

StateReaderTaskEither<S, C, L, R> gets<S, C, L, R>(R Function(S s) f) =>
    (s) => RTE.right(tuple2(f(s), s));

StateReaderTaskEither<S, C, L, void> put<S, C, L>(S s) =>
    (_) => RTE.right(tuple2(null, s));

StateReaderTaskEither<S, C, L, void> Function(
    StateReaderTaskEither<S, C, L, dynamic>) chainPut<S, C, L>(
        S s) =>
    flatMap((_) => put(s));

StateReaderTaskEither<S, C, L, void> modify<S, C, L, R>(S Function(S s) f) =>
    (s) => RTE.right(tuple2(null, f(s)));

StateReaderTaskEither<S, C, L, void> Function(
    StateReaderTaskEither<S, C, L, dynamic>) chainModify<S, C, L>(
        S Function(S s) f) =>
    flatMap((_) => modify(f));

/// Projects a value from the global context in a [StateReaderTaskEither].
StateReaderTaskEither<S, C, L, C> ask<S, C, L>() =>
    (s) => (c) => TE.right(tuple2(c, s));

/// Projects a value from the global context in a [StateReaderTaskEither].
StateReaderTaskEither<S, C, L, R> asks<S, C, L, R>(R Function(C c) f) =>
    (s) => (c) => TE.right(tuple2(f(c), s));

/// Returns a [StateReaderTaskEither] that resolves to the given [ReaderTaskEither].
StateReaderTaskEither<S, C, L, R> fromReaderTaskEither<S, C, L, R>(
        ReaderTaskEither<C, L, R> rte) =>
    (s) => rte.chain((RTE.map((a) => tuple2(a, s))));

/// Returns a [StateReaderTaskEither] that resolves to the given [Either].
StateReaderTaskEither<S, C, L, R> fromEither<S, C, L, R>(Either<L, R> either) =>
    either.chain(Ei.fold(left, right));

/// Transforms a [Task] into a [StateReaderTaskEither], wrapping the result in an [Right].
StateReaderTaskEither<S, C, L, R> fromTask<S, C, L, R>(Task<R> task) =>
    (s) => RTE.fromTask(task.chain(T.map((a) => tuple2(a, s))));

/// Returns a [StateReaderTaskEither] that resolves to the given [TaskEither].
StateReaderTaskEither<S, C, L, R> fromTaskEither<S, C, L, R>(
        TaskEither<L, R> taskEither) =>
    (s) => RTE.fromTaskEither(taskEither.chain(TE.map((a) => tuple2(a, s))));

StateReaderTaskEither<S, R, E, B> Function(StateReaderTaskEither<S, R, E, A>)
    map<S, R, E, A, B>(B Function(A a) f) =>
        (fa) => fa.compose(RTE.map((t) => tuple2(f(t.first), t.second)));

StateReaderTaskEither<S, R, E, IList<B>> Function(
    Iterable<A>) traverseIterable<S, R, E, A, B>(
  StateReaderTaskEither<S, R, E, B> Function(A a) f,
) =>
    (as) => (s) => (r) => () => as.fold<Future<Either<E, Tuple2<IList<B>, S>>>>(
          Future.value(Ei.right(tuple2(IList(), s))),
          (acc, a) => acc.then(Ei.fold(
            (e) => acc,
            (bs) => f(a)(bs.second)(r)().then((eb) => eb.chain(Ei.fold(
                  (e) => Ei.left(e),
                  (t) => Ei.right(tuple2(bs.first.add(t.first), t.second)),
                ))),
          )),
        );

StateReaderTaskEither<S, R, E, IList<A>> sequence<S, R, E, A>(
        Iterable<StateReaderTaskEither<S, R, E, A>> arr) =>
    arr.chain(traverseIterable(identity));

StateReaderTaskEither<S, R, E, B> Function(StateReaderTaskEither<S, R, E, A>)
    flatMap<S, R, E, A, B>(StateReaderTaskEither<S, R, E, B> Function(A a) f) =>
        (fa) => fa.compose(RTE.flatMap((a) => f(a.first)(a.second)));

StateReaderTaskEither<S, C, L, R2> Function(StateReaderTaskEither<S, C, L, R1>)
    flatMapTask<S, C, L, R1, R2>(
  Task<R2> Function(R1 a) f,
) =>
        flatMap(f.compose(fromTask));

StateReaderTaskEither<S, C, L, R2> Function(StateReaderTaskEither<S, C, L, R1>)
    flatMapTaskEither<S, C, L, R1, R2>(
  TaskEither<L, R2> Function(R1 a) f,
) =>
        flatMap(f.compose(fromTaskEither));

StateReaderTaskEither<S, C, L, R2> Function(StateReaderTaskEither<S, C, L, R1>)
    flatMapEither<S, C, L, R1, R2>(
  Either<L, R2> Function(R1 a) f,
) =>
        flatMap(f.compose(fromEither));

StateReaderTaskEither<S, C, L, R2> Function(StateReaderTaskEither<S, C, L, R1>)
    flatMapReaderTaskEither<S, C, L, R1, R2>(
  ReaderTaskEither<C, L, R2> Function(R1 a) f,
) =>
        flatMap(f.compose(fromReaderTaskEither));

/// Composes computations in sequence, using the return value from the previous
/// computation. Discarding the result.
StateReaderTaskEither<S, C, L, R> Function(StateReaderTaskEither<S, C, L, R>)
    flatMapFirst<S, C, L, R>(
  StateReaderTaskEither<S, C, L, dynamic> Function(R a) f,
) =>
        flatMap((r) => f(r).chain(map((_) => r)));

StateReaderTaskEither<S, C, L, R> Function(StateReaderTaskEither<S, C, L, R>)
    flatMapFirstTask<S, C, L, R>(
  Task<dynamic> Function(R a) f,
) =>
        flatMapFirst(f.compose(fromTask));

StateReaderTaskEither<S, C, L, R> Function(StateReaderTaskEither<S, C, L, R>)
    flatMapFirstTaskEither<S, C, L, R>(
  TaskEither<L, dynamic> Function(R a) f,
) =>
        flatMapFirst(f.compose(fromTaskEither));

StateReaderTaskEither<S, C, L, R> Function(StateReaderTaskEither<S, C, L, R>)
    flatMapFirstEither<S, C, L, R>(
  Either<L, dynamic> Function(R a) f,
) =>
        flatMapFirst(f.compose(fromEither));

StateReaderTaskEither<S, C, L, R> flatten<S, C, L, R>(
        StateReaderTaskEither<S, C, L, StateReaderTaskEither<S, C, L, R>>
            srte) =>
    srte.chain(flatMap(identity));

ReaderTaskEither<C, L, R> Function(S s) evaluate<S, C, L, R>(
        StateReaderTaskEither<S, C, L, R> f) =>
    f.compose(RTE.map((a) => a.first));

ReaderTaskEither<C, L, S> Function(S s) execute<S, C, L, R>(
        StateReaderTaskEither<S, C, L, R> f) =>
    f.compose(RTE.map((a) => a.second));

/// Runs the given task, and returns the result as an [Right].
/// If it throws an error, the the error is passed to `onError`, which determines
/// the [Left] value.
StateReaderTaskEither<S, C, L, R> tryCatch<S, C, L, R>(
  FutureOr<R> Function(C) Function(S) task,
  L Function(dynamic err, StackTrace stackTrace) Function(C c) Function(S)
      onError,
) =>
    (s) => (r) => () async {
          try {
            return Ei.right(tuple2(await task(s)(r), s));
          } catch (err, stack) {
            return Ei.left(onError(s)(r)(err, stack));
          }
        };

/// A variant of [tryCatch] that accepts an external parameter.
StateReaderTaskEither<S, C, L, R> Function(A value) tryCatchK<S, C, A, L, R>(
  FutureOr<R> Function(A value) Function(C) Function(S) task,
  L Function(dynamic err, StackTrace stackTrace) Function(A a) Function(C c)
          Function(S s)
      onError,
) =>
    (a) => tryCatch(
          (s) => (c) => task(s)(c)(a),
          (s) => (c) => onError(s)(c)(a),
        );

/// A variant of [tryCatch] that accepts two external parameters.
StateReaderTaskEither<S, C, L, R> Function(A a, B b)
    tryCatchK2<A, B, S, C, L, R>(
  FutureOr<R> Function(A a, B b) Function(C) Function(S) task,
  L Function(dynamic err, StackTrace stackTrace) Function(C c) Function(S s)
      onError,
) =>
        (a, b) => tryCatch((s) => (c) => task(s)(c)(a, b), onError);

/// A chainable variant of [tryCatchK].
StateReaderTaskEither<S, C, L, R2> Function(StateReaderTaskEither<S, C, L, R>)
    chainTryCatchK<S, C, L, R, R2>(
  FutureOr<R2> Function(R value) Function(C c) Function(S s) task,
  L Function(dynamic err, StackTrace stackTrace) Function(R r) Function(C c)
          Function(S s)
      onError,
) =>
        flatMap(tryCatchK(task, onError));

/// If the given [StateReaderTaskEither] is an [Left], then unwrap the result and transform
/// it into an [alt]ernative [StateReaderTaskEither].
StateReaderTaskEither<S, C, L, R> Function(StateReaderTaskEither<S, C, L, R>)
    alt<S, C, L, R>(
  StateReaderTaskEither<S, C, L, R> Function(L left) orElse,
) =>
        (f) => (s) => f(s).chain(RTE.alt((l) => orElse(l)(s)));

/// Similar to [alt], but the alternative [ReaderTaskEither] is given directly.
StateReaderTaskEither<S, C, L, R> Function(StateReaderTaskEither<S, C, L, R>)
    orElse<S, C, L, R>(
  StateReaderTaskEither<S, C, L, R> orElse,
) =>
        alt((_) => orElse);
