import 'package:flutter_nucleus/flutter_nucleus.dart';
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

// Nucleus atom
AtomWithParent<S, Atom<SM>> stateMachineAtom<S, SM extends StateMachineBase<S>>(
  AtomReader<SM> create,
) =>
    atomWithParent(atom((get) {
      final sm = create(get);
      get.onDispose(sm.close);
      return sm;
    }), (get, parent) {
      final sm = get(parent);
      get.onDispose(sm.stream.listen(get.setSelf).cancel);
      return sm.state;
    });
