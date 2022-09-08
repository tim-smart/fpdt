import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdt/fpdt.dart';
import 'package:fpdt/either.dart' as E;
import 'package:fpdt/option.dart' as O;

extension AsyncValueFpdt<A> on AsyncValue<A> {
  Option<A> get option => maybeWhen(data: O.some, orElse: O.none);

  Either<dynamic, Option<A>> get either => when(
        data: (a) => E.right(O.some(a)),
        error: (err, stack) => E.left(err),
        loading: () => E.right(O.none()),
      );
}
