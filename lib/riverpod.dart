import 'package:fpdt/fpdt.dart';

/// Helper for creating riverpod providers
SM Function(SM sm) stateMachineProvider<SM extends StateMachineBase>(
  dynamic ref,
) =>
    (sm) {
      ref.onDispose(sm.close);
      return sm;
    };

/// Helper for creating riverpod providers
S Function(SM sm) stateMachineStateProvider<SM extends StateMachineBase<S>, S>(
  dynamic ref,
) =>
    (sm) {
      ref.onDispose(sm.stream.listen((s) => ref.state = s).cancel);
      return sm.state;
    };
