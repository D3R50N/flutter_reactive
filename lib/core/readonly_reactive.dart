part of '../flutter_reactive.dart';

class ReadonlyReactive<T> extends BaseReactive<T> {
  ReadonlyReactive(super._value, [super.strict = true]);

  final List<BaseReactive> _computedReactives = [];
}
