import 'package:fpdt/function.dart';

/// Type alias representing a [Task]. It is a lazy future - a function that
/// returns a [Future].
typedef Task<A> = Future<A> Function();

/// Create a [Task] from a thunk / lazy value. A thunk is a function without
/// arguments that returns a value.
///
/// ```
/// expect(await fromThunk(() => 'hello')(), equals('hello'));
/// ```
Task<A> fromThunk<A>(Lazy<A> f) => () => Future.microtask(f);

/// Pause execution of the task by the given [Duration].
Task<A> Function(Task<A> task) delay<A>(Duration d) =>
    (task) => () => Future.delayed(d, task);

/// Transform the value of a [Task] with the provided function.
///
/// ```
/// expect(
///   await fromThunk(() => 'hi').chain(map((str) => str.toUpperCase()))(),
///   equals('HI'),
/// );
/// ```
Task<R> Function(Task<T> task) map<T, R>(R Function(T value) f) =>
    (t) => () => t().then(f);

/// Perform a side effect on the value of a [Task].
///
/// ```
/// expect(
///   await fromThunk(() => 'hi').chain(tap(print))(),
///   equals('hi'),
/// );
/// ```
Task<A> Function(Task<A> task) tap<A>(void Function(A value) f) => map((a) {
      f(a);
      return a;
    });

/// Transforms a value from a [Task] into another [Task], then flattens the result.
///
/// ```
/// expect(
///   await fromThunk(() => 'hi')
///       .chain(flatMap((s) => fromThunk(() => s.toUpperCase())))(),
///   equals('HI'),
/// );
/// ```
Task<B> Function(Task<A> task) flatMap<A, B>(Task<B> Function(A value) f) =>
    (t) => () => t().then((v) => f(v)());

Task<B> Function(Task<A> task) call<A, B>(Task<B> chain) =>
    flatMap((_) => chain);

Task<List<A>> sequence<A>(
  Iterable<Task<A>> tasks,
) =>
    () => Future.wait(tasks.map((f) => f()));

Task<List<A>> sequenceSeq<A>(Iterable<Task<A>> tasks) => () => tasks.fold(
      Future.sync(() => []),
      (acc, task) => acc.then((list) => task().then((a) => [...list, a])),
    );
