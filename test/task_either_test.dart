import 'dart:async';

import 'package:fpdt/fpdt.dart';
import 'package:fpdt/either.dart' as E;
import 'package:fpdt/option.dart' as O;
import 'package:fpdt/task.dart' as T;
import 'package:fpdt/task_either.dart' as TE;
import 'package:test/test.dart';

void main() {
  group('right', () {
    test('resolves to a Right', () async {
      final r = await TE.right(123)();
      expect(r, E.right(123));
    });
  });

  group('left', () {
    test('resolves to a Left', () async {
      final r = await TE.left('fail')();
      expect(r, E.left('fail'));
    });
  });

  group('toFuture', () {
    test('resolves to value on right', () async {
      final te = TE.right(123);
      expect(await TE.toFuture(te), 123);
    });

    test('resolves to an error on left', () async {
      final te = TE.left('fail');
      await expectLater(() => TE.toFuture(te), throwsA('fail'));
    });
  });

  group('toFutureVoid', () {
    test('resolves to void on right', () async {
      final c = Completer.sync();
      await TE.right(123).chain(TE.toFutureVoid(c.complete));
      expect(c.isCompleted, false);
    });

    test('resolves to void on left and runs the effect', () async {
      final c = Completer.sync();
      await TE.left('fail').chain(TE.toFutureVoid(c.complete));
      expect(c.isCompleted, true);
    });
  });

  group('fromOption', () {
    test('resolve to a right if some', () async {
      final r = await O.some(123).chain(TE.fromOption(() => ''))();
      expect(r, E.right(123));
    });

    test('resolves to a left if none', () async {
      final r = await O.none().chain(TE.fromOption(() => 'none'))();
      expect(r, E.left('none'));
    });
  });

  group('fromNullable', () {
    test('resolve to a right if non-null', () async {
      final r = await TE.fromNullable(123, () => 'left')();
      expect(r, E.right(123));
    });

    test('resolves to a left if none', () async {
      final r = await TE.fromNullable(null, () => 'left')();
      expect(r, E.left('left'));
    });
  });

  group('fromNullableK', () {
    test('resolve to a right if non-null', () async {
      final r = await 123.chain(TE.fromNullableK(
        (i) => i,
        (i) => 'left',
      ))();
      expect(r, E.right(123));
    });

    test('resolves to a left if none', () async {
      final r = await null.chain(TE.fromNullableK(
        (i) => null,
        (i) => 'left',
      ))();
      expect(r, E.left('left'));
    });
  });

  group('chainNullableK', () {
    test('resolve to a right if non-null', () async {
      final r = await TE.right(123).chain(TE.chainNullableK(
            (i) => i * 2,
            (i) => 'left',
          ))();
      expect(r, E.right(246));
    });

    test('resolves to a left if none', () async {
      final r = await TE.right(null).chain(TE.chainNullableK(
            (i) => null,
            (i) => 'left',
          ))();
      expect(r, E.left('left'));
    });

    test('does nothing if left', () async {
      final r = await TE.left('fail').chain(TE.chainNullableK(
            (i) => i,
            (i) => 'left',
          ))();
      expect(r, E.left('fail'));
    });
  });

  group('fromEither', () {
    test('resolve to a right if right', () async {
      final r = await E.right(123).chain(TE.fromEither)();
      expect(r, E.right(123));
    });

    test('resolves to a left if none', () async {
      final r = await E.left('left').chain(TE.fromEither)();
      expect(r, E.left('left'));
    });
  });

  group('fromTask', () {
    test('resolves to a right', () async {
      final r = await T.value(123).chain(TE.fromTask)();
      expect(r, E.right(123));
    });
  });

  group('fold', () {
    test('returns the onRight result when Right', () async {
      final r = await TE.right(123).chain(TE.fold(
            (l) => 'left',
            (r) => 'right',
          ))();

      expect(r, 'right');
    });

    test('returns the onLeft result when left', () async {
      final r = await TE.left('asdf').chain(TE.fold(
            (l) => 'left',
            (r) => 'right',
          ))();

      expect(r, 'left');
    });
  });

  group('flatMap', () {
    test('returns the transformed result on Right', () async {
      final r = await TE.right(123).chain(TE.flatMap((i) => TE.right(i * 2)))();
      expect(r, E.right(246));
    });

    test('does nothing on left', () async {
      final r =
          await TE.left('left').chain(TE.flatMap((i) => TE.right(i * 2)))();
      expect(r, E.left('left'));
    });
  });

  group('flatMapFirst', () {
    test('runs the function on right, and discards the result', () async {
      final r =
          await TE.right(123).chain(TE.flatMapFirst((i) => TE.right(i * 2)))();
      expect(r, E.right(123));
    });

    test('does not discord left values', () async {
      final r =
          await TE.right(123).chain(TE.flatMapFirst((i) => TE.left('fail')))();
      expect(r, E.left('fail'));
    });

    test('does nothing on left', () async {
      final r = await TE
          .left('left')
          .chain(TE.flatMapFirst((i) => TE.right(i * 2)))();
      expect(r, E.left('left'));
    });
  });

  group('tryCatch', () {
    test('resolves to a right when there is no error', () async {
      final r = await TE.tryCatch(
        () async => 123,
        (err, stack) => 'fail',
      )();
      expect(r, E.right(123));
    });

    test('resolves to a left when there is an error', () async {
      final r = await TE.tryCatch(
        () async => throw 'error',
        (err, stack) => 'fail',
      )();
      expect(r, E.left('fail'));
    });
  });

  group('alt', () {
    test('does nothing on right', () async {
      final r = await TE.right(123).chain(TE.alt((_) => TE.right(-1)))();
      expect(r, E.right(123));
    });

    test('returns the transformed result on left', () async {
      final r = await TE.left('left').chain(TE.alt((i) => TE.right('$i-y')))();
      expect(r, E.right('left-y'));
    });
  });

  group('orElse', () {
    test('does nothing on right', () async {
      final r = await TE.right(123).chain(TE.orElse(TE.right(-1)))();
      expect(r, E.right(123));
    });

    test('returns the transformed result on left', () async {
      final r = await TE.left('left').chain(TE.orElse(TE.right('else')))();
      expect(r, E.right('else'));
    });
  });

  group('getOrElse', () {
    test('returns a task', () async {
      final r = await TE.right(123).chain(TE.getOrElse((_) => -1))();
      expect(r, 123);
    });

    test('returns the fallback on left', () async {
      final r = await TE.left('left').chain(TE.getOrElse((i) => '$i-y'))();
      expect(r, 'left-y');
    });
  });

  group('tryCatchK', () {
    test('runs the function on right', () async {
      final r = await TE.right(123).chain(TE.flatMap(TE.tryCatchK(
            (i) async => i * 2,
            (err, stack) => 'fail',
          )))();
      expect(r, E.right(246));
    });

    test('does nothing on left', () async {
      final r = await TE.left('left').chain(TE.flatMap(TE.tryCatchK(
            (i) async => i * 2,
            (err, stack) => 'fail',
          )))();
      expect(r, E.left('left'));
    });
  });

  group('tryCatchK2', () {
    final task = TE.tryCatchK2(
      (int a, int b) => a > 5 ? a + b : throw 'error',
      (err, stack) => 'fail',
    );

    test('resolves to right on success', () async {
      expect(await task(10, 5)(), E.right(15));
    });

    test('resolves to left on error', () async {
      expect(await task(3, 5)(), E.left('fail'));
    });
  });

  group('chainTryCatchK', () {
    test('runs the function on right', () async {
      final r = await TE.right(123).chain(TE.chainTryCatchK(
            (i) async => i * 2,
            (err, stack) => 'fail',
          ))();
      expect(r, E.right(246));
    });

    test('does nothing on left', () async {
      final r = await TE.left('left').chain(TE.chainTryCatchK(
            (i) async => i * 2,
            (err, stack) => 'fail',
          ))();
      expect(r, E.left('left'));
    });

    test('errors are handled', () async {
      final r = await TE.right(123).chain(TE.chainTryCatchK(
            (i) async => throw 'error',
            (err, stack) => 'fail',
          ))();
      expect(r, E.left('fail'));
    });
  });

  group('map', () {
    test('transforms a right', () async {
      final r = await TE.right(123).chain(TE.map((i) => i * 2))();
      expect(r, E.right(246));
    });

    test('does nothing on left', () async {
      final r = await TE.left('left').chain(TE.map((i) => i * 2))();
      expect(r, E.left('left'));
    });
  });

  group('filter', () {
    test('does nothing if right and predicate passes', () async {
      final r = await TE.right(123).chain(TE.filter(
            (i) => i == 123,
            (i) => 'left',
          ))();
      expect(r, E.right(123));
    });

    test('returns orElse if predicate fails', () async {
      final r = await TE.right(123).chain(TE.filter(
            (i) => i != 123,
            (i) => 'left',
          ))();
      expect(r, E.left('left'));
    });

    test('does nothing on left', () async {
      final r = await TE.left('asdf').chain(TE.filter(
            (i) => i != 123,
            (i) => 'left',
          ))();
      expect(r, E.left('asdf'));
    });
  });
}
