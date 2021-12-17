import 'package:fpdt/option.dart';

extension IterableExtension<T> on Iterable<T> {
  Option<T> get head => isEmpty ? kNone : some(first);

  Option<Iterable<T>> get tail => isEmpty ? kNone : some(skip(1));

  Option<Iterable<T>> get init => isEmpty ? kNone : some(take(length - 1));

  Option<T> get lastOption => isEmpty ? kNone : some(last);

  Option<T> elementAtOption(int index) => tryCatch(() => elementAt(index));

  Iterable<T> plus(Iterable<T> l) => [...this, ...l];

  Iterable<T> append(T t) => [...this, t];

  Iterable<T> prepend(T t) => [t, ...this];
}
