import 'dart:async';

import 'package:fpdt/fpdt.dart';

/// A state machine for [State].
class StateMachine<S> {
  StateMachine(this._state);

  S _state;
  S get state => _state;

  StreamController<S>? _controller;
  Stream<S> get stream {
    _controller ??= StreamController();
    return _controller!.stream;
  }

  Tuple2<A, S> run<A>(State<S, A> state) {
    final next = state(_state);
    _state = next.second;
    _controller?.add(next.second);
    return next;
  }

  A evaluate<A>(State<S, A> state) => run(state).first;
  S execute(State<S, dynamic> state) => run(state).second;

  IList<Tuple2<dynamic, S>> sequence(Iterable<State<S, dynamic>> arr) =>
      arr.map(run).toIList();
  IList<dynamic> evaluateSeq(Iterable<State<S, dynamic>> arr) =>
      arr.map(run).map((t) => t.first).toIList();
  IList<S> executeSeq(Iterable<State<S, dynamic>> arr) =>
      arr.map(run).map((t) => t.second).toIList();

  void close() => _controller?.close();
}
