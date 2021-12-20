import 'package:fpdt/iterable.dart';
import 'package:fpdt/option.dart';
import 'package:test/test.dart';

void main() {
  group('firstOption', () {
    test('returns some if not empty', () {
      expect([1, 2, 3].firstOption, some(1));
    });

    test('returns none if empty', () {
      expect([].firstOption, none());
    });
  });

  group('firstWhereOption', () {
    test('returns some if predicate passes', () {
      expect([1, 2, 3].firstWhereOption((i) => i == 2), some(2));
    });

    test('returns none if not found', () {
      expect([1, 2, 3].firstWhereOption((i) => i == 4), none());
    });
  });
}
