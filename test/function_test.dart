import 'package:fpdt/function.dart';
import 'package:fpdt/option.dart' as O;
import 'package:test/test.dart';

void main() {
  group('compose', () {
    test('can compose functions together', () {
      final g = O
          .map((int i) => i * 2)
          .compose(O.flatMap((i) => O.some(i + 2)))
          .compose(O.filter((i) => i > 3))
          .compose(O.toNullable);

      expect(g(O.some(1)), 4);
      expect(g(O.some(0)), null);
    });

    test('various arities', () {
      int zero() => 0;
      int one(int a) => a;
      int two(int a, int b) => a + b;
      int three(int a, int b, int c) => a + b + c;
      int four(int a, int b, int c, int d) => a + b + c + d;

      expect(zero.compose((a) => a + 1)(), 1);
      expect(one.compose(identity)(1), 1);
      expect(two.compose(identity)(1, 1), 2);
      expect(three.compose(identity)(1, 1, 1), 3);
      expect(four.compose(identity)(1, 1, 1, 1), 4);
    });

    test('multiple artity 3', () {
      String addPrint(String name, int a, int b) =>
          'Result for $name: ${a + b}';

      final g = addPrint
          .compose(O.fromPredicateK((s) => s.contains('4')))
          .compose(O.map((s) => '$s - it was four!'))
          .compose(O.toNullable);

      expect(g('first call', 1, 3), 'Result for first call: 4 - it was four!');
      expect(g('second call', 1, 2), null);
    });

    test('optional named parameters', () {
      int test(int a, {int b = 1}) => a + b;
      expect(test.compose(identity)(1), 2);
    });
  });

  group('chain', () {
    test('can pass values into functions', () {
      final r = O
          .some(1)
          .chain(O.map((int i) => i * 2))
          .chain(O.flatMap((i) => O.some(i + 2)))
          .chain(O.filter((i) => i > 3))
          .chain(O.toNullable);

      expect(r, 4);
    });
  });
}
