import 'package:fpdt/option.dart';

extension FpdtIterableExtension<T> on Iterable<T> {
  Option<T> get head => isEmpty ? none() : some(first);

  Option<Iterable<T>> get tail => isEmpty ? none() : some(skip(1));

  Option<Iterable<T>> get init => isEmpty ? none() : some(take(length - 1));

  Option<T> get lastOption => isEmpty ? none() : some(last);

  Iterable<T> plus(Iterable<T> l) => [...this, ...l];

  Iterable<T> append(T t) => [...this, t];

  Iterable<T> prepend(T t) => [t, ...this];
}
