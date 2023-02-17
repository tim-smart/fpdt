import 'package:fpdt/fpdt.dart';
import 'package:fpdt/task.dart' as T;

class ReaderTask<R, A> {
  ReaderTask(this._task);
  final Task<A> Function(R deps) _task;
  Task<A> call(R deps) => _task(deps);
}

/// Projects a value from the global context in a [ReaderTask].
ReaderTask<R, R> ask<R>() => ReaderTask((R r) => T.value(r));

/// Projects a value from the global context in a [ReaderTask].
ReaderTask<R, A> asks<R, A>(Reader<R, A> f) => ReaderTask((r) => T.value(f(r)));

ReaderTask<R, A> fromReader<R, A>(Reader<R, A> f) => asks(f);

ReaderTask<R, A> fromTask<R, A>(Task<A> task) => ReaderTask((r) => task);

ReaderTask<R, B> Function(ReaderTask<R, A> task) zipRight<R, A, B>(
  ReaderTask<R, B> task,
) =>
    flatMap((_) => task);

/// [map] transforms the previous computation result using the given function.
ReaderTask<R, B> Function(ReaderTask<R, A>) map<R, A, B>(
  B Function(A a) f,
) =>
    (fa) => ReaderTask(fa.call.compose(T.map(f)));

/// [tap] transforms the previous computation result using the given function.
ReaderTask<R, A> Function(ReaderTask<R, A>) tap<R, A>(
  void Function(A a) f,
) =>
    (fa) => ReaderTask(fa.call.compose(T.tap(f)));

/// [flatMap] transforms the previous computation result using the given function.
ReaderTask<R, B> Function(ReaderTask<R, A>) flatMap<R, A, B>(
  ReaderTask<R, B> Function(A a) f,
) =>
    (fa) => ReaderTask((r) => fa(r).chain(T.flatMap((a) => f(a)(r))));

ReaderTask<R, B> Function(ReaderTask<R, A>) flatMapReader<R, A, B>(
  Reader<R, B> Function(A a) f,
) =>
    flatMap(f.compose(fromReader));

ReaderTask<R, B> Function(ReaderTask<R, A>) flatMapTask<R, A, B>(
  Task<B> Function(A a) f,
) =>
    flatMap(f.compose(fromTask));
