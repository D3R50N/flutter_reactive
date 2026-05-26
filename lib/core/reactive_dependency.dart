part of 'package:flutter_reactive/flutter_reactive.dart';

class ReactiveDependency {
  static final Map<Type, dynamic> _dependencies = {};

  /// Disposes the dependencyd instance of type [T], if it exists.
  @nonVirtual
  void dispose() {
    _dependencies.remove(runtimeType);
    onDispose();
  }

  /// Override this method to perform initialization logic when the dependency is created. Do not call this method directly; it will be called automatically when the dependency is first accessed or injected.
  void onCreate() {}

  /// Override this method to perform cleanup logic when the dependency is disposed. Do not call this method directly; it will be called automatically when the dependency is disposed.
  void onDispose() {}

  /// Clears all dependencyd instances. Useful for testing or resetting state.
  static void clear() {
    _dependencies.clear();
  }

  /// Registers a dependency instance of type [T] and returns it. If an instance of type [T] already exists, it will be overwritten.
  static T inject<T>(T instance) {
    _dependencies[T] = instance;
    return instance;
  }

  /// Retrieves the dependency instance of type [T], or creates and registers a new one using the provided [create] function if it doesn't exist.
  static T use<T>(T Function() create) {
    if (_dependencies.containsKey(T)) {
      return _dependencies[T] as T;
    }
    return inject(create());
  }

  /// Finds and returns the dependency instance of type [T], or throws an exception if it doesn't exist.
  static T of<T>() {
    final value = _dependencies[T];
    if (value == null) {
      throw Exception('No dependency found for type $T');
    }
    return value as T;
  }

  /// Checks if a dependency instance of type [T] exists.
  static bool has<T>() {
    return _dependencies.containsKey(T);
  }

  /// Removes the dependency instance of type [T] from the registry.
  static void drop<T>() {
    _dependencies.remove(T);
  }
}

extension ReactiveDependencyExtension<T> on T {
  /// Retrieves the dependencyd instance of type [T], or creates and dependencys a new one if it doesn't exist.
  T get dependency {
    if (ReactiveDependency.has<T>()) {
      return ReactiveDependency.of<T>();
    }
    final dep = ReactiveDependency.inject<T>(this);
    if (this is ReactiveDependency) {
      (this as ReactiveDependency).onCreate();
    }
    return dep;
  }

  /// Alias for [dependency]
  T get dep => dependency;
}
