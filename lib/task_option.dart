import 'package:fpdt/function.dart';
import 'package:fpdt/option.dart' as O;
import 'package:fpdt/task.dart' as T;

export 'package:fpdt/task.dart' show delay;

typedef TaskOption<A> = T.Task<O.Option<A>>;

TaskOption<A> some<A>(A a) => () => Future.value(O.some(a));
TaskOption<A> none<A>() => () => Future.value(O.none());
TaskOption<A> fromNullable<A>(A? a) => () => Future.value(O.fromNullable(a));

TaskOption<B> Function(TaskOption<A> taskOption) pure<A, B>(B b) =>
    (taskOption) => () => Future.value(O.some(b));

TaskOption<A> fromOption<A>(O.Option<A> option) => () => Future.value(option);

TaskOption<A> Function(T.Task<A?> task) fromTask<A>() =>
    (task) => task.chain(T.map(O.fromNullable));

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
    (taskOption) => () => taskOption().then((o) => o.chain(O.fold(
          O.none,
          (a) => f(a)(),
        )));

TaskOption<A> Function(TaskOption<A> taskOption) orElse<A>(
  TaskOption<A> Function() orElse,
) =>
    (taskOption) => () => taskOption().then((o) => o.chain(O.fold(
          () => orElse()(),
          O.some,
        )));

T.Task<A> Function(TaskOption<A> taskOption) getOrElse<A>(
  A Function() orElse,
) =>
    (taskOption) => () => taskOption().then((o) => o.chain(O.fold(
          orElse,
          identity,
        )));

TaskOption<B> Function(A value) tryCatchK<A, B>(
  Future<B> Function(A value) task,
) =>
    (a) => tryCatch(() => task(a));

TaskOption<B> Function(TaskOption<A> taskOption) map<A, B>(
  B Function(A value) f,
) =>
    (taskOption) => () => taskOption().then((o) => o.chain(O.map(f)));

TaskOption<A> Function(TaskOption<A> taskOption) filter<A>(
  bool Function(A value) predicate,
) =>
    flatMap((a) => predicate(a) ? some(a) : none());
