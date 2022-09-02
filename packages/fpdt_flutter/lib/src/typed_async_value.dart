import 'package:flutter/material.dart';
import 'package:fpdt/fpdt.dart';
import 'package:fpdt/either.dart' as Ei;
import 'package:fpdt/option.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'typed_async_value.freezed.dart';

@freezed
class TypedAsyncValue<E, A> with _$TypedAsyncValue<E, A> {
  const TypedAsyncValue._();

  const factory TypedAsyncValue.none() = TypedAsyncValueNone<E, A>;
  const factory TypedAsyncValue.loading({
    @Default(kNone) Option<A> data,
  }) = TypedAsyncValueLoading<E, A>;
  const factory TypedAsyncValue.error(E error) = TypedAsyncValueError<E, A>;
  const factory TypedAsyncValue.data(A data) = TypedAsyncValueData<E, A>;

  Option<A> get dataOption => maybeWhen(
        data: some,
        loading: identity,
        orElse: none,
      );

  Option<E> get errorOption => maybeWhen(
        error: some,
        orElse: none,
      );

  bool get isLoading => maybeWhen(
        loading: (_) => true,
        orElse: () => false,
      );

  TypedAsyncValue<E, A> asLoading() =>
      TypedAsyncValue.loading(data: dataOption);

  factory TypedAsyncValue.fromEither(
    Either<E, A> either,
  ) =>
      either
          .p(Ei.fold(TypedAsyncValue<E, A>.error, TypedAsyncValue<E, A>.data));

  static Future<TypedAsyncValue<E, A>> fromFuture<E, A>(
    Future<Either<E, A>> future,
  ) =>
      future.then(TypedAsyncValue.fromEither);

  static Future<Either<E, A>> withValueNotifier<E, A>(
    ValueNotifier<TypedAsyncValue<E, A>> notifier,
    Lazy<Future<Either<E, A>>> future,
  ) async {
    notifier.value = TypedAsyncValue.loading(data: notifier.value.dataOption);
    final e = await future();
    notifier.value = TypedAsyncValue.fromEither(e);
    return e;
  }
}
