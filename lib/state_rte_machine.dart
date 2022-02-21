import 'dart:async';

import 'package:fpdt/either.dart' as E;
import 'package:fpdt/fpdt.dart';

/// A state machine for [StateReaderTaskEither].
class StateRTEMachine<S, C, L> {
  StateRTEMachine(this._state, this.context);

  S _state;
  S get state => _state;

  StreamController<S>? _controller;
  Stream<S> get stream {
    _controller ??= StreamController.broadcast(sync: true);
    return _controller!.stream;
  }

  final C context;

  late Future<Either<L, Tuple2<dynamic, S>>> _future =
      Future.value(E.right(tuple2(null, _state)));

  var _closed = false;
  bool get closed => _closed;

  Future<Either<L, R>> evaluate<R>(StateReaderTaskEither<S, C, L, R> state) =>
      run(state).then(E.map((t) => t.first));

  Future<Either<L, S>> execute<R>(StateReaderTaskEither<S, C, L, R> state) =>
      run(state).then(E.map((t) => t.second));

  Future<Either<L, Tuple2<R, S>>> run<R>(
    StateReaderTaskEither<S, C, L, R> state,
  ) {
    if (_closed) {
      return Future.error('closed');
    }

    final future = _future.then((_) => state(_state)(context)());

    _future = future.then(
      _handleResult,
      onError: (err, st) => tuple2(null, _state),
    );

    return future;
  }

  Future<Either<L, IList<Tuple2<dynamic, S>>>> sequence(
          Iterable<StateReaderTaskEither<S, C, L, dynamic>> arr) =>
      Future.wait(arr.map(run)).then(E.sequence);

  Future<Either<L, IList<dynamic>>> evaluateSeq(
          Iterable<StateReaderTaskEither<S, C, L, dynamic>> arr) =>
      sequence(arr).then(E.map((arr) => arr.map((t) => t.first).toIList()));

  Future<Either<L, IList<S>>> executeSeq(
          Iterable<StateReaderTaskEither<S, C, L, dynamic>> arr) =>
      sequence(arr).then(E.map((arr) => arr.map((t) => t.second).toIList()));

  Either<L, Tuple2<R, S>> _handleResult<R>(Either<L, Tuple2<R, S>> result) {
    _state = result.chain(E.fold(
      (_) => _state,
      (r) => r.second,
    ));

    if (E.isRight(result)) {
      _controller?.add(_state);
    }

    return result;
  }

  void close() {
    if (_closed) return;
    _closed = true;
    _future.whenComplete(() => _controller?.close());
  }
}
