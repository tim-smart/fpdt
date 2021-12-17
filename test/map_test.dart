import 'package:fpdt/map.dart';
import 'package:fpdt/option.dart';
import 'package:test/test.dart';

void main() {
  group('lookup', () {
    test('returns some if key exists', () {
      expect({'test': 123}.lookup('test'), some(123));
    });

    test('returns none if key does not exist', () {
      expect({'test': 123}.lookup('foo'), none());
    });
  });

  group('extract', () {
    test('returns some if key exists and type matches', () {
      expect(
        {
          'test': {'foo': 'bar'}
        }.lookup('test').extract<String>('foo'),
        some('bar'),
      );
    });

    test('returns none if key does not exist', () {
      expect({'test': 123}.lookup('foo'), none());
    });
  });

  group('extractMap', () {
    test('returns some if key exists and contains a map', () {
      expect(
        some({
          'test': {'foo': 'bar'}
        }).extractMap('test').extract<String>('foo'),
        some('bar'),
      );
    });

    test('returns none if key does not contain a map', () {
      expect(some({'test': 123}).extractMap('test'), none());
    });
  });
}
