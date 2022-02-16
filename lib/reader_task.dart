import 'package:fpdt/fpdt.dart';
import 'package:fpdt/task.dart' as T;

typedef ReaderTask<R, A> = Task<A> Function(R);

/// Projects a value from the global context in a [ReaderTask].
ReaderTask<R, R> ask<R, E>() => (R r) => T.value(r);

/// Projects a value from the global context in a [ReaderTask].
ReaderTask<R, A> asks<R, E, A>(A Function(R r) f) => (r) => T.value(f(r));

/// [map] transforms the previous computation result using the given function.
ReaderTask<R, B> Function(ReaderTask<R, A>) map<R, A, B>(
  B Function(A a) f,
) =>
    (fa) => (r) => fa(r).chain(T.map(f));

/// [flatMap] transforms the previous computation result using the given function.
ReaderTask<R, B> Function(ReaderTask<R, A>) flatMap<R, A, B>(
  ReaderTask<R, B> Function(A a) f,
) =>
    (fa) => (r) => fa(r).chain(T.flatMap((a) => f(a)(r)));
