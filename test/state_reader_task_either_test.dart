import 'dart:async';

import 'package:fpdt/fpdt.dart';
import 'package:fpdt/either.dart' as E;
import 'package:fpdt/task_either.dart' as TE;
import 'package:fpdt/state_reader_task_either.dart';
import 'package:test/test.dart';

enum StateEnum {
  one,
  two,
  three,
}

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
  group('put', () {
    test('sets the state', () async {
      final f = put(StateEnum.one);
      final r = await f(StateEnum.two)(kContext)();
      expect(r, E.right(tuple2(null, StateEnum.one)));
    });
  });

  group('modify', () {
    test('updates the state', () async {
      final f = put(StateEnum.one)
          .chain(flatMap((_) => modify((_) => StateEnum.two)));
      final r = await f(StateEnum.three)(kContext)();
      expect(r, E.right(tuple2(null, StateEnum.two)));
    });
  });

  group('ask', () {
    test('sets the type params correctly', () async {
      final rte = ask<StateEnum, Context, String>();
      final r = await rte(StateEnum.one)(kContext)();
      expect(r, E.right(tuple2(kContext, StateEnum.one)));
    });
  });

  group('asks', () {
    test('sets the type params and value correctly', () async {
      final rte = asks((Context c) => c.value);
      final r = await rte(StateEnum.one)(kContext)();
      expect(r, E.right(tuple2(123, StateEnum.one)));
    });
  });

  group('right', () {
    test('resolves to a Right', () async {
      final r = await right(123)(StateEnum.one)(null)();
      expect(r, E.right(tuple2(123, StateEnum.one)));
    });
  });

  group('left', () {
    test('resolves to a Left', () async {
      final r = await left('fail')(StateEnum.one)(null)();
      expect(r, E.left('fail'));
    });
  });

  group('map', () {
    test('transform the value', () async {
      final r = asks((Context c) => c.value).chain(map((a) => a + 1));
      expect(
        await r(StateEnum.one)(kContext)(),
        E.right(tuple2(124, StateEnum.one)),
      );
    });
  });

  group('flatMap', () {
    test('transforms the StateReaderTaskEither', () async {
      final r =
          asks((Context c) => c.value).chain(flatMap((a) => right(a + 1)));
      expect(
        await r(StateEnum.one)(kContext)(),
        E.right(tuple2(124, StateEnum.one)),
      );
    });

    test('resolves left values', () async {
      final r = asks<StateEnum, Context, String, int>((c) => c.value)
          .chain(flatMap((a) => left('fail')));
      expect(
        await r(StateEnum.one)(kContext)(),
        E.left('fail'),
      );
    });
  });

  group('flatMapFirst', () {
    test('runs the computation and discards the result', () async {
      final r =
          asks((Context c) => c.value).chain(flatMapFirst((a) => right(a + 1)));
      expect(
        await r(StateEnum.one)(kContext)(),
        E.right(tuple2(123, StateEnum.one)),
      );
    });

    test('resolves left values', () async {
      final r = asks<StateEnum, Context, String, int>((c) => c.value)
          .chain(flatMapFirst((a) => left('fail')));
      expect(await r(StateEnum.one)(kContext)(), E.left('fail'));
    });
  });

  group('flatMapTaskEither', () {
    test('transforms the ReaderTaskEither', () async {
      final r = asks((Context c) => c.value)
          .chain(flatMapTaskEither((a) => TE.right(a + 1)));
      expect(
        await r(StateEnum.one)(kContext)(),
        E.right(tuple2(124, StateEnum.one)),
      );
    });

    test('resolves left values', () async {
      final r = asks<StateEnum, Context, String, int>((c) => c.value)
          .chain(flatMapTaskEither((a) => TE.left('fail')));
      expect(await r(StateEnum.one)(kContext)(), E.left('fail'));
    });
  });

  group('flatMapFirstTaskEither', () {
    test('runs the computation and discards the result', () async {
      final r = asks((Context c) => c.value)
          .chain(flatMapFirstTaskEither((a) => TE.right(a + 1)));
      expect(await r(StateEnum.one)(kContext)(),
          E.right(tuple2(123, StateEnum.one)));
    });

    test('resolves left values', () async {
      final r = asks<StateEnum, Context, String, int>((c) => c.value)
          .chain(flatMapFirstTaskEither((a) => TE.left('fail')));
      expect(await r(StateEnum.one)(kContext)(), E.left('fail'));
    });
  });

  group('tryCatch', () {
    test('resolves to a right when there is no error', () async {
      final r = await tryCatch(
        (StateEnum s) => (Context c) => c.fetch(),
        (_) => (_) => (err, stack) => 'fail',
      )(StateEnum.one)(kContext)();
      expect(r, E.right(tuple2(123, StateEnum.one)));
    });

    test('resolves to a left when there is an error', () async {
      final r = await tryCatch(
        (StateEnum s) => (Context c) async => throw 'error',
        (s) => (c) => (err, stack) => 'fail',
      )(StateEnum.one)(kContext)();
      expect(r, E.left('fail'));
    });
  });

  group('alt', () {
    test('does nothing on right', () async {
      final r = await right(123).chain(alt((_) => right(-1)))(StateEnum.one)(
          kContext)();
      expect(r, E.right(tuple2(123, StateEnum.one)));
    });

    test('returns the transformed result on left', () async {
      final r = await left('left')
          .chain(alt((i) => right('$i-y')))(StateEnum.one)(kContext)();
      expect(r, E.right(tuple2('left-y', StateEnum.one)));
    });
  });

  group('tryCatchK', () {
    test('runs the function on right', () async {
      final r = await right<StateEnum, Context, String, int>(123)
          .chain(flatMap(tryCatchK(
        (s) => (c) => (i) => c.fetch().then((r) => i + r),
        (s) => (c) => (i) => (err, stack) => 'fail',
      )))(StateEnum.one)(kContext)();

      expect(r, E.right(tuple2(246, StateEnum.one)));
    });

    test('does nothing on left', () async {
      final r = await left('left').chain(flatMap(tryCatchK(
        (s) => (_) => (i) async => i * 2,
        (s) => (_) => (_) => (err, stack) => 'fail',
      )))(StateEnum.one)(kContext)();
      expect(r, E.left('left'));
    });
  });
}