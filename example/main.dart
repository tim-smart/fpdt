import 'package:fpdt/fpdt.dart';
import 'package:fpdt/either.dart' as E;
import 'package:fpdt/option.dart' as O;

void main() async {
  // A function that validates that a string starts with 'hello', after doing some
  // sanitization.
  String? validateHelloImperative(String? s) {
    if (s == null) return null;

    s = s.trim();
    if (s.isEmpty) return null;

    if (!s.startsWith('hello')) return null;

    return '$s - valid!';
  }

  assert(validateHelloImperative('   hello!') == 'hello! - valid!');
  assert(validateHelloImperative('   hi!') == null);
  assert(validateHelloImperative('   ') == null);
  assert(validateHelloImperative(null) == null);

  // A functional version using Option and chain.
  Option<String> validateHelloFunctional(String? s) => O
      .fromNullable(s)
      .chain(O.map((s) => s.trim()))
      .chain(O.filter((s) => s.isNotEmpty))
      .chain(O.filter((s) => s.startsWith('hello')))
      .chain(O.map((s) => '$s - valid!'));

  assert(validateHelloFunctional('   hello!') == O.some('hello! - valid!'));
  assert(validateHelloFunctional('   hi!') == O.none());
  assert(validateHelloFunctional('   ') == O.none());
  assert(validateHelloFunctional(null) == O.none());

  // A functional version using composition.
  // Creating small re-usable functions.
  final maybeString = O
      .fromNullableWith<String>()
      .compose(O.map((s) => s.trim()))
      .compose(O.filter((s) => s.isNotEmpty));

  final maybeHelloString =
      maybeString.compose(O.filter((s) => s.startsWith('hello')));

  final validateHelloCompose =
      maybeHelloString.compose(O.map((s) => '$s - valid!'));

  assert(validateHelloCompose('   hello!') == O.some('hello! - valid!'));
  assert(validateHelloCompose('   hi!') == O.none());
  assert(validateHelloCompose('   ') == O.none());
  assert(validateHelloCompose(null) == O.none());

  // We can then use our `maybeString` function to do other things, like
  // optionally parsing int's.
  final maybeInt = maybeString.compose(O.chainNullableK(int.tryParse));

  assert(maybeInt('123') == O.some(123));
  assert(maybeInt('hello') == O.none());
  assert(maybeInt(null) == O.none());

  // === Either

  // Here is another version of `validateHelloImperative` that throws
  // exceptions.
  String validateHelloImperativeE(String? s) {
    if (s == null) throw ArgumentError.notNull();

    s = s.trim();
    if (s.isEmpty) throw ArgumentError.value(s, 's');

    if (!s.startsWith('hello')) throw ArgumentError.value(s);

    return '$s - valid!';
  }

  assert(validateHelloImperativeE('    hello') == 'hello - valid!');

  // The following would crash our program, unless we wrap it in a try catch.
  // Because try {} catch (e) {} is optional, errors may not be handled correctly.
  // assert(validateHelloImperativeE(null) == 'hello - valid!');

  // Here is a functional equivilent using [Either].
  Either<ArgumentError, String> validateHelloFunctionalE(String? s) => E
      // If the string was null, the result of `orElse` function will be wrapped
      // in a Left and returned.
      //
      // If the string was present, the value will be wrapped in a Right and
      // returned.
      .fromNullable(s, () => ArgumentError.notNull('s'))
      .chain(E.map((s) => s.trim()))
      // If the filter predicate (function that returns a bool) fails, then
      // the second argument will determine the Left value.
      .chain(E.filter(
        (s) => s.isNotEmpty,
        (s) => ArgumentError.value(s, 's', 'was empty'),
      ))
      .chain(E.filter(
        (s) => s.startsWith('hello'),
        (s) => ArgumentError.value(s, 's', 'does not start with hello'),
      ))
      .chain(E.map((s) => '$s - valid!'));

  // It is similar to the Option version, but allows us handle errors very
  // concisely. It also forces us to handles errors correctly.
  assert(validateHelloFunctionalE('    hello') == E.right('hello - valid!'));
  assert(validateHelloFunctionalE('    hello')
          .chain(E.getOrElse((left) => 'Error was: $left')) ==
      'hello - valid!');
  assert(validateHelloFunctionalE(null)
          .chain(E.getOrElse((left) => 'Error was: $left')) ==
      'Error was: Invalid argument(s) (s): Must not be null');

  // A version using composition
  final maybeStringE = E
      .fromNullableWith<ArgumentError, String>(
          () => ArgumentError.notNull('string'))
      .compose(E.map((s) => s.trim()))
      .compose(E.filter(
        (s) => s.isNotEmpty,
        (s) => ArgumentError.value(s, 's', 'was empty'),
      ));
  final maybeHelloStringE = maybeStringE.compose(E.filter(
    (s) => s.startsWith('hello'),
    (s) => ArgumentError.value(s, 's', 'does not start with hello'),
  ));
  final validateHelloComposeE =
      maybeHelloStringE.compose(E.map((s) => '$s - valid!'));

  assert(validateHelloComposeE('   hello') == E.right('hello - valid!'));
  assert(E.isLeft(validateHelloComposeE(null)) == true);

  // And an Either version of our maybeInt function
  final maybeIntE = maybeStringE.compose(E.chainNullableK(
    int.tryParse,
    (s) => ArgumentError.value(s, 's', 'did not contain an int'),
  ));
  assert(maybeIntE('    1234 ') == E.right(1234));
}
