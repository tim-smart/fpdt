T identity<T>(T value) => value;

extension ChainExtension<T> on T {
  R chain<R>(R Function(T value) transform) => transform(this);
}

extension ComposeExtension<A, B> on B Function(A) {
  C Function(A a) compose<C>(C Function(B b) f) => (a) => f(this.call(a));
}
