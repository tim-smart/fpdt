typedef Task<R> = Future<R> Function();

Task<A> fromThunk<A>(A Function() f) => () => Future.microtask(f);

Task<A> Function(Task<A> task) delay<A>(Duration d) =>
    (task) => () => Future.delayed(d, task);

Task<R> Function(Task<T> task) map<T, R>(R Function(T value) f) =>
    (t) => () => t().then(f);

Task<B> Function(Task<A> task) flatMap<A, B>(Task<B> Function(A value) f) =>
    (t) => () => t().then((v) => f(v)());

Task<B> Function(Task<A> task) call<A, B>(Task<B> chain) =>
    flatMap((_) => chain);
