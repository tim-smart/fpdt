import 'package:fpdt/fpdt.dart';
import 'package:fpdt/either.dart' as Ei;
import 'package:fpdt/reader_task_either.dart' as RTE;

typedef StateReaderTaskEither<S, R, E, A> = ReaderTaskEither<R, E, Tuple2<A, S>>
    Function(S s);

StateReaderTaskEither<S, R, E, A> left<S, R, E, A>(E e) => (s) => RTE.left(e);
StateReaderTaskEither<S, R, E, A> right<S, R, E, A>(A a) =>
    (s) => RTE.right(tuple2(a, s));

StateReaderTaskEither<S, R, E, B> Function(
    StateReaderTaskEither<S, R, E, A>) map<S, R, E, A, B>(
        B Function(A a) f) =>
    (fa) => (s) => fa(s).chain(RTE.map((t) => tuple2(f(t.first), t.second)));

StateReaderTaskEither<S, R, E, B> Function(StateReaderTaskEither<S, R, E, A>)
    flatMap<S, R, E, A, B>(StateReaderTaskEither<S, R, E, B> Function(A a) f) =>
        (fa) => (s) => fa(s).chain(RTE.flatMap((a) => f(a.first)(a.second)));

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
