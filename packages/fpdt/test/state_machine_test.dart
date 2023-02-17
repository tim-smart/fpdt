import 'package:fpdt/fpdt.dart';
import 'package:fpdt/state.dart';
import 'package:test/test.dart';

enum StateEnum {
  one,
  two,
  three,
}

void main() {
  group('basic', () {
    test('example', () {
      final s = StateMachine(StateEnum.one);
      expect(s.state, StateEnum.one);

      s.evaluate(put(StateEnum.two));
      expect(s.state, StateEnum.two);

      expect(s.evaluate(State((_) => tuple2(123, StateEnum.three))), 123);
      expect(s.state, StateEnum.three);
    });
  });

  group('stream', () {
    test('emits new states', () {
      final s = StateMachine(StateEnum.one);
      expect(
        s.stream,
        emitsInOrder([
          StateEnum.two,
          StateEnum.three,
          emitsDone,
        ]),
      );

      s.evaluate(put(StateEnum.two));
      s.evaluate(State((_) => tuple2(123, StateEnum.three)));
      s.close();
    });
  });
}
