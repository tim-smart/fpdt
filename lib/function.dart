/// Represents a lazy value, which is a value returned from a function without
/// arguments.
typedef Lazy<A> = A Function();

/// A functions that directly returns whatever was given to it.
T identity<T>(T value) => value;

/// Return a [Lazy] version of `value`.
Lazy<A> lazy<A>(A value) => () => value;

extension ChainExtension<T> on T {
  /// Pass the value into the given function.
  ///
  /// ```
  /// 123.chain(print);
  /// // is the same as
  /// print(123);
  /// ```
  R chain<R>(R Function(T value) f) => f(this);

  /// [p]ipe the value into the given function.
  ///
  /// ```
  /// 123.p(print);
  /// // is the same as
  /// print(123);
  /// ```
  R p<R>(R Function(T value) f) => f(this);
}

extension ComposeExtension0<A> on A Function() {
  /// Compose two functions together
  ///
  /// ```
  /// add.compose(print);
  /// // is the same as
  /// () => print(add());
  /// ```
  B Function() compose<B>(B Function(A a) f) => () => f(this());

  /// [c]ompose two functions together
  ///
  /// ```
  /// add.c(print);
  /// // is the same as
  /// () => print(add());
  /// ```
  B Function() c<B>(B Function(A a) f) => () => f(this());
}

extension ComposeExtension1<A, B> on B Function(A) {
  /// Compose two functions together
  ///
  /// ```
  /// add.compose(print);
  /// // is the same as
  /// () => print(add());
  /// ```
  C Function(A a) compose<C>(C Function(B b) f) => (a) => f(this(a));

  /// [c]ompose two functions together
  ///
  /// ```
  /// add.c(print);
  /// // is the same as
  /// () => print(add());
  /// ```
  C Function(A a) c<C>(C Function(B b) f) => (a) => f(this(a));
}

extension ComposeExtension2<A, B, C> on C Function(A, B) {
  /// Compose two functions together
  ///
  /// ```
  /// add.compose(print);
  /// // is the same as
  /// () => print(add());
  /// ```
  D Function(A a, B b) compose<D>(D Function(C c) f) => (a, b) => f(this(a, b));

  /// [c]ompose two functions together
  ///
  /// ```
  /// add.c(print);
  /// // is the same as
  /// () => print(add());
  /// ```
  D Function(A a, B b) c<D>(D Function(C c) f) => (a, b) => f(this(a, b));
}

extension ComposeExtension3<A, B, C, D> on D Function(A, B, C) {
  /// Compose two functions together
  ///
  /// ```
  /// add.compose(print);
  /// // is the same as
  /// () => print(add());
  /// ```
  E Function(A a, B b, C c) compose<E>(E Function(D d) f) =>
      (a, b, c) => f(this(a, b, c));

  /// [c]ompose two functions together
  ///
  /// ```
  /// add.c(print);
  /// // is the same as
  /// () => print(add());
  /// ```
  E Function(A a, B b, C c) c<E>(E Function(D d) f) =>
      (a, b, c) => f(this(a, b, c));
}

extension ComposeExtension4<A, B, C, D, E> on E Function(A, B, C, D) {
  /// Compose two functions together
  ///
  /// ```
  /// add.compose(print);
  /// // is the same as
  /// () => print(add());
  /// ```
  F Function(A a, B b, C c, D d) compose<F>(F Function(E e) f) =>
      (a, b, c, d) => f(this(a, b, c, d));

  /// [c]ompose two functions together
  ///
  /// ```
  /// add.c(print);
  /// // is the same as
  /// () => print(add());
  /// ```
  F Function(A a, B b, C c, D d) c<F>(F Function(E e) f) =>
      (a, b, c, d) => f(this(a, b, c, d));
}
