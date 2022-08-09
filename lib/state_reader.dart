import 'package:fpdt/fpdt.dart';

typedef StateReader<S, C, A> = Reader<C, Tuple2<A, S>> Function(S s);

/// Get the current state
StateReader<S, C, S> get<C, S>() => (s) => (c) => tuple2(s, s);

/// Set the state
StateReader<S, C, Unit> put<S, C>(S s) => (_) => (c) => tuple2(unit, s);

/// Modify the state with the given transformer function
StateReader<S, C, Unit> modify<S, C>(S Function(S s) f) =>
    (s) => (c) => tuple2(unit, f(s));

/// Get a value that depends on the state
StateReader<S, C, A> gets<S, C, A>(A Function(S s) f) =>
    (s) => (c) => tuple2(f(s), s);

/// Transform the value of the [State] (the `A` type)
StateReader<S, C, B> Function(StateReader<S, C, A>) map<S, C, A, B>(
        B Function(A a) f) =>
    (fa) => (sa) => (c) {
          final next = fa(sa)(c);
          return tuple2(f(next.first), next.second);
        };

StateReader<S, C, A> of<S, C, A>(A a) => (s) => (c) => tuple2(a, s);

/// Compose computations in sequence
StateReader<S, C, B> Function(StateReader<S, C, A> fa) flatMap<S, C, A, B>(
  StateReader<S, C, B> Function(A a) f,
) =>
    (fa) => (sa) => (c) {
          final next = fa(sa)(c);
          return f(next.first)(next.second)(c);
        };

/// Compose computations in sequence, discarding the result
StateReader<S, C, A> Function(StateReader<S, C, A> fa) flatMapFirst<S, C, A>(
  StateReader<S, C, dynamic> Function(A a) f,
) =>
    map((a) {
      f(a);
      return a;
    });

StateReader<S, C, A> flatten<S, C, A>(
        StateReader<S, C, StateReader<S, C, A>> fa) =>
    (sa) => (c) {
          final next = fa(sa)(c);
          return next.first(next.second)(c);
        };

/// Run a computation in the `State` monad, discarding the final state
A Function<A>(StateReader<S, C, A> s) Function(C c) evaluate<S, C>(S s) =>
    (C c) => <A>(fa) => fa(s)(c).first;

/// Run a computation in the `State` monad, discarding the result
S Function<A>(StateReader<S, C, A> s) Function(C c) execute<S, C>(S s) =>
    (C c) => <A>(fa) => fa(s)(c).second;

StateReader<S, C, IList<A>> sequence<S, C, A>(
        Iterable<StateReader<S, C, A>> states) =>
    (s) => (c) => states.fold(tuple2(IList(), s), (acc, f) {
          final next = f(acc.second)(c);
          return tuple2(acc.first.add(next.first), next.second);
        });

/// Projects a value from the global context in a Reader
StateReader<S, C, C> ask<S, C>() => (s) => (c) => tuple2(c, s);
StateReader<S, C, A> asks<S, C, A>(A Function(C r) f) =>
    (s) => (c) => tuple2(f(c), s);

StateReader<S, C2, A> Function(StateReader<S, C1, A>) local<S, C1, C2, A>(
        C1 Function(C2 r) f) =>
    (fa) => (s) => (c) => fa(s)(f(c));
