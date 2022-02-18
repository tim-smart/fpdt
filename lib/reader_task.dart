import 'package:fpdt/fpdt.dart';
import 'package:fpdt/task.dart' as T;

typedef ReaderTask<R, A> = Task<A> Function(R);

/// Projects a value from the global context in a [ReaderTask].
ReaderTask<R, R> ask<R, E>() => (R r) => T.value(r);

/// Projects a value from the global context in a [ReaderTask].
ReaderTask<R, A> asks<R, E, A>(A Function(R r) f) => (r) => T.value(f(r));

ReaderTask<R, A> fromTask<R, A>(Task<A> task) => (r) => task;

/// [map] transforms the previous computation result using the given function.
ReaderTask<R, B> Function(ReaderTask<R, A>) map<R, A, B>(
  B Function(A a) f,
) =>
    (fa) => fa.compose(T.map(f));

/// [tap] transforms the previous computation result using the given function.
ReaderTask<R, A> Function(ReaderTask<R, A>) tap<R, A>(
  void Function(A a) f,
) =>
    (fa) => fa.compose(T.tap(f));

/// [flatMap] transforms the previous computation result using the given function.
ReaderTask<R, B> Function(ReaderTask<R, A>) flatMap<R, A, B>(
  ReaderTask<R, B> Function(A a) f,
) =>
    (fa) => (r) => fa(r).chain(T.flatMap((a) => f(a)(r)));

ReaderTask<R, B> Function(ReaderTask<R, A>) flatMapTask<R, A, B>(
  Task<B> Function(A a) f,
) =>
    flatMap(f.compose(fromTask));
