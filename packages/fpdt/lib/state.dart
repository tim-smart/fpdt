import 'package:fpdt/fpdt.dart';

class State<S, A> {
  State(this._f);
  final Tuple2<A, S> Function(S state) _f;
  Tuple2<A, S> call(S state) => _f(state);
}

/// Get the current state
State<S, S> get<S>() => State((s) => tuple2(s, s));

/// Set the state
State<S, Unit> put<S>(S s) => State((_) => tuple2(unit, s));

/// Modify the state with the given transformer function
State<S, Unit> modify<S>(S Function(S s) f) => State((s) => tuple2(unit, f(s)));

/// Get a value that depends on the state
State<S, A> gets<S, A>(A Function(S s) f) => State((s) => tuple2(f(s), s));

/// Transform the value of the [State] (the `A` type)
State<S, B> Function(State<S, A>) map<S, A, B>(B Function(A a) f) =>
    (fa) => State((sa) {
          final next = fa(sa);
          return tuple2(f(next.first), next.second);
        });

State<S, A> of<S, A>(A a) => State((S s) => tuple2(a, s));

/// Compose computations in sequence
State<S, B> Function(State<S, A> fa) flatMap<S, A, B>(
  State<S, B> Function(A a) f,
) =>
    (fa) => State((sa) {
          final next = fa(sa);
          return f(next.first)(next.second);
        });

/// Compose computations in sequence, discarding the result
State<S, A> Function(State<S, A> fa) flatMapFirst<S, A>(
  State<S, dynamic> Function(A a) f,
) =>
    map((a) {
      f(a);
      return a;
    });

State<S, A> flatten<S, A>(State<S, State<S, A>> fa) => State((sa) {
      final next = fa(sa);
      return next.first(next.second);
    });

/// Run a computation in the `State` monad, discarding the final state
A Function<A>(State<S, A> s) evaluate<S>(S s) => <A>(fa) => fa(s).first;

/// Run a computation in the `State` monad, discarding the result
S Function<A>(State<S, A> s) execute<S>(S s) => <A>(fa) => fa(s).second;

State<S, IList<A>> sequence<S, A>(Iterable<State<S, A>> states) =>
    State((s) => states.fold(tuple2(IList(), s), (acc, f) {
          final next = f(acc.second);
          return tuple2(acc.first.add(next.first), next.second);
        }));
