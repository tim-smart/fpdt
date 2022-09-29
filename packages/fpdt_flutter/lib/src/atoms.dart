import 'package:flutter_nucleus/flutter_nucleus.dart';
import 'package:fpdt/either.dart' as E;
import 'package:fpdt/fpdt.dart';
import 'package:fpdt/option.dart' as O;

typedef TaskEitherValue<L, R> = Either<L, Tuple2<Option<R>, bool>>;

typedef TaskEitherAtom<L, R> = AtomWithParent<TaskEitherValue<L, R>,
    WritableAtom<Future<Either<L, R>>, void>>;

TaskEitherAtom<L, R> taskEitherAtom<L, R>(
  AtomReader<Future<Either<L, R>>> create,
) =>
    atomWithParent(
      atomWithRefresh(create),
      (get, parent) {
        bool disposed = false;
        get.onDispose(() => disposed = true);

        get(parent).then((value) {
          if (disposed) return;
          get.setSelf(value.p(E.map((a) => tuple2(O.some(a), false))));
        });

        final prev = get.self()?.p(E.map((t) => t.withItem2(true)));
        return prev ?? E.right(tuple2(kNone, true));
      },
    );
