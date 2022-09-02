import 'package:fpdt/fpdt.dart';
import 'package:fpdt/either.dart' as E;
import 'package:fpdt/option.dart' as O;
import 'package:fpdt/task.dart' as T;
import 'package:fpdt/task_option.dart' as TO;
import 'package:test/test.dart';

void main() {
  group('some', () {
    test('resolves to a Some', () async {
      final r = await TO.some(123)();
      expect(r, O.some(123));
    });
  });

  group('none', () {
    test('resolves to a None', () async {
      final r = await TO.none()();
      expect(r, O.none());
    });
  });

  group('fromNullable', () {
    test('resolve to a some if non-null', () async {
      final r = await TO.fromNullable(123)();
      expect(r, O.some(123));
    });

    test('resolves to a none if null', () async {
      final r = await TO.fromNullable(null)();
      expect(r, O.none());
    });
  });

  group('chainNullable', () {
    test('resolve to a some if non-null', () async {
      final r = await TO.some(123).chain(TO.chainNullable)();
      expect(r, O.some(123));
    });

    test('resolves to a none if null', () async {
      final r = await TO.some(null).chain(TO.chainNullable)();
      expect(r, O.none());
    });

    test('does nothing if none', () async {
      final r = await TO.none().chain(TO.chainNullable)();
      expect(r, O.none());
    });
  });

  group('fromNullableK', () {
    final transform = TO.fromNullableK((int i) => i > 5 ? i : null);

    test('resolve to a some if non-null', () async {
      final r = await transform(10)();
      expect(r, O.some(10));
    });

    test('resolves to a none if null', () async {
      final r = await transform(3)();
      expect(r, O.none());
    });
  });

  group('chainNullableK', () {
    final transform = TO.chainNullableK((int i) => i > 5 ? i : null);

    test('resolve to a some if non-null', () async {
      final r = await TO.some(10).chain(transform)();
      expect(r, O.some(10));
    });

    test('resolves to a none if null', () async {
      final r = await TO.some(3).chain(transform)();
      expect(r, O.none());
    });
  });

  group('fromOption', () {
    test('resolve to a some if some', () async {
      final r = await O.some(123).chain(TO.fromOption)();
      expect(r, O.some(123));
    });

    test('resolves to a none if none', () async {
      final r = await O.none().chain(TO.fromOption)();
      expect(r, O.none());
    });
  });

  group('fromEither', () {
    test('resolve to a some if right', () async {
      final r = await E.right(123).chain(TO.fromEither)();
      expect(r, O.some(123));
    });

    test('resolves to a none if left', () async {
      final r = await E.left('left').chain(TO.fromEither)();
      expect(r, O.none());
    });
  });

  group('fromTask', () {
    test('resolves to a some', () async {
      final r = await T.value(123).chain(TO.fromTask)();
      expect(r, O.some(123));
    });
  });

  group('fold', () {
    test('returns the onSome result when some', () async {
      final r = await TO.some(123).chain(TO.fold(
            () => 'none',
            (r) => 'some',
          ))();

      expect(r, 'some');
    });

    test('returns the onNone result when none', () async {
      final r = await TO.none().chain(TO.fold(
            () => 'none',
            (r) => 'some',
          ))();

      expect(r, 'none');
    });
  });

  group('flatMap', () {
    test('returns the transformed result on Some', () async {
      final r = await TO.some(123).chain(TO.flatMap((i) => TO.some(i * 2)))();
      expect(r, O.some(246));
    });

    test('does nothing on None', () async {
      final r = await TO.none().chain(TO.flatMap((i) => TO.some(i * 2)))();
      expect(r, O.none());
    });
  });

  group('flatMapTuple2', () {
    test('appends the result to a tuple2', () async {
      final r =
          await TO.some(123).chain(TO.flatMapTuple2((i) => TO.some(i * 2)))();
      expect(r, O.some(tuple2(123, 246)));
    });
  });

  group('flatMapTuple3', () {
    test('appends the result to a tuple', () async {
      final r = await TO
          .some(123)
          .chain(TO.flatMapTuple2((i) => TO.some(i * 2)))
          .chain(TO.flatMapTuple3((a) => TO.some(a.second - a.first)))();
      expect(r, O.some(tuple3(123, 246, 123)));
    });
  });

  group('flatMapFirst', () {
    test('runs the task then returns the result of the first', () async {
      final r =
          await TO.some(123).chain(TO.flatMapFirst((i) => TO.some(i * 2)))();
      expect(r, O.some(123));
    });

    test('preserves none values', () async {
      final r = await TO.some(123).chain(TO.flatMapFirst((i) => TO.none()))();
      expect(r, O.none());
    });

    test('does nothing on None', () async {
      final r = await TO.none().chain(TO.flatMapFirst((i) => TO.some(i * 2)))();
      expect(r, O.none());
    });
  });

  group('tryCatch', () {
    test('resolves to a some when there is no error', () async {
      final r = await TO.tryCatch(() async => 123)();
      expect(r, O.some(123));
    });

    test('resolves to a none when there is an error', () async {
      final r = await TO.tryCatch(() async => throw 'error')();
      expect(r, O.none());
    });
  });

  group('alt', () {
    test('does nothing on some', () async {
      final r = await TO.some(123).chain(TO.alt(() => TO.some(-1)))();
      expect(r, O.some(123));
    });

    test('returns the transformed result on none', () async {
      final r = await TO.none().chain(TO.alt(() => TO.some('some')))();
      expect(r, O.some('some'));
    });
  });

  group('orElse', () {
    test('does nothing on some', () async {
      final r = await TO.some(123).chain(TO.orElse(TO.some(-1)))();
      expect(r, O.some(123));
    });

    test('returns the transformed result on left', () async {
      final r = await TO.none().chain(TO.orElse(TO.some('else')))();
      expect(r, O.some('else'));
    });
  });

  group('getOrElse', () {
    test('returns a task', () async {
      final r = await TO.some(123).chain(TO.getOrElse(() => -1))();
      expect(r, 123);
    });

    test('returns the fallback on none', () async {
      final r = await TO.none().chain(TO.getOrElse(() => 'hi'))();
      expect(r, 'hi');
    });
  });

  group('tryCatchK', () {
    test('runs the function on some', () async {
      final r = await TO
          .some(123)
          .chain(TO.flatMap(TO.tryCatchK((i) async => i * 2)))();
      expect(r, O.some(246));
    });

    test('does nothing on none', () async {
      final r =
          await TO.none().chain(TO.flatMap(TO.tryCatchK((i) async => i * 2)))();
      expect(r, O.none());
    });

    test('errors are handled', () async {
      final r = await TO
          .some(123)
          .chain(TO.flatMap(TO.tryCatchK((i) async => throw 'error')))();
      expect(r, O.none());
    });
  });

  group('chainTryCatchK', () {
    test('runs the function on some', () async {
      final r =
          await TO.some(123).chain(TO.chainTryCatchK((i) async => i * 2))();
      expect(r, O.some(246));
    });

    test('does nothing on none', () async {
      final r = await TO.none().chain(TO.chainTryCatchK((i) async => i * 2))();
      expect(r, O.none());
    });

    test('errors are handled', () async {
      final r = await TO
          .some(123)
          .chain(TO.chainTryCatchK((i) async => throw 'error'))();
      expect(r, O.none());
    });
  });

  group('map', () {
    test('transforms a some', () async {
      final r = await TO.some(123).chain(TO.map((i) => i * 2))();
      expect(r, O.some(246));
    });

    test('does nothing on none', () async {
      final r = await TO.none().chain(TO.map((i) => i * 2))();
      expect(r, O.none());
    });
  });

  group('filter', () {
    test('does nothing if some and predicate passes', () async {
      final r = await TO.some(123).chain(TO.filter((i) => i == 123))();
      expect(r, O.some(123));
    });

    test('returns none if predicate fails', () async {
      final r = await TO.some(123).chain(TO.filter((i) => i != 123))();
      expect(r, O.none());
    });

    test('does nothing on none', () async {
      final r = await TO.none().chain(TO.filter((i) => i != 123))();
      expect(r, O.none());
    });
  });

  group('sequence', () {
    test('runs the tasks in parallel', () async {
      final input = [1, 2, 3, null, 5];
      final multiplier =
          TO.fromNullableWith<int>().compose(TO.map((i) => i * 2));

      final result = await TO.sequence(input.map(multiplier))();

      expect(result, [
        O.some(2),
        O.some(4),
        O.some(6),
        O.none(),
        O.some(10),
      ]);
    });
  });

  group('sequenceSeq', () {
    test('runs the tasks in sequence', () async {
      var taskTwoComplete = false;

      final result = await TO.sequenceSeq([
        TO
            .some(1)
            .chain(TO.delay(const Duration(milliseconds: 5)))
            .chain(TO.tap((i) => expect(taskTwoComplete, false))),
        TO.some(2).chain(TO.tap((i) => taskTwoComplete = true)),
      ])();

      expect(result, [
        O.some(1),
        O.some(2),
      ]);
    });
  });
}
