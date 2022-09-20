import 'package:flutter_nucleus/flutter_nucleus.dart';
import 'package:fpdt/fpdt.dart';
import 'package:fpdt/either.dart' as E;
import 'package:fpdt/option.dart' as O;

extension FutureValueFpdt<A> on FutureValue<A> {
  Option<A> get dataOption => O.fromNullable(dataOrNull);

  Either<dynamic, Option<A>> get either => when(
        data: (a) => E.right(O.some(a)),
        error: (err, stack) => E.left(err),
        loading: (data) => E.right(dataOption),
      );
}
