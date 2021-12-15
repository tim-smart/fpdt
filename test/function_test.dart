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
