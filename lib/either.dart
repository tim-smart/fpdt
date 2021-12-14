import 'package:fpdt/function.dart';
import 'package:fpdt/option.dart' as O;

Either<L, R> left<L, R>(L value) => Left(value);
Either<L, R> right<L, R>(R value) => Right(value);

T Function(Either<L, R> either) fold<L, R, T>(
  T Function(L left) ifLeft,
  T Function(R right) ifRight,
) =>
    (either) => either._fold(ifLeft, ifRight);

Either<NL, NR> Function(Either<L, R> either) foldEither<L, R, NL, NR>(
  Either<NL, NR> Function(Left<L, R> left) ifLeft,
  Either<NL, NR> Function(Right<L, R> right) ifRight,
) =>
    (either) => either._foldEither(ifLeft, ifRight);

bool isLeft<L, R>(Either<L, R> either) => either._isLeft();
bool isRight<L, R>(Either<L, R> either) => either._isRight();

Either<R, L> swap<L, R>(Either<L, R> either) => either._fold(right, left);

Either<L, NR> Function(Either<L, R> either) map<L, R, NR>(
  NR Function(R value) f,
) =>
    fold(left, (r) => right(f(r)));

Either<L, NR> Function(Either<L, R> either) flatMap<L, R, NR>(
  Either<L, NR> Function(R value) f,
) =>
    fold(left, f);

Either<dynamic, R> tryCatch<R>(R Function() f) {
  try {
    return right(f());
  } catch (err) {
    return left(err);
  }
}

Either<L, R> Function(Either<L, R> either) alt<L, R>(
  Either<L, R> Function(L left) orElse,
) =>
    (e) => e._fold(orElse, right);

R Function(Either<L, R> either) getOrElse<L, R>(
  R Function(L left) orElse,
) =>
    (e) => e._fold(orElse, identity);

Either<L, R> Function(Either<L, R> either) filter<L, R>(
  bool Function(R right) predicate,
  L Function(R left) orElse,
) =>
    (e) => e._foldEither(
          identity,
          (r) => predicate(r.value) ? r : left(orElse(r.value)),
        );

Either<L, R> Function(O.Option<R> option) fromOption<L, R>(
  L Function() onNone,
) =>
    O.fold(() => left(onNone()), right);

abstract class Either<L, R> {
  const Either();

  T _fold<T>(T Function(L left) ifLeft, T Function(R value) ifRight);
  Either<NL, NR> _foldEither<NL, NR>(
    Either<NL, NR> Function(Left<L, R> left) ifLeft,
    Either<NL, NR> Function(Right<L, R> right) ifRight,
  );
  bool _isLeft();
  bool _isRight();
}

class Left<L, R> extends Either<L, R> {
  const Left(this.value);
  final L value;

  @override
  T _fold<T>(T Function(L left) ifLeft, T Function(R value) ifRight) =>
      ifLeft(value);

  @override
  Either<NL, NR> _foldEither<NL, NR>(
    Either<NL, NR> Function(Left<L, R> left) ifLeft,
    Either<NL, NR> Function(Right<L, R> right) ifRight,
  ) =>
      ifLeft(this);

  @override
  bool _isLeft() => true;

  @override
  bool _isRight() => false;

  @override
  String toString() => 'Left($value)';

  @override
  bool operator ==(other) => other is Left && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class Right<L, R> extends Either<L, R> {
  const Right(this.value);
  final R value;

  @override
  T _fold<T>(T Function(L left) ifLeft, T Function(R value) ifRight) =>
      ifRight(value);

  @override
  Either<NL, NR> _foldEither<NL, NR>(
    Either<NL, NR> Function(Left<L, R> left) ifLeft,
    Either<NL, NR> Function(Right<L, R> right) ifRight,
  ) =>
      ifRight(this);

  @override
  bool _isLeft() => false;

  @override
  bool _isRight() => true;

  @override
  String toString() => 'Right($value)';

  @override
  bool operator ==(other) => other is Right && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
