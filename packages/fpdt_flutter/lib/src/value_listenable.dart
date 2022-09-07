import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fpdt/fpdt.dart';
import 'package:fpdt/option.dart';

Option<A> useValueListenableOption<A>(Option<ValueListenable<A>> notifier) {
  final state = useState(notifier.p(map((n) => n.value)));

  useEffect(
    () => notifier.p(fold(() => () {}, (n) {
      void onChange() {
        state.value = some(n.value);
      }

      n.addListener(onChange);
      return () => n.removeListener(onChange);
    })),
    [notifier],
  );

  return state.value;
}
