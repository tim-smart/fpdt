import 'dart:async';

import 'package:fpdt/either.dart' as E;
import 'package:fpdt/fpdt.dart';

/// A state machine for [StateReaderTaskEither].
class StateRTEMachine<S, C, L> implements StateMachineBase<S> {
  StateRTEMachine(this._state, this.context);

  S _state;

  @override
  S get state => _state;

  StreamController<S>? _controller;

  @override
  Stream<S> get stream {
    _controller ??= StreamController.broadcast(sync: true);
    return _controller!.stream;
  }

  /// The context / environment passed to the [StateReaderTaskEither]'s.
  final C context;

  FutureOr<dynamic> _future;

  var _closed = false;

  /// `true` if [close] has been called
  bool get closed => _closed;

  /// Run the computation and returns the result only.
  FutureOr<Either<L, R>> evaluate<R>(StateReaderTaskEither<S, C, L, R> state) =>
      run(state).flatMap(E.map((t) => t.first));

  /// Run the computation and returns the state only.
  FutureOr<Either<L, S>> execute<R>(StateReaderTaskEither<S, C, L, R> state) =>
      run(state).flatMap(E.map((t) => t.second));

  /// Run the computation and returns a tuple of the result and state.
  FutureOr<Either<L, Tuple2<R, S>>> run<R>(
    StateReaderTaskEither<S, C, L, R> state,
  ) {
    if (_closed) {
      return Future.error('closed');
    }

    final future = _future.flatMap((_) => state(_state)(context)());

    _future = future.flatMap(
      _handleResult,
    );

    return future;
  }

  /// Run the computations in sequence
  FutureOr<Either<L, IList<Tuple2<dynamic, S>>>> sequence(
    Iterable<StateReaderTaskEither<S, C, L, dynamic>> arr,
  ) =>
      arr.fold<FutureOr<Either<L, IList<Tuple2<dynamic, S>>>>>(
        E.right(IList()),
        (acc, _) => acc.flatMap(E.fold(
          (l) => E.left(l),
          (list) => run(_).flatMap(E.fold(
            (l) => E.left(l),
            (a) => E.right(list.add(a)),
          )),
        )),
      );

  /// Run the computations in sequence, only returning the results
  FutureOr<Either<L, IList<dynamic>>> evaluateSeq(
    Iterable<StateReaderTaskEither<S, C, L, dynamic>> arr,
  ) =>
      sequence(arr).flatMap(E.map((arr) => arr.map((t) => t.first).toIList()));

  /// Run the computations in sequence, only returning the new states
  FutureOr<Either<L, IList<S>>> executeSeq(
    Iterable<StateReaderTaskEither<S, C, L, dynamic>> arr,
  ) =>
      sequence(arr).flatMap(E.map((arr) => arr.map((t) => t.second).toIList()));

  Either<L, Tuple2<R, S>> _handleResult<R>(Either<L, Tuple2<R, S>> result) {
    final previous = _state;

    _state = result.chain(E.fold(
      (_) => _state,
      (r) => r.second,
    ));

    if (_controller != null && !identical(previous, _state)) {
      _controller!.add(_state);
    }

    return result;
  }

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    _future.flatMap((_) => _controller?.close());
  }
}
