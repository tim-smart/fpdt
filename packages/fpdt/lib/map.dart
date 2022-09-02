import 'package:fpdt/fpdt.dart';
import 'package:fpdt/option.dart';

extension MapExtension<K, V> on Map<K, V> {
  /// Return an [Option] that conditionally accesses map keys.
  ///
  /// ```
  /// expect(
  ///   { 'test': 123 }.lookup('test'),
  ///   some(123),
  /// );
  /// expect(
  ///   { 'test': 123 }.lookup('foo'),
  ///   none(),
  /// );
  /// ```
  Option<V> lookup(K key) => fromNullable(this[key]);
}

extension MapOptionExtension<K> on Option<Map<K, dynamic>> {
  /// Return an [Option] that conditionally accesses map keys, if they match the
  /// given type.
  /// Useful for accessing nested JSON.
  ///
  /// ```
  /// expect(
  ///   some({ 'test': 123 }).extract<int>('test'),
  ///   some(123),
  /// );
  /// ```
  Option<T> extract<T>(K key) => chain(flatMap((map) {
        final value = map[key];
        if (value is T) return some(value);
        return none();
      }));

  /// Return an [Option] that conditionally accesses map keys, if they contain a map
  /// with the same key type.
  /// Useful for accessing nested JSON.
  ///
  /// ```
  /// expect(
  ///   some({ 'test': { 'foo': 'bar' } }).extractMap('test'),
  ///   some({ 'foo': 'bar' }),
  /// );
  /// ```
  Option<Map<K, dynamic>> extractMap(K key) => extract<Map<K, dynamic>>(key);
}
