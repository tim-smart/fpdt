import 'dart:async';
import 'dart:collection';

import 'package:fpdt/either.dart' as E;
import 'package:fpdt/fpdt.dart';

/// A state machine for [StateReaderTaskEither].
class StateRTEMachine<S, C, L> {
  StateRTEMachine(this._state, this._context);

  S _state;
  S get state => _state;

  StreamController<S>? _controller;
  Stream<S> get stream {
    _controller ??= StreamController(sync: true);
    return _controller!.stream;
  }

  final C _context;

  final _queue = Queue<
      Tuple2<StateReaderTaskEither<S, C, L, dynamic>,
          Completer<Either<L, Tuple2<dynamic, S>>>>>();

  var _closed = false;
  bool get closed => _closed;

  Future<Either<L, R>> evaluate<R>(StateReaderTaskEither<S, C, L, R> state) =>
      run(state).then(E.map((t) => t.first));

  Future<Either<L, S>> execute<R>(StateReaderTaskEither<S, C, L, R> state) =>
      run(state).then(E.map((t) => t.second));

  Future<Either<L, Tuple2<R, S>>> run<R>(
      StateReaderTaskEither<S, C, L, R> state) async {
    if (_closed) throw 'closed';

    if (_queue.isNotEmpty) {
      final completer = Completer<Either<L, Tuple2<R, S>>>.sync();
      _queue.add(tuple2(state, completer));
      return completer.future;
    }

    return _run(state);
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

  Future<Either<L, Tuple2<R, S>>> _run<R>(
      StateReaderTaskEither<S, C, L, R> state) async {
    final result = await state(_state)(_context)();

    _state = result.chain(E.fold(
      (_) => _state,
      (r) => r.second,
    ));
    if (E.isRight(result)) {
      _controller?.add(_state);
    }

    if (_queue.isNotEmpty) {
      final next = _queue.removeFirst();
      _run(next.first).then(next.second.complete);
    } else {
      _maybeClose(true);
    }

    return result;
  }

  void close() {
    if (_closed) return;
    _closed = true;
    _maybeClose(_queue.isEmpty);
  }

  void _maybeClose(bool queueEmpty) {
    if (_closed && queueEmpty) {
      _controller?.close();
    }
  }
}
