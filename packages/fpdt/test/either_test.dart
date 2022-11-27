import 'package:fpdt/either.dart' as E;
import 'package:fpdt/fpdt.dart';
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

  group('fromNullable', () {
    test('returns right for non nullable values', () {
      expect(E.fromNullable('hello', () => 'null'), E.right('hello'));
    });

    test('returns left for nullable values', () {
      expect(E.fromNullable(null, () => 'null'), E.left('null'));
    });
  });

  group('fromNullableK', () {
    final transform = E.fromNullableK(
      (int i) => i < 1 ? null : i.toStringAsFixed(2),
      (i) => '$i was less than one',
    );

    test('returns right for non nullable values', () {
      expect(transform(2), E.right('2.00'));
    });

    test('returns left for nullable values', () {
      expect(transform(0), E.left('0 was less than one'));
    });
  });

  group('chainNullableK', () {
    test('returns right for non nullable values', () {
      expect(
        E.right(2).chain(E.chainNullableK(
              (i) => i < 1 ? null : i.toStringAsFixed(2),
              (i) => '$i was less than one',
            )),
        E.right('2.00'),
      );
    });

    test('returns left for nullable values', () {
      expect(
        E.right(0).chain(E.chainNullableK(
              (i) => i < 1 ? null : i.toStringAsFixed(2),
              (i) => '$i was less than one',
            )),
        E.left('0 was less than one'),
      );
    });
  });

  group('Do', () {
    test('returns right on success', () {
      final a = E.Do<String, int>(($) {
        return $(E.right(123));
      });

      expect(a, E.right(123));
    });

    test('returns left on failure', () {
      final a = E.Do<String, int>(($) {
        $(E.left("fail"));
        return $(E.right(123));
      });

      expect(a, E.left("fail"));
    });
  });
}
