import 'dart:async';

import 'package:fpdt/either.dart' as E;
import 'package:fpdt/fpdt.dart';
import 'package:fpdt/reader_task_either.dart' as RTE;
import 'package:fpdt/state_reader_task_either.dart';
import 'package:test/test.dart';

enum StateEnum {
  one,
  two,
  three,
  four,
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
  group('basic', () {
    test('example', () async {
      final s = StateRTEMachine(StateEnum.one, kContext);
      expect(s.state, StateEnum.one);

      final r = await s.evaluate(put(StateEnum.two));
      expect(s.state, StateEnum.two);
      expect(r, E.right(null));

      expect(
        await s.evaluate((_) => RTE.right(tuple2(123, StateEnum.three))),
        E.right(123),
      );
      expect(s.state, StateEnum.three);
    });
  });

  group('stream', () {
    test('emits new states', () async {
      final s = StateRTEMachine(StateEnum.one, kContext);
      expect(
        s.stream,
        emitsInOrder([
          StateEnum.two,
          StateEnum.three,
          StateEnum.four,
          emitsDone,
        ]),
      );

      s.evaluate(put(StateEnum.two));
      s.evaluate(put(StateEnum.three));
      await s.evaluate((_) => RTE.right(tuple2(123, StateEnum.four)));
      s.close();
    });
  });

  group('sequence', () {
    test('emits new states', () async {
      final s = StateRTEMachine(StateEnum.one, kContext);
      expect(
        s.stream,
        emitsInOrder([
          StateEnum.two,
          StateEnum.three,
          StateEnum.four,
          emitsDone,
        ]),
      );

      expect(
        await s.sequence([
          put(StateEnum.two),
          put(StateEnum.three),
          (_) => RTE.right(tuple2(123, StateEnum.four)),
        ]),
        E.right(const IListConst([
          Tuple2(null, StateEnum.two),
          Tuple2(null, StateEnum.three),
          Tuple2(123, StateEnum.four),
        ])),
      );

      s.close();
    });
  });
}
