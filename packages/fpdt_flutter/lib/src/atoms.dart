import 'dart:async';

import 'package:flutter_nucleus/flutter_nucleus.dart';
import 'package:fpdt/either.dart' as E;
import 'package:fpdt/fpdt.dart';
import 'package:fpdt/option.dart' as O;
import 'package:fpdt_flutter/fpdt_flutter.dart';

typedef TaskEitherAtom<L, R>
    = AtomWithParent<TaskEitherValue<L, R>, Atom<FutureOr<Either<L, R>>>>;

TaskEitherAtom<L, R> taskEitherAtom<L, R>(
  AtomReader<FutureOr<Either<L, R>>> create,
) =>
    atomWithParent(
      atom(create),
      (get, parent) {
        bool disposed = false;
        get.onDispose(() => disposed = true);

        final result = get(parent).flatMap((value) {
          if (disposed) return;
          get.setSelf(value.p(E.map((a) => tuple2(O.some(a), false))));
        });

        if (result is Future) {
          final prev = get.self()?.p(E.map((t) => t.withItem2(true)));
          return prev ?? E.right(tuple2(kNone, true));
        }

        return get.self() ?? E.right(tuple2(kNone, true));
      },
    );
