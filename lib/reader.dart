import 'package:fpdt/fpdt.dart';

typedef Reader<R, A> = A Function(R deps);

/// Projects a value from the global context in a Reader
Reader<R, R> ask<R>() => identity;
Reader<R, A> asks<R, A>(A Function(R r) f) => f;

/// [map] transforms the previous computation result using the given function.
Reader<R, B> Function(Reader<R, A>) map<R, A, B>(
  B Function(A a) f,
) =>
    (fa) => (r) => f(fa(r));

/// Composes computations in sequence, using the return value from the previous
/// computation.
Reader<R, B> Function(Reader<R, A>) flatMap<R, A, B>(
  Reader<R, B> Function(A a) f,
) =>
    (fa) => (r) => f(fa(r))(r);

/// Composes computations in sequence, using the return value from the previous
/// computation, discarding the result.
Reader<R, A> Function(Reader<R, A>) flatMapFirst<R, A>(
  Reader<R, dynamic> Function(A a) f,
) =>
    flatMap((a) => (r) {
          f(a)(r);
          return a;
        });
