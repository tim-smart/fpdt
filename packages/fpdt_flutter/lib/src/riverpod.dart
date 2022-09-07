import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdt/option.dart';

extension AsyncValueFpdt<A> on AsyncValue<A> {
  Option<A> get option => maybeWhen(data: some, orElse: none);
}
