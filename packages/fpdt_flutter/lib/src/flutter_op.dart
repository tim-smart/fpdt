import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fpdt/fpdt.dart';
import 'package:fpdt/reader_task_either.dart' as RTE;
import 'package:fpdt_flutter/task_either_value.dart';

class FlutterOpContext {
  FlutterOpContext(this.context);
  final BuildContext context;
}

typedef FlutterOp<E, A> = ReaderTaskEither<FlutterOpContext, E, A>;
FlutterOp<E, FlutterOpContext> askFlutterOp<E>() => RTE.ask();
FlutterOp<E, A> flutterOpDo<E, A>(RTE.DoFunction<FlutterOpContext, E, A> f) =>
    RTE.Do(f);

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

Tuple2<TaskEitherValue<E, A>, TaskEither<E, A>> useFlutterOpWithState<E, A>(
  FlutterOp<E, A> op, [
  List<dynamic> deps = const [],
]) {
  final task = useFlutterOp(op, deps);
  final state = useState(none<E, A>());
  final fn = useCallback(() {
    state.value = asLoading(state.value);
    return withValueNotifier(state, task);
  }, deps);

  return tuple2(state.value, TaskEither(Task(fn)));
}
