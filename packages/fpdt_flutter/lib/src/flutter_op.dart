import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_nucleus/flutter_nucleus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdt/fpdt.dart';
import 'package:fpdt/reader_task_either.dart' as RTE;
import 'package:fpdt_flutter/fpdt_flutter.dart';

class FlutterOpContext {
  FlutterOpContext(this.context);

  final BuildContext context;
  late final container = ProviderScope.containerOf(context, listen: false);
  late final registry = AtomScope.registryOf(context, listen: false);
}

typedef FlutterOp<E, A> = ReaderTaskEither<FlutterOpContext, E, A>;
FlutterOp<E, FlutterOpContext> askFlutterOp<E>() => RTE.ask();

TaskEither<E, A> useFlutterOp<E, A>(
  FlutterOp<E, A> op, [
  List<dynamic> deps = const [],
]) {
  final context = useContext();
  final opContext = useMemoized(() => FlutterOpContext(context), [context]);

  return useMemoized(
    () => op(opContext),
    [opContext, ...deps],
  );
}

Tuple2<TypedAsyncValue<E, A>, TaskEither<E, A>> useFlutterOpWithState<E, A>(
  FlutterOp<E, A> op, [
  List<dynamic> deps = const [],
]) {
  final task = useFlutterOp(op, deps);
  final state = useState(TypedAsyncValue<E, A>.none());
  final fn = useCallback(() {
    state.value = state.value.asLoading();
    return TypedAsyncValue.withValueNotifier(state, task);
  }, deps);

  return tuple2(state.value, fn);
}
