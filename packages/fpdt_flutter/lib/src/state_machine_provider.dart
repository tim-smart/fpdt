import 'package:fpdt/fpdt.dart';

/// Helper for creating riverpod providers
SM stateMachineProvider<SM extends StateMachineBase>(dynamic ref, SM sm) {
  ref.onDispose(sm.close);
  return sm;
}

/// Helper for creating riverpod providers
S stateMachineStateProvider<S>(
  dynamic ref,
  StateMachineBase<S> sm,
) {
  ref.onDispose(sm.stream.listen((s) => ref.state = s).cancel);
  return sm.state;
}
