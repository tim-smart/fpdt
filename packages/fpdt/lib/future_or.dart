import 'dart:async';

extension FlatMapExtension<T> on FutureOr<T> {
  FutureOr<B> flatMap<B>(
    FutureOr<B> Function(T a) f, {
    B Function(dynamic err, StackTrace stack)? onError,
  }) {
    if (this is Future) {
      return (this as Future<T>).then(f, onError: onError);
    } else {
      try {
        return f(this as T);
      } catch (err, stack) {
        return onError?.call(err, stack) as dynamic;
      }
    }
  }
}
