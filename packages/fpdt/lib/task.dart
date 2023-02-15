import 'dart:async';

import 'package:fpdt/fpdt.dart';

/// Type alias representing a [Task]. It is a lazy future - a function that
/// returns a [FutureOr].
typedef Task<A> = FutureOr<A> Function();

/// Create a [Task] that wraps the given value.
Task<A> value<A>(A value) => () => value;

/// Create a [Task] from a thunk / lazy value. A thunk is a function without
/// arguments that returns a value.
///
/// ```
/// expect(await fromThunk(() => 'hello')(), equals('hello'));
/// ```
Task<A> fromThunk<A>(Lazy<A> f) => f;

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
    (t) => () => t().flatMap(f);

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
    (t) => () => t().flatMap((v) => f(v)());

/// Runs the returned [Task], but resolves to the result of the previous task.
/// I.e. discards the result.
///
/// ```
/// expect(
///   await fromThunk(() => 'hi')
///       .chain(flatMapFirst((s) => fromThunk(() => s.toUpperCase())))(),
///   equals('hi'),
/// );
/// ```
Task<A> Function(Task<A> task) flatMapFirst<A>(
  Task<dynamic> Function(A value) f,
) =>
    (t) => () => t().flatMap((v) => f(v)().flatMap((_) => v));

/// Perform a side effect on the value of a [Task].
///
/// ```
/// expect(
///   await fromThunk(() => 'hi').chain(tap(print))(),
///   equals('hi'),
/// );
/// ```
Task<A> Function(Task<A> task) tap<A>(FutureOr<void> Function(A value) f) =>
    flatMapFirst((a) => value(f(a)));

Task<B> Function(Task<A> task) call<A, B>(Task<B> chain) =>
    flatMap((_) => chain);

Task<IList<B>> Function(Iterable<A>) traverseIterableSeq<A, B>(
  Task<B> Function(A a) f,
) =>
    (as) => () => as.fold(
          IList(),
          (acc, a) => acc.flatMap((bs) => f(a)().flatMap((b) => bs.add(b))),
        );

Task<IList<B>> Function(Iterable<A>) traverseIterable<A, B>(
  Task<B> Function(A a) f,
) =>
    (as) => () =>
        Future.wait(as.map((a) => Future.sync(f(a)))).then((bs) => IList(bs));

/// Returns a task that maps an [Iterable] of [Task]'s, into a list of results.
///
/// The tasks are run in parallel.
///
/// ```
/// expect(
///   await [fromThunk(() => 'one'), fromThunk(() => 'two')]
///     .chain(sequence)(),
///   ['one', 'two'],
/// );
/// ```
Task<IList<A>> sequence<A>(
  Iterable<Task<A>> tasks,
) =>
    tasks.chain(traverseIterable(identity));

/// Returns a task the flattens an [Iterable] of [Task]'s, into a list of results.
///
/// The tasks are run sequentially - one after the other.
///
/// ```
/// expect(
///   await [fromThunk(() => 'one'), fromThunk(() => 'two')]
///     .chain(sequenceSeq)(),
///   ['one', 'two'],
/// );
/// ```
Task<IList<A>> sequenceSeq<A>(Iterable<Task<A>> tasks) =>
    tasks.chain(traverseIterableSeq(identity));
