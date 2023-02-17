import 'dart:async';

import 'package:fpdt/fpdt.dart';
import 'package:fpdt/either.dart' as E;
import 'package:fpdt/task_either.dart' as TE;
import 'package:fpdt/reader_task_either.dart';
import 'package:test/test.dart';

class Context {
  const Context({
    required this.value,
    required this.flag,
  });

  final int value;
  final bool flag;

  Future<int> fetch() => Future.value(value);
}

const kContext = Context(flag: true, value: 123);

void main() {
  group('ask', () {
    test('sets the type params correctly', () async {
      final rte = ask<Context, String>();
      final r = await rte(kContext)();
      expect(r, E.right(kContext));
    });
  });

  group('asks', () {
    test('sets the type params and value correctly', () async {
      final rte = asks((Context c) => c.value);
      final r = await rte(kContext)();
      expect(r, E.right(123));
    });
  });

  group('right', () {
    test('resolves to a Right', () async {
      final r = await right(123)(null)();
      expect(r, E.right(123));
    });
  });

  group('left', () {
    test('resolves to a Left', () async {
      final r = await left('fail')(null)();
      expect(r, E.left('fail'));
    });
  });

  group('map', () {
    test('transform the value', () async {
      final r = asks((Context c) => c.value).chain(map((a) => a + 1));
      expect(await r(kContext)(), E.right(124));
    });
  });

  group('flatMap', () {
    test('transforms the ReaderTaskEither', () async {
      final r =
          asks((Context c) => c.value).chain(flatMap((a) => right(a + 1)));
      expect(await r(kContext)(), E.right(124));
    });

    test('resolves left values', () async {
      final r = asks<Context, String, int>((c) => c.value)
          .chain(flatMap((a) => left('fail')));
      expect(await r(kContext)(), E.left('fail'));
    });
  });

  group('flatMapTuple2', () {
    test('appends the result to a tuple', () async {
      final r = asks((Context c) => c.value)
          .chain(flatMapTuple2((a) => right(a + 1)));
      expect(await r(kContext)(), E.right(tuple2(123, 124)));
    });

    test('resolves left values', () async {
      final r = asks<Context, String, int>((c) => c.value)
          .chain(flatMapTuple2((a) => left('fail')));
      expect(await r(kContext)(), E.left('fail'));
    });
  });

  group('flatMapTuple3', () {
    test('appends the result to a tuple', () async {
      final r = asks((Context c) => c.value)
          .chain(flatMapTuple2((a) => right(a + 1)))
          .chain(flatMapTuple3((t) => right(t.second - t.first)));
      expect(await r(kContext)(), E.right(tuple3(123, 124, 1)));
    });
  });

  group('pure', () {
    test('transforms the StateReaderTaskEither', () async {
      final r = asks((Context c) => c.value).chain(pure(124));
      expect(
        await r(kContext)(),
        E.right(124),
      );
    });

    test('does not transform left', () async {
      final r = left('fail').chain(zipRight(left('asdf')));
      expect(
        await r(kContext)(),
        E.left('fail'),
      );
    });
  });

  group('call', () {
    test('transforms the StateReaderTaskEither', () async {
      final r = asks((Context c) => c.value).chain(zipRight(right(124)));
      expect(
        await r(kContext)(),
        E.right(124),
      );
    });

    test('resolves left values', () async {
      final r = asks<Context, String, int>((c) => c.value)
          .chain(zipRight(left('fail')));
      expect(
        await r(kContext)(),
        E.left('fail'),
      );
    });
  });

  group('flatMapFirst', () {
    test('runs the computation and discards the result', () async {
      final r =
          asks((Context c) => c.value).chain(flatMapFirst((a) => right(a + 1)));
      expect(await r(kContext)(), E.right(123));
    });

    test('resolves left values', () async {
      final r = asks<Context, String, int>((c) => c.value)
          .chain(flatMapFirst((a) => left('fail')));
      expect(await r(kContext)(), E.left('fail'));
    });
  });

  group('flatMapTaskEither', () {
    test('transforms the ReaderTaskEither', () async {
      final r = asks((Context c) => c.value)
          .chain(flatMapTaskEither((a) => TE.right(a + 1)));
      expect(await r(kContext)(), E.right(124));
    });

    test('resolves left values', () async {
      final r = asks<Context, String, int>((c) => c.value)
          .chain(flatMapTaskEither((a) => TE.left('fail')));
      expect(await r(kContext)(), E.left('fail'));
    });
  });

  group('flatMapFirstTaskEither', () {
    test('runs the computation and discards the result', () async {
      final r = asks((Context c) => c.value)
          .chain(flatMapFirstTaskEither((a) => TE.right(a + 1)));
      expect(await r(kContext)(), E.right(123));
    });

    test('resolves left values', () async {
      final r = asks<Context, String, int>((c) => c.value)
          .chain(flatMapFirstTaskEither((a) => TE.left('fail')));
      expect(await r(kContext)(), E.left('fail'));
    });
  });

  group('tryCatch', () {
    test('resolves to a right when there is no error', () async {
      final r = await tryCatch(
        () => Future.value(123),
        (err, stack) => 'fail',
      )(kContext)();
      expect(r, E.right(123));
    });

    test('resolves to a left when there is an error', () async {
      final r = await tryCatch(
        () async => throw 'error',
        (err, stack) => 'fail',
      )(kContext)();
      expect(r, E.left('fail'));
    });
  });

  group('alt', () {
    test('does nothing on right', () async {
      final r = await right(123).chain(alt((_) => right(-1)))(kContext)();
      expect(r, E.right(123));
    });

    test('returns the transformed result on left', () async {
      final r = await left('left').chain(alt((i) => right('$i-y')))(kContext)();
      expect(r, E.right('left-y'));
    });
  });

  group('tryCatchK', () {
    test('runs the function on right', () async {
      final r = await right<Context, String, int>(123).chain(flatMap(tryCatchK(
        (i) => i * 2,
        (err, stack) => 'fail',
      )))(kContext)();

      expect(r, E.right(246));
    });

    test('does nothing on left', () async {
      final r = await left('left').chain(flatMap(tryCatchK(
        (i) async => i * 2,
        (err, stack) => 'fail',
      )))(kContext)();
      expect(r, E.left('left'));
    });
  });

  group('Do', () {
    test('returns right on success', () async {
      final result = await Do<Context, String, int>(($, context) async {
        return $(right(123));
      })(kContext)();
      expect(result, E.right(123));
    });

    test('returns left on failure', () async {
      final result = await Do<Context, String, int>(($, context) async {
        await $(left("fail"));
        return $(right(123));
      })(kContext)();
      expect(result, E.left("fail"));
    });
  });
}
