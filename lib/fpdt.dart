library fpdt;

// Expose the primitive types, and any common functions.
// Specific monads should be imported seperate, and aliased if desired.
//
// ```
// import 'package:fpdt/fpdt.dart';
// import 'package:fpdt/option.dart' as O;
// ```

// Common functions and helpers
export 'function.dart';
export 'iterable.dart';
export 'map.dart';
export 'tuple.dart';
export 'unit.dart';

// Primitive types
export 'either.dart' show Either, Left, Right;
export 'option.dart' show Option, Some, None, kNone;
export 'task_either.dart' show TaskEither;
export 'task_option.dart' show TaskOption;
export 'task.dart' show Task;

// Immutable data types
export 'package:fast_immutable_collections/fast_immutable_collections.dart';
