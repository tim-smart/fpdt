import 'package:fpdt/either.dart' as E;
import 'package:fpdt/option.dart' as O;
import 'package:fpdt/task.dart' as T;

export 'package:fpdt/task.dart' show tap, delay, sequence, sequenceSeq;

typedef TaskOption<A> = Future<O.Option<A>> Function();

TaskOption<A> some<A>(A a) => () => Future.value(O.some(a));
TaskOption<A> none<A>() => () => Future.value(O.none());
TaskOption<A> fromNullable<A>(A? a) => () => Future.value(O.fromNullable(a));
TaskOption<A> Function(A? value) fromNullableWith<A>() => fromNullable;

TaskOption<B> Function(TaskOption<A> taskOption) pure<A, B>(B b) =>
    (taskOption) => () => Future.value(O.some(b));

TaskOption<A> fromOption<A>(O.Option<A> option) => () => Future.value(option);

TaskOption<R> fromEither<L, R>(E.Either<L, R> either) =>
    () => Future.value(O.fromEither(either));

TaskOption<A> fromTask<A>(T.Task<A?> task) => () async {
      try {
        return O.fromNullable(await task());
      } catch (_) {
        return O.none();
      }
    };

T.Task<B> Function(TaskOption<A> taskOption) fold<A, B>(
  B Function() onNone,
  B Function(A value) onSome,
) =>
    T.map(O.fold(onNone, onSome));

TaskOption<A> tryCatch<A>(T.Task<A> task) => () async {
      try {
        return O.some(await task());
      } catch (_) {
        return O.none();
      }
    };

TaskOption<B> Function(TaskOption<A> taskOption) flatMap<A, B>(
  TaskOption<B> Function(A value) f,
) =>
    T.flatMap(O.fold(none, f));

TaskOption<A> Function(TaskOption<A> taskOption) alt<A>(
  TaskOption<A> Function() orElse,
) =>
    T.flatMap(O.fold(orElse, some));

TaskOption<A> Function(TaskOption<A> taskOption) orElse<A>(
  TaskOption<A> task,
) =>
    alt(() => task);

T.Task<A> Function(TaskOption<A> taskOption) getOrElse<A>(
  A Function() orElse,
) =>
    T.map(O.getOrElse(orElse));

TaskOption<B> Function(A value) tryCatchK<A, B>(
  Future<B> Function(A value) task,
) =>
    (a) => tryCatch(() => task(a));

TaskOption<B> Function(TaskOption<A> taskOption) chainTryCatchK<A, B>(
  Future<B> Function(A value) task,
) =>
    flatMap(tryCatchK(task));

TaskOption<B> Function(TaskOption<A> taskOption) map<A, B>(
  B Function(A value) f,
) =>
    T.map(O.map(f));

TaskOption<A> Function(TaskOption<A> taskOption) filter<A>(
  bool Function(A value) predicate,
) =>
    T.map(O.filter(predicate));
