# Changelog

## 1.0.3

- Added `ReactiveDependency` for cached shared stores and dependencies
- Added `.dependency` and `.dep` extensions for simple dependency reuse
- Added `Rxb` alias for `ReactiveBuilder` to simplify usage and reduce boilerplate in widget builders
- Changed `.reactive()` extension to a simpler `.rt` and added `.rtNonStrict` for non-strict mode reactive creation. Same for nullable version with `.rtN` and `.rtNNonStrict`
_ Added `.once(callback)` method to `Reactive` for one-time reactions that automatically unsubscribe after the first trigger
- All subscription methods (`listen`, `debounce`, `throttle`, `once`) now return a `ReactiveSubscription` object with an explicit `cancel()` method for better subscription management and cleanup
- Fixed `react` and `reactN` extensions to avoid emitting initial value on bind, preventing unnecessary widget rebuilds on initial state setup


## 1.0.2

- Fixed `Reactive.compute(...)` dependency retracking so dynamic and nested computed values keep working after updates
- Fixed a listener iteration issue where multiple computed values declared sequentially could cause earlier computed listeners to stop receiving updates
- Added regression tests covering nested computed values and multiple computed listeners declared side by side

## 1.0.1

- Added `Reactive.streamEmitOnListen` to optionally emit the current stream value as soon as a new stream listener subscribes
- Added `ReactiveBuilder.stream(reactive, builder, withInitial: true)` as a shortcut around Flutter's `StreamBuilder`
- Updated `Reactive.notify()` so stream listeners receive updates through the same notification flow as bound states and callback listeners
- Added documentation for the new stream emission behavior and related public API

## 1.0.0 (🚨 Breaking changes)

- Old `ReactiveBuilder` is now `ReactiveBuilder.watch(reactive, builder)` and `ReactiveBuilder(() { ... })` now auto-tracks reactive reads directly in the widget builder
- Updated `Reactive.build(...)` to use the new `ReactiveBuilder.watch(...)` API
- Added `ReactiveBuilder.watch2`..`ReactiveBuilder.watch5`
- Changed `list.dart` to `iterable.dart`
- `Reactive.computed(...)` is now `Reactive.compute(...)` and can auto-tracks reactives
- Remove `ReactiveStreamBuilder` widget cause it was not relevant
- Added new methods to iterable, map and string reactives
- Updated `transform(...)` method of reactive lists
- Added new methods and operators to Reactives num and string
- Added optional `emitInitial` positional argument to `listen(callback, [emitInitial])`
  to immediately emit the current value on subscription
- Updated tests, README examples, and example app to match the new builder and
  listener APIs

## 0.1.0

- Added transaction support with `Reactive.run(...)`
- Added `save`, `restore`, `unsave` and `unsaveAll` methods on `Reactive`
- Added `when` method on `Reactive` for conditional reactions
- Added `sort` method to `ReactiveList`
- Added optional strict mode argument to `.reactive([strict])`
- Added `ReactiveStateBuilder` widget for multiple states in one builder
- Renamed `Validator` to `ReactiveValidator`
- Renamed `ValidatorError` to `ReactiveValidatorError`
- Fixed `as` method to correctly propagate reactive updates
- Updated README with new transaction features and examples
- Update example app with transaction usage

## 0.0.9

- Try catch listeners to avoid break

## 0.0.8

- New methodz `build`, `as`, `throttle`, `require`, `setAsync`
- Inside `transform`, filter can change dynamically now
- Added new extensions on `DateTime`, `Duration` and `Color`

## 0.0.7

- Fix `transform` where empty list are ignored

## 0.0.6

- Added `length` extension to StringReactive
- Added `transform` method to Reactive lists

## 0.0.5

- Update README

## 0.0.4

- Added "Recommended Architecture" section to README
- Minor changes in example app

## 0.0.3

- Added ReactiveN for nullable types
- New debounce, mutate and computed methods
- Updated README with new features

## 0.0.2

- Minor fixes and improvements

## 0.0.1

- Initial release
