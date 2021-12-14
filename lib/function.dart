T identity<T>(T value) => value;

extension ChainExtension<T> on T {
  R chain<R>(R Function(T value) transform) => transform(this);
}
