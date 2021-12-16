import 'package:fpdt/either.dart' as E;
import 'package:test/test.dart';

void main() {
  group('fromPredicateK', () {
    final transform = E.fromPredicateK(
      (int number) => number > 1,
      (_) => 'number too small',
    );

    test('returns Right if predicate passes', () {
      expect(transform(2), E.right(2));
    });

    test('returns left for predicate fails', () {
      expect(transform(0), E.left('number too small'));
    });
  });
}
