import 'package:flutter/foundation.dart';
import 'package:fpdt/either.dart' as Ei;
import 'package:fpdt/fpdt.dart';
import 'package:fpdt/option.dart' as O;

/// Represent the different states of an async operation.
/// Is [Left] when there was an error.
/// The tuple includes a boolean indicating the loading state.
typedef TaskEitherValue<L, R> = Either<L, Tuple2<Option<R>, bool>>;

TaskEitherValue<L, R> fromEither<L, R>(
  Either<L, R> either, {
  bool loading = false,
}) =>
    either.p(Ei.map((r) => tuple2(O.some(r), loading)));

TaskEitherValue<L, B> Function(TaskEitherValue<L, A> tev) map<L, A, B>(
  B Function(A a) f,
) =>
    Ei.map((t) => tuple2(t.first.p(O.map(f)), t.second));

TaskEitherValue<L, R> asLoading<L, R>(
  TaskEitherValue<L, R> tev,
) =>
    tev.p(Ei.map((t) => t.withItem2(true)));

TaskEitherValue<L, R> putData<L, R>(
  TaskEitherValue<L, R> tev,
  R data,
) =>
    tev.p(Ei.map((t) => t.withItem1(O.some(data))));

TaskEitherValue<L, R> asComplete<L, R>(
  TaskEitherValue<L, R> tev,
) =>
    tev.p(Ei.map((t) => t.withItem2(false)));

Option<R> toOption<R>(
  TaskEitherValue<dynamic, R> tev,
) =>
    tev.p(O.fromEither).p(O.flatMap((t) => t.first));

Either<L, R> Function(TaskEitherValue<L, R> tev) toEither<L, R>(
  L Function() onNone,
) =>
    Ei.flatMap((t) => t.first.p(Ei.fromOption(onNone)));

Future<Either<L, R>> withValueNotifier<L, R>(
  ValueNotifier<TaskEitherValue<L, R>> notifier,
  TaskEither<L, R> task,
) async {
  notifier.value = asLoading(notifier.value);
  final either = await task();
  notifier.value = fromEither(either);
  return either;
}
