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
export 'future_or.dart' hide fromThrowable;
export 'iterable.dart';
export 'map.dart';
export 'tuple.dart';
export 'unit.dart';

// Primitive types
export 'either.dart' show Either, Left, Right;
export 'option.dart' show Option, Some, None, kNone;
export 'reader.dart' show Reader;
export 'reader_task.dart' show ReaderTask;
export 'reader_task_either.dart' show ReaderTaskEither;
export 'state.dart' show State;
export 'state_reader.dart' show StateReader;
export 'state_machine.dart' show StateMachine, StateMachineBase;
export 'state_reader_task_either.dart' show StateReaderTaskEither;
export 'state_rte_machine.dart' show StateRTEMachine;
export 'task_either.dart' show TaskEither;
export 'task_option.dart' show TaskOption;
export 'task.dart' show Task;

// Immutable data types
export 'package:fast_immutable_collections/fast_immutable_collections.dart';
