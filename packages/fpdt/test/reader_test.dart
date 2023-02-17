import 'package:fpdt/fpdt.dart';
import 'package:fpdt/reader.dart';
import 'package:test/test.dart';

class Context {
  const Context({
    required this.value,
    required this.flag,
  });

  final int value;
  final bool flag;
}

const kContext = Context(flag: true, value: 123);

void main() {
  group('ask', () {
    test('creates a reader that returns the context', () {
      final r = ask<Context>();
      expect(r(kContext).value, 123);
    });
  });

  group('map', () {
    test('transforms the value', () {
      final r = ask<Context>().chain(map((_) => 1));
      expect(r(kContext), 1);
    });
  });

  group('flatMap', () {
    test('transforms the reader', () {
      final r =
          ask<Context>().chain(flatMap((_) => Reader((c) => c.value + 1)));
      expect(r(kContext), 124);
    });
  });

  group('flatMapFirst', () {
    test('runs the computation and discards the result', () {
      final r =
          ask<Context>().chain(flatMapFirst((_) => Reader((c) => c.value + 1)));
      expect(r(kContext).value, 123);
    });
  });
}
