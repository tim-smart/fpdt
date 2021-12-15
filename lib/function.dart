typedef Lazy<A> = A Function();

T identity<T>(T value) => value;

extension ChainExtension<T> on T {
  R chain<R>(R Function(T value) transform) => transform(this);
}

extension ComposeExtension0<A> on A Function() {
  B Function() compose<B>(B Function(A a) f) => () => f(this.call());
}

extension ComposeExtension1<A, B> on B Function(A) {
  C Function(A a) compose<C>(C Function(B b) f) => (a) => f(this.call(a));
}

extension ComposeExtension2<A, B, C> on C Function(A, B) {
  D Function(A a, B b) compose<D>(D Function(C c) f) =>
      (a, b) => f(this.call(a, b));
}

extension ComposeExtension3<A, B, C, D> on D Function(A, B, C) {
  E Function(A a, B b, C c) compose<E>(E Function(D d) f) =>
      (a, b, c) => f(this.call(a, b, c));
}

extension ComposeExtension4<A, B, C, D, E> on E Function(A, B, C, D) {
  F Function(A a, B b, C c, D d) compose<F>(F Function(E e) f) =>
      (a, b, c, d) => f(this.call(a, b, c, d));
}
