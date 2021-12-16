import 'package:fpdt/function.dart';
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
  O.Option<String> validateHelloFunctional(String? s) => O
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
}
