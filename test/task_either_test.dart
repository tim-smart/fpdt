import 'package:fp_dart/function.dart';
import 'package:fp_dart/either.dart' as E;
import 'package:fp_dart/option.dart' as O;
import 'package:fp_dart/task.dart' as T;
import 'package:fp_dart/task_either.dart' as TE;
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
    test('resolve to a right if no error', () async {
      final r = await T
          .fromThunk(() => 123)
          .chain(TE.fromTask((err, stack) => 'fail'))();

      expect(r, E.right(123));
    });

    test('resolves to a left on error', () async {
      final r = await T
          .fromThunk(() => throw 'error')
          .chain(TE.fromTask((err, stack) => 'fail'))();

      expect(r, E.left('fail'));
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

  group('orElse', () {
    test('does nothing on right', () async {
      final r = await TE.right(123).chain(TE.orElse((_) => TE.right(-1)))();
      expect(r, E.right(123));
    });

    test('returns the transformed result on left', () async {
      final r =
          await TE.left('left').chain(TE.orElse((i) => TE.right('$i-y')))();
      expect(r, E.right('left-y'));
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

    test('errors are handled', () async {
      final r = await TE.right(123).chain(TE.flatMap(TE.tryCatchK(
            (i) async => throw 'error',
            (err, stack) => 'fail',
          )))();
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
