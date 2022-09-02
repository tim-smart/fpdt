import 'dart:async';

import 'package:fpdt/fpdt.dart';

/// A state machine for [StateReader].
class StateReaderMachine<S, C> implements StateMachineBase<S> {
  StateReaderMachine(this.context, this._state);

  final C context;
  S _state;

  @override
  S get state => _state;

  StreamController<S>? _controller;

  @override
  Stream<S> get stream {
    _controller ??= StreamController.broadcast(sync: true);
    return _controller!.stream;
  }

  /// Run the computation and returns a tuple of the result and state.
  Tuple2<A, S> run<A>(StateReader<S, C, A> state) {
    final next = state(_state)(context);
    final previous = _state;

    _state = next.second;
    if (_controller != null && !identical(previous, _state)) {
      _controller!.add(_state);
    }

    return next;
  }

  /// Run the computation and returns the result only.
  A evaluate<A>(StateReader<S, C, A> state) => run(state).first;

  /// Run the computation and returns the state only.
  S execute(StateReader<S, C, dynamic> state) => run(state).second;

  /// Run the iterable of [State]'s in sequence
  IList<Tuple2<dynamic, S>> sequence(
          Iterable<StateReader<S, C, dynamic>> arr) =>
      arr.map(run).toIList();

  /// Run the iterable of [State]'s in sequence, only returning the results.
  IList<dynamic> evaluateSeq(Iterable<StateReader<S, C, dynamic>> arr) =>
      arr.map(run).map((t) => t.first).toIList();

  /// Run the iterable of [State]'s in sequence, only returning the new states.
  IList<S> executeSeq(Iterable<StateReader<S, C, dynamic>> arr) =>
      arr.map(run).map((t) => t.second).toIList();

  @override
  void close() => _controller?.close();
}
