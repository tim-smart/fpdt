import 'package:fpdt/option.dart';

extension IterableExtension<T> on Iterable<T> {
  /// Returns the first element as an [Option].
  /// If the list is empty, it will return [None].
  Option<T> get head => isEmpty ? kNone : some(first);

  /// Returns the first element as an [Option].
  /// If the list is empty, it will return [None].
  Option<T> get firstOption => isEmpty ? kNone : some(first);

  /// Returns all the of elements except the first.
  Option<Iterable<T>> get tail => isEmpty ? kNone : some(skip(1));

  /// Returns all the of elements except the last.
  Option<Iterable<T>> get init => isEmpty ? kNone : some(take(length - 1));

  /// Returns the last element as an [Option].
  /// If the list is empty, it will return [None].
  Option<T> get lastOption => isEmpty ? kNone : some(last);

  /// Get the element at the given `index` as an [Option].
  /// If the element does not exist, it will return [None].
  Option<T> elementAtOption(int index) => tryCatch(() => elementAt(index));

  /// Returns a new iterable with the given element appended to the end.
  Iterable<T> append(T t) => followedBy([t]);

  /// Returns a new iterable with the given element prepended to the start.
  Iterable<T> prepend(T t) => [t].followedBy(this);
}
