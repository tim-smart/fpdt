import 'package:fpdt/fpdt.dart';
import 'package:fpdt/option.dart' as O;
import 'package:fpdt/state.dart' as S;
import 'package:test/test.dart';

enum GumballState { unpaid, paid }

State<GumballState, Option<String>> pay(int amount) => (s) =>
    amount >= 50 ? tuple2(O.none(), GumballState.paid) : tuple2(kNone, s);

State<GumballState, Option<String>> turn() => (s) => s == GumballState.paid
    ? tuple2(O.some("Gumball"), GumballState.unpaid)
    : tuple2(kNone, s);

void main() {
  group('flatMap', () {
    test('', () {
      final program = pay(5)
          .chain(S.flatMap((_) => turn()))
          .chain(S.flatMap((_) => pay(50)))
          .chain(S.flatMap((a) {
        expect(a, kNone);
        return turn();
      })).chain(S.flatMap((a) {
        expect(a, O.some('Gumball'));
        return turn();
      }));

      final result = program(GumballState.unpaid);
      expect(result.first, kNone);
      expect(result.second, GumballState.unpaid);
    });
  });

  group('sequence', () {
    test('runs the states in order', () {
      final result = S.sequence([
        pay(5),
        turn(),
        pay(50),
        turn(),
        turn(),
      ])(GumballState.unpaid);

      expect(
        result.first,
        IList([
          kNone,
          kNone,
          kNone,
          O.some("Gumball"),
          kNone,
        ]),
      );
      expect(result.second, GumballState.unpaid);
    });
  });
}
