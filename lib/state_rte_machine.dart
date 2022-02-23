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

  Future<dynamic> _future = Future.sync(() {});

  var _closed = false;

  /// `true` if [close] has been called
  bool get closed => _closed;

  /// Run the computation and returns the result only.
  Future<Either<L, R>> evaluate<R>(StateReaderTaskEither<S, C, L, R> state) =>
      run(state).then(E.map((t) => t.first));

  /// Run the computation and returns the state only.
  Future<Either<L, S>> execute<R>(StateReaderTaskEither<S, C, L, R> state) =>
      run(state).then(E.map((t) => t.second));

  /// Run the computation and returns a tuple of the result and state.
  Future<Either<L, Tuple2<R, S>>> run<R>(
    StateReaderTaskEither<S, C, L, R> state,
  ) {
    if (_closed) {
      return Future.error('closed');
    }

    final future = _future.then((_) => state(_state)(context)());

    _future = future.then(
      _handleResult,
      onError: (err, st) => null,
    );

    return future;
  }

  /// Run the computations in sequence
  Future<Either<L, IList<Tuple2<dynamic, S>>>> sequence(
          Iterable<StateReaderTaskEither<S, C, L, dynamic>> arr) =>
      Future.wait(arr.map(run)).then(E.sequence);

  /// Run the computations in sequence, only returning the results
  Future<Either<L, IList<dynamic>>> evaluateSeq(
          Iterable<StateReaderTaskEither<S, C, L, dynamic>> arr) =>
      sequence(arr).then(E.map((arr) => arr.map((t) => t.first).toIList()));

  /// Run the computations in sequence, only returning the new states
  Future<Either<L, IList<S>>> executeSeq(
          Iterable<StateReaderTaskEither<S, C, L, dynamic>> arr) =>
      sequence(arr).then(E.map((arr) => arr.map((t) => t.second).toIList()));

  Either<L, Tuple2<R, S>> _handleResult<R>(Either<L, Tuple2<R, S>> result) {
    final previous = _state;

    _state = result.chain(E.fold(
      (_) => _state,
      (r) => r.second,
    ));

    if (_controller != null && previous != _state) {
      _controller!.add(_state);
    }

    return result;
  }

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    _future.whenComplete(() => _controller?.close());
  }
}
