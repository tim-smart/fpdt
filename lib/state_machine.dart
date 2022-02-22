import 'dart:async';

import 'package:fpdt/fpdt.dart';

abstract class StateMachineBase<S> {
  /// A [Stream] of state changes
  Stream<S> get stream;

  /// The current state ([S]) of the machine
  S get state;

  /// Closes the internal [StreamController]
  void close();
}

/// A state machine for [State].
class StateMachine<S> implements StateMachineBase<S> {
  StateMachine(this._state);

  S _state;

  @override
  S get state => _state;

  StreamController<S>? _controller;

  @override
  Stream<S> get stream {
    _controller ??= StreamController.broadcast();
    return _controller!.stream;
  }

  /// Run the computation and returns a tuple of the result and state.
  Tuple2<A, S> run<A>(State<S, A> state) {
    final next = state(_state);
    _state = next.second;
    _controller?.add(next.second);
    return next;
  }

  /// Run the computation and returns the result only.
  A evaluate<A>(State<S, A> state) => run(state).first;

  /// Run the computation and returns the state only.
  S execute(State<S, dynamic> state) => run(state).second;

  /// Run the iterable of [State]'s in sequence
  IList<Tuple2<dynamic, S>> sequence(Iterable<State<S, dynamic>> arr) =>
      arr.map(run).toIList();

  /// Run the iterable of [State]'s in sequence, only returning the results.
  IList<dynamic> evaluateSeq(Iterable<State<S, dynamic>> arr) =>
      arr.map(run).map((t) => t.first).toIList();

  /// Run the iterable of [State]'s in sequence, only returning the new states.
  IList<S> executeSeq(Iterable<State<S, dynamic>> arr) =>
      arr.map(run).map((t) => t.second).toIList();

  @override
  void close() => _controller?.close();
}
