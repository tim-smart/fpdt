import 'dart:async';

import 'package:fpdt/fpdt.dart';
import 'package:fpdt/either.dart' as E;
import 'package:fpdt/task_either.dart' as TE;
import 'package:fpdt/reader_task_either.dart' as RTE;
import 'dart:collection';

/// A state machine for [State].
class StateMachine<S> {
  StateMachine(this._state);

  Tuple2<dynamic, S> _state;
  Tuple2<dynamic, S> get state => _state;

  final _controller = StreamController<Tuple2<dynamic, S>>();
  Stream<Tuple2<dynamic, S>> get stream => _controller.stream;

  A evaluate<A>(State<S, A> state) {
    final next = state(_state.second);
    _state = next;
    _controller.add(next);
    return next.first;
  }

  S execute(State<S, dynamic> state) {
    final next = state(_state.second);
    _state = next;
    _controller.add(next);
    return next.second;
  }

  void close() => _controller.close();
}

/// A state machine for [StateReaderTaskEither].
class StateRTEMachine<S, C, L> {
  StateRTEMachine(this._state, this._context);

  static ReaderTaskEither<C, L, StateRTEMachine<S, C, L>> Function(
      S s) from<S, C, L, R>(
    StateReaderTaskEither<S, C, L, R> srte,
  ) =>
      (s) => srte(s).chain(
          RTE.flatMap((r) => (c) => TE.right(StateRTEMachine<S, C, L>(r, c))));

  Tuple2<dynamic, S> _state;
  Tuple2<dynamic, S> get state => _state;

  final _controller = StreamController<Tuple2<dynamic, S>>(sync: true);
  Stream<Tuple2<dynamic, S>> get stream => _controller.stream;

  final C _context;

  final _queue = Queue<
      Tuple2<StateReaderTaskEither<S, C, L, dynamic>,
          Completer<Either<L, Tuple2<dynamic, S>>>>>();

  var _closed = false;
  bool get closed => _closed;

  Future<Either<L, R>> evaluate<R>(StateReaderTaskEither<S, C, L, R> state) =>
      _maybeRun(state).then(E.map((t) => t.first));

  Future<Either<L, S>> execute<R>(StateReaderTaskEither<S, C, L, R> state) =>
      _maybeRun(state).then(E.map((t) => t.second));

  Future<Either<L, Tuple2<R, S>>> _maybeRun<R>(
      StateReaderTaskEither<S, C, L, R> state) async {
    if (_closed) throw 'closed';

    if (_queue.isNotEmpty) {
      final completer = Completer<Either<L, Tuple2<R, S>>>.sync();
      _queue.add(tuple2(state, completer));
      return completer.future;
    }

    return _run(state);
  }

  Future<Either<L, Tuple2<R, S>>> _run<R>(
      StateReaderTaskEither<S, C, L, R> state) async {
    final result = await state(_state.second)(_context)();

    _state = result.chain(E.fold(
      (_) => _state,
      (r) => r,
    ));
    if (E.isRight(result)) {
      _controller.add(_state);
    }

    _afterRun();

    return result;
  }

  void _afterRun() {
    final isEmpty = _queue.isEmpty;

    if (_closed && isEmpty) {
      _controller.close();
    } else if (!isEmpty) {
      final next = _queue.removeFirst();
      _run(next.first).then(next.second.complete);
    }
  }

  void close() {
    _closed = true;
    _afterRun();
  }
}
