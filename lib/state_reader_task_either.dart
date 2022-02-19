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

StateReaderTaskEither<S, C, L, void> modify<S, C, L>(S Function(S s) f) =>
    (s) => RTE.right(tuple2(null, f(s)));

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
