# Changelog

## 0.1.1

- Changed `list.dart` to `iterable.dart`
- Added new methods to iterable reactives

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
