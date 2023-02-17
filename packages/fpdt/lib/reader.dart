import 'package:fpdt/fpdt.dart';

class Reader<R, A> {
  Reader(this._f);
  final A Function(R deps) _f;
  A call(R deps) => _f(deps);
}

/// Projects a value from the global context in a Reader
Reader<R, R> ask<R>() => Reader(identity);
Reader<R, A> asks<R, A>(A Function(R r) f) => Reader(f);

Reader<R, A> of<R, A>(A a) => Reader((r) => a);

Reader<R2, A> Function(Reader<R1, A>) local<R1, R2, A>(R1 Function(R2 r) f) =>
    (fa) => Reader((r) => fa(f(r)));

/// [map] transforms the previous computation result using the given function.
Reader<R, B> Function(Reader<R, A>) map<R, A, B>(
  B Function(A a) f,
) =>
    (fa) => Reader((r) => f(fa(r)));

/// Composes computations in sequence, using the return value from the previous
/// computation.
Reader<R, B> Function(Reader<R, A>) flatMap<R, A, B>(
  Reader<R, B> Function(A a) f,
) =>
    (fa) => Reader((r) => f(fa(r))(r));

/// Composes computations in sequence, using the return value from the previous
/// computation, discarding the result.
Reader<R, A> Function(Reader<R, A>) flatMapFirst<R, A>(
  Reader<R, dynamic> Function(A a) f,
) =>
    flatMap((a) => Reader((r) {
          f(a)(r);
          return a;
        }));

Reader<R, A> flatten<R, A>(Reader<R, Reader<R, A>> f) =>
    f.chain(flatMap(identity));
