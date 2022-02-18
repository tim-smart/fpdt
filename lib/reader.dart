import 'package:fpdt/fpdt.dart';

typedef Reader<R, A> = A Function(R deps);

/// Projects a value from the global context in a Reader
Reader<R, R> ask<R>() => identity;
Reader<R, A> asks<R, A>(A Function(R r) f) => f;

Reader<R, A> of<R, A>(A a) => (r) => a;

Reader<R2, A> Function(Reader<R1, A>) local<R1, R2, A>(R1 Function(R2 r) f) =>
    (fa) => (r) => fa(f(r));

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

Reader<R, A> flatten<R, A>(Reader<R, Reader<R, A>> f) =>
    f.chain(flatMap(identity));
