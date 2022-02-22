import 'package:fpdt/fpdt.dart';

/// Helper for creating riverpod providers
SM Function<SM extends StateMachineBase>(SM sm) stateMachineProvider(
  dynamic ref,
) =>
    <SM extends StateMachineBase>(SM sm) {
      ref.onDispose(sm.close);
      return sm;
    };

/// Helper for creating riverpod providers
S Function<S>(StateMachineBase<S> sm) stateMachineStateProvider(dynamic ref) =>
    <S>(sm) {
      ref.onDispose(sm.stream.listen((s) => ref.state = s).cancel);
      return sm.state;
    };
