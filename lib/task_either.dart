import 'package:fpdt/either.dart' as E;
import 'package:fpdt/function.dart';
import 'package:fpdt/option.dart' as O;
import 'package:fpdt/task.dart' as T;

export 'package:fpdt/task.dart' show delay;

typedef TaskEither<L, R> = T.Task<E.Either<L, R>>;

TaskEither<L, R> right<L, R>(R a) => () => Future.value(E.right(a));
TaskEither<L, R> left<L, R>(L a) => () => Future.value(E.left(a));

Future<R> toFuture<R>(TaskEither<dynamic, R> taskEither) =>
    taskEither.chain(fold(
      (l) => throw l,
      identity,
    ))();

TaskEither<L, R2> Function(TaskEither<L, R> taskEither) pure<L, R, R2>(R2 a) =>
    (taskEither) => () => Future.value(E.right(a));

TaskEither<L, R> Function(O.Option<R> option) fromOption<L, R>(
  L Function() onNone,
) =>
    (option) => () => Future.value(option.chain(O.toEither(onNone)));

TaskEither<L, R> fromEither<L, R>(E.Either<L, R> either) =>
    () => Future.value(either);

TaskEither<L, R> Function(T.Task<R> task) fromTask<L, R>(
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
    (task) => () async {
          try {
            return E.right(await task());
          } catch (err, stack) {
            return E.left(onError(err, stack));
          }
        };

T.Task<A> Function(TaskEither<L, R> taskEither) fold<L, R, A>(
  A Function(L left) onLeft,
  A Function(R right) onRight,
) =>
    (taskEither) =>
        () => taskEither().then((e) => e.chain(E.fold(onLeft, onRight)));

TaskEither<L, R> tryCatch<L, R>(
  T.Task<R> task,
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
    task.chain(fromTask(onError));

TaskEither<L, R2> Function(TaskEither<L, R> taskEither) flatMap<L, R, R2>(
  TaskEither<L, R2> Function(R value) f,
) =>
    (taskEither) => () => taskEither().then((e) => e.chain(E.fold(
          E.left,
          (r) => f(r)(),
        )));

TaskEither<L, R> Function(TaskEither<L, R> taskEither) alt<L, R>(
  TaskEither<L, R> Function(L left) orElse,
) =>
    (taskEither) => () => taskEither().then((e) => e.chain(E.fold(
          (l) => orElse(l)(),
          E.right,
        )));

T.Task<R> Function(TaskEither<L, R> taskEither) getOrElse<L, R>(
  R Function(L left) orElse,
) =>
    (taskEither) => () => taskEither().then((e) => e.chain(E.fold(
          orElse,
          identity,
        )));

TaskEither<L, R2> Function(R value) tryCatchK<L, R, R2>(
  Future<R2> Function(R value) task,
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
    (r) => tryCatch(() => task(r), onError);

TaskEither<L, R2> Function(TaskEither<L, R> taskEither)
    chainTryCatchK<L, R, R2>(
  Future<R2> Function(R value) task,
  L Function(dynamic err, StackTrace stackTrace) onError,
) =>
        flatMap((r) => tryCatch(() => task(r), onError));

TaskEither<L, R2> Function(TaskEither<L, R> taskEither) map<L, R, R2>(
  R2 Function(R value) f,
) =>
    (taskEither) => () => taskEither().then((e) => e.chain(E.map(f)));

TaskEither<L, R> Function(TaskEither<L, R> taskEither) filter<L, R>(
  bool Function(R value) predicate,
  L Function(R value) orElse,
) =>
    flatMap((r) => predicate(r) ? right(r) : left(orElse(r)));
