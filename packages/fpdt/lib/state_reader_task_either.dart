import 'dart:async';

import 'package:fpdt/fpdt.dart';
import 'package:fpdt/either.dart' as Ei;
import 'package:fpdt/option.dart' as O;
import 'package:fpdt/reader.dart' as Rd;
import 'package:fpdt/reader_task.dart' as RT;
import 'package:fpdt/reader_task_either.dart' as RTE;
import 'package:fpdt/task.dart' as T;
import 'package:fpdt/task_either.dart' as TE;

typedef StateReaderTaskEither<S, C, L, R> = ReaderTaskEither<C, L, Tuple2<R, S>>
    Function(S s);

StateReaderTaskEither<S, R, E, A> left<S, R, E, A>(E e) => (s) => RTE.left(e);
StateReaderTaskEither<S, R, E, A> right<S, R, E, A>(A a) =>
    (s) => RTE.right(tuple2(a, s));

/// Replace the [StateReaderTaskEither] with one that resolves to an [Right] containing
/// the given value.
StateReaderTaskEither<S, C, L, R2> Function(StateReaderTaskEither<S, C, L, R>)
    pure<S, C, L, R, R2>(R2 a) => (_) => right(a);

StateReaderTaskEither<S, C, L, S> get<S, C, L>() =>
    (s) => RTE.right(tuple2(s, s));

StateReaderTaskEither<S, C, L, R> gets<S, C, L, R>(R Function(S s) f) =>
    (s) => RTE.right(tuple2(f(s), s));

StateReaderTaskEither<S, C, L, Unit> put<S, C, L>(S s) =>
    (_) => RTE.right(tuple2(unit, s));

StateReaderTaskEither<S, C, L, Unit> Function(
    StateReaderTaskEither<S, C, L, dynamic>) chainPut<S, C, L>(
        S s) =>
    call(put(s));

StateReaderTaskEither<S, C, L, Unit> modify<S, C, L, R>(S Function(S s) f) =>
    (s) => RTE.right(tuple2(unit, f(s)));

StateReaderTaskEither<S, C, L, Unit> Function(
    StateReaderTaskEither<S, C, L, dynamic>) chainModify<S, C, L>(
        S Function(S s) f) =>
    call(modify(f));

/// Projects a value from the global context in a [StateReaderTaskEither].
StateReaderTaskEither<S, C, L, C> ask<S, C, L>() =>
    (s) => (c) => TE.right(tuple2(c, s));

/// Projects a value from the global context in a [StateReaderTaskEither].
StateReaderTaskEither<S, C, L, R> asks<S, C, L, R>(R Function(C c) f) =>
    (s) => (c) => TE.right(tuple2(f(c), s));

/// If the function returns true, then the resolved [Either] will be a [Right]
/// containing the given `value`.
///
/// If the function returns `false`, then the resolved [Either] will be a [Left]
/// containing the value returned from executing the `orElse` function.
StateReaderTaskEither<S, C, L, R> fromPredicate<S, C, L, R>(
  R r,
  bool Function(R r) f,
  L Function(R r) orElse,
) =>
    fromEither(Ei.fromPredicate(r, f, orElse));

/// If the function returns true, then the resolved [Either] will be a [Right]
/// containing the given `value`.
///
/// If the function returns `false`, then the resolved [Either] will be a [Left]
/// containing the value returned from executing the `orElse` function.
StateReaderTaskEither<S, C, L, R> Function(R r) fromPredicateK<S, C, L, R>(
  bool Function(R r) f,
  L Function(R r) orElse,
) =>
    (r) => fromPredicate(r, f, orElse);

/// Returns a [StateReaderTaskEither] that resolves to the given [ReaderTaskEither].
StateReaderTaskEither<S, C, L, R> fromReaderTaskEither<S, C, L, R>(
        ReaderTaskEither<C, L, R> rte) =>
    (s) => rte.chain((RTE.map((a) => tuple2(a, s))));

/// Returns a [StateReaderTaskEither] that resolves to the given [Either].
StateReaderTaskEither<S, C, L, R> fromState<S, C, L, R>(State<S, R> f) =>
    (s) => RTE.right(f(s));

/// Returns a [StateReaderTaskEither] that resolves to the given [Either].
StateReaderTaskEither<S, C, L, R> fromEither<S, C, L, R>(Either<L, R> either) =>
    either.chain(Ei.fold(left, right));

StateReaderTaskEither<S, C, E, A> Function(Option<A> fa) fromOption<S, C, E, A>(
  E Function() onNone,
) =>
    (fa) => fa.chain(O.fold(() => left(onNone()), (a) => right(a)));

/// Transforms a [Reader] into a [StateReaderTaskEither], wrapping the result in an [Right].
StateReaderTaskEither<S, C, L, R> fromReader<S, C, L, R>(Reader<C, R> f) =>
    (s) => RTE.fromReader(f.chain(Rd.map((r) => tuple2(r, s))));

/// Transforms a [ReaderTask] into a [StateReaderTaskEither], wrapping the
/// result in an [Right].
StateReaderTaskEither<S, C, L, R> fromReaderTask<S, C, L, R>(
        ReaderTask<C, R> f) =>
    (s) => RTE.fromReaderTask(f.chain(RT.map((r) => tuple2(r, s))));

/// Transforms a [Task] into a [StateReaderTaskEither], wrapping the result in an [Right].
StateReaderTaskEither<S, C, L, R> fromTask<S, C, L, R>(Task<R> task) =>
    (s) => RTE.fromTask(task.chain(T.map((a) => tuple2(a, s))));

/// Returns a [StateReaderTaskEither] that resolves to the given [TaskEither].
StateReaderTaskEither<S, C, L, R> fromTaskEither<S, C, L, R>(
  TaskEither<L, R> taskEither,
) =>
    (s) => RTE.fromTaskEither(taskEither.chain(TE.map((a) => tuple2(a, s))));

StateReaderTaskEither<S, C, L, R2> Function(StateReaderTaskEither<S, C, L, R1>)
    call<S, C, L, R1, R2>(
  StateReaderTaskEither<S, C, L, R2> chain,
) =>
        flatMap((_) => chain);

StateReaderTaskEither<S, C, L, R2> Function(StateReaderTaskEither<S, C, L, R1>)
    replace<S, C, L, R1, R2>(
  StateReaderTaskEither<S, C, L, R2> chain,
) =>
        (fa) => (s) => fa(s).chain(RTE.replace(chain(s)));

StateReaderTaskEither<S, R, E, B> Function(StateReaderTaskEither<S, R, E, A>)
    map<S, R, E, A, B>(B Function(A a) f) =>
        (fa) => fa.compose(RTE.map((t) => tuple2(f(t.first), t.second)));

/// Run a side effect on a [Right] value. The side effect can optionally return
/// a [Future].
StateReaderTaskEither<S, C, L, R> Function(StateReaderTaskEither<S, C, L, R>)
    tap<S, C, L, R>(
  FutureOr<void> Function(R r) f,
) =>
        flatMapFirstTask((r) => () => Future.sync(() => f(r)));

/// Run a side effect on a [Left] value. The side effect can optionally return
/// a [Future].
StateReaderTaskEither<S, C, L, R> Function(StateReaderTaskEither<S, C, L, R>)
    tapLeft<S, C, L, R>(
  FutureOr<void> Function(L value) f,
) =>
        (fa) => fa.compose(RTE.tapLeft(f));

StateReaderTaskEither<S, C, L2, R> Function(StateReaderTaskEither<S, C, L1, R>)
    mapLeft<S, C, L1, L2, R>(L2 Function(L1 a) f) =>
        (fa) => fa.compose(RTE.mapLeft(f));

StateReaderTaskEither<S, R, E, IList<B>> Function(
    Iterable<A>) traverseIterable<S, R, E, A, B>(
  StateReaderTaskEither<S, R, E, B> Function(A a) f,
) =>
    (as) => (s) => (r) => () => as.fold<Future<Either<E, Tuple2<IList<B>, S>>>>(
          Future.sync(() => Ei.right(tuple2(IList(), s))),
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

StateReaderTaskEither<S, R, E, Tuple2<A, B>> Function(
    StateReaderTaskEither<S, R, E, A>) flatMapTuple2<S, R, E, A, B>(
        StateReaderTaskEither<S, R, E, B> Function(A a) f) =>
    flatMap((a) => f(a).p(map((b) => tuple2(a, b))));

StateReaderTaskEither<S, R, E, Tuple3<A, B, C>> Function(
        StateReaderTaskEither<S, R, E, Tuple2<A, B>>)
    flatMapTuple3<S, R, E, A, B, C>(
            StateReaderTaskEither<S, R, E, C> Function(Tuple2<A, B> a) f) =>
        flatMap((a) => f(a).p(map((c) => tuple3(a.first, a.second, c))));

StateReaderTaskEither<S, C, L, R2> Function(StateReaderTaskEither<S, C, L, R1>)
    flatMapR<S, C, L, R1, R2>(
            ReaderTaskEither<C, L, R2> Function(S s) Function(R1 a) f) =>
        flatMap((a) => (s) => f(a)(s).chain(RTE.map((b) => tuple2(b, s))));

StateReaderTaskEither<S, C, L, Unit> Function(StateReaderTaskEither<S, C, L, R>)
    flatMapS<S, C, L, R>(
            ReaderTaskEither<C, L, S> Function(S s) Function(R a) f) =>
        flatMap((a) => f(a).compose(RTE.map((s) => tuple2(unit, s))));

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
    flatMapState<S, C, L, R1, R2>(
  State<S, R2> Function(R1 a) f,
) =>
        flatMap(f.compose(fromState));

StateReaderTaskEither<S, C, L, R2> Function(StateReaderTaskEither<S, C, L, R1>)
    flatMapReader<S, C, L, R1, R2>(
  Reader<C, R2> Function(R1 a) f,
) =>
        flatMap(f.compose(fromReader));

StateReaderTaskEither<S, C, L, R2> Function(StateReaderTaskEither<S, C, L, R1>)
    flatMapReaderTask<S, C, L, R1, R2>(
  ReaderTask<C, R2> Function(R1 a) f,
) =>
        flatMap(f.compose(fromReaderTask));

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

StateReaderTaskEither<S, C, L, R> Function(StateReaderTaskEither<S, C, L, R>)
    flatMapFirstState<S, C, L, R>(
  State<S, dynamic> Function(R a) f,
) =>
        flatMapFirst(f.compose(fromState));

StateReaderTaskEither<S, C, L, R> Function(StateReaderTaskEither<S, C, L, R>)
    flatMapFirstReader<S, C, L, R>(
  Reader<C, dynamic> Function(R a) f,
) =>
        flatMapFirst(f.compose(fromReader));

StateReaderTaskEither<S, C, L, R> Function(StateReaderTaskEither<S, C, L, R>)
    flatMapFirstReaderTaskEither<S, C, L, R>(
  ReaderTaskEither<C, L, dynamic> Function(R a) f,
) =>
        flatMapFirst(f.compose(fromReaderTaskEither));

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
  FutureOr<R> Function() task,
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
    (s) => (r) => TE.tryCatch(task, onError).p(TE.map((r) => tuple2(r, s)));

/// A variant of [tryCatch] that accepts an external parameter.
StateReaderTaskEither<S, C, L, R> Function(A value) tryCatchK<S, C, A, L, R>(
  FutureOr<R> Function(A value) task,
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
    (a) => tryCatch(
          () => task(a),
          onError,
        );

/// A variant of [tryCatch] that accepts two external parameters.
StateReaderTaskEither<S, C, L, R> Function(A a, B b)
    tryCatchK2<A, B, S, C, L, R>(
  FutureOr<R> Function(A a, B b) task,
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
        (a, b) => tryCatch(() => task(a, b), onError);

/// A chainable variant of [tryCatchK].
StateReaderTaskEither<S, C, L, R2> Function(StateReaderTaskEither<S, C, L, R>)
    chainTryCatchK<S, C, L, R, R2>(
  FutureOr<R2> Function(R value) task,
  L Function(dynamic err, StackTrace stackTrace) onError,
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

// Delay the task by the given duration.
StateReaderTaskEither<S, C, L, R> Function(StateReaderTaskEither<S, C, L, R>)
    delay<S, C, L, R>(
  Duration d,
) =>
        (f) => f.compose(RTE.delay(d));

/// Conditionally filter the [StateReaderTaskEither], transforming [Right] values to [Left].
StateReaderTaskEither<S, C, L, R> Function(StateReaderTaskEither<S, C, L, R>)
    filter<S, C, L, R>(
  bool Function(R value) predicate,
  L Function(R value) orElse,
) =>
        (f) => f.compose(RTE.filter(
              (t) => predicate(t.first),
              (t) => orElse(t.first),
            ));
