import 'dart:async';

import 'package:fpdt/fpdt.dart';
import 'package:fpdt/task.dart';
import 'package:test/test.dart';

void main() {
  group('map', () {
    test('transforms the value', () async {
      expect(
        await fromThunk(() => 'hi').chain(map((str) => str.toUpperCase()))(),
        equals('HI'),
      );
    });
  });

  group('tap', () {
    test('performs a side effect', () async {
      final c = Completer<String>.sync();
      expect(
        await fromThunk(() => 'hi').chain(tap(c.complete))(),
        equals('hi'),
      );
      expect(await c.future, 'hi');
    });
  });

  group('flatMap', () {
    test('transforms the task', () async {
      expect(
        await fromThunk(() => 'hi')
            .chain(flatMap((s) => fromThunk(() => s.toUpperCase())))(),
        equals('HI'),
      );
    });
  });
}
