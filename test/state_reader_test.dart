import 'package:fpdt/fpdt.dart';
import 'package:fpdt/option.dart' as O;
import 'package:fpdt/state_reader.dart' as SR;
import 'package:test/test.dart';

enum GumballState { unpaid, paid }

class GumballConfig {
  const GumballConfig({
    required this.modifier,
  });

  final double modifier;
}

StateReader<GumballState, GumballConfig, Option<String>> pay(int amount) =>
    (s) => (c) => (amount * c.modifier) >= 50
        ? tuple2(O.none(), GumballState.paid)
        : tuple2(kNone, s);

StateReader<GumballState, GumballConfig, Option<String>> turn() =>
    (s) => (c) => s == GumballState.paid
        ? tuple2(O.some("Gumball"), GumballState.unpaid)
        : tuple2(kNone, s);

void main() {
  group('flatMap', () {
    test('', () {
      final program = pay(5)
          .chain(SR.flatMap((_) => turn()))
          .chain(SR.flatMap((_) => pay(25)))
          .chain(SR.flatMap((a) {
        expect(a, kNone);
        return turn();
      })).chain(SR.flatMap((a) {
        expect(a, O.some('Gumball'));
        return turn();
      }));

      final result =
          program(GumballState.unpaid)(const GumballConfig(modifier: 2));
      expect(result.first, kNone);
      expect(result.second, GumballState.unpaid);
    });
  });

  group('sequence', () {
    test('runs the states in order', () {
      final result = SR.sequence([
        pay(5),
        turn(),
        pay(25),
        turn(),
        turn(),
      ])(GumballState.unpaid)(const GumballConfig(modifier: 2));

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
