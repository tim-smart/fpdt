import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdt/fpdt.dart';
import 'package:fpdt/reader_task_either.dart' as RTE;
import 'package:fpdt_flutter/fpdt_flutter.dart';

class FlutterOpContext {
  const FlutterOpContext(this.context, this._ref);

  final BuildContext context;
  final WidgetRef _ref;

  T Function<T>(ProviderBase<T> provider) get read => _ref.read;
  T Function<T>(ProviderBase<T> provider) get refresh => _ref.refresh;
  void Function<T>(
    ProviderListenable<T> provider,
    void Function(T?, T) listener, {
    void Function(Object, StackTrace)? onError,
  }) get listen => _ref.listen;
}

typedef FlutterOp<E, A> = ReaderTaskEither<FlutterOpContext, E, A>;
FlutterOp<E, FlutterOpContext> askFlutterOp<E>() => RTE.ask();

TaskEither<E, A> useFlutterOp<E, A>(
  WidgetRef ref,
  FlutterOp<E, A> op, [
  List<dynamic> deps = const [],
]) {
  final context = useContext();
  return useMemoized(
    () => op(FlutterOpContext(context, ref)),
    [context, ...deps],
  );
}

Tuple2<ValueNotifier<TypedAsyncValue<E, A>>, TaskEither<E, A>>
    useFlutterOpWithState<E, A>(
  WidgetRef ref,
  FlutterOp<E, A> op, [
  List<dynamic> deps = const [],
]) {
  final task = useFlutterOp(ref, op, deps);
  final state = useState(TypedAsyncValue<E, A>.none());
  final fn = useCallback(() {
    state.value = state.value.asLoading();
    return TypedAsyncValue.withValueNotifier(state, task);
  }, deps);

  return tuple2(state, fn);
}
