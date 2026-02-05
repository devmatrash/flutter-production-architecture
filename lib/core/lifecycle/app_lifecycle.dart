import 'dart:developer';

import 'package:flutter/material.dart';

/*
 * AppLifeCycle Observer - Monitors application state changes
 *
 * This class implements WidgetsBindingObserver to track app lifecycle events:
 * - App state changes (resumed, inactive, paused, detached, hidden)
 * - Memory pressure warnings
 * - Platform brightness changes
 * - Locale changes
 *
 * Integration: Should be initialized during app bootstrap and disposed properly
 * to prevent memory leaks.
 *
 * Usage:
 * ```dart
 * final appLifecycle = AppLifeCycle();
 * appLifecycle.initialize();
 * // ... later
 * appLifecycle.dispose();
 * ```
 */
class AppLifeCycle with WidgetsBindingObserver {
  static AppLifeCycle? _instance;
  bool _isInitialized = false;

  // Singleton pattern for global access
  static AppLifeCycle get instance {
    _instance ??= AppLifeCycle._internal();
    return _instance!;
  }

  AppLifeCycle._internal();

  /// Factory constructor for easy instantiation
  factory AppLifeCycle() => instance;

  /// Current application state
  AppLifecycleState get currentState => WidgetsBinding.instance.lifecycleState!;

  /// Initialize the lifecycle observer
  /// Should be called during app bootstrap
  Future<void> initialize() async {
    if (_isInitialized) {
      log('AppLifeCycle already initialized', name: 'AppLifeCycle');
      return;
    }

    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;

    log(
      'AppLifeCycle initialized - Current state: ${currentState.name}',
      name: 'AppLifeCycle',
    );
  }

  /// Dispose the lifecycle observer
  /// Should be called when app is terminated
  void dispose() {
    if (!_isInitialized) return;

    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;

    log('AppLifeCycle disposed', name: 'AppLifeCycle');
  }

  /// Called when the system puts the app in the background or returns it to the foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    log('App lifecycle changed to: ${state.name}', name: 'AppLifeCycle');

    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.inactive:
        _onAppInactive();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      case AppLifecycleState.hidden:
        _onAppHidden();
        break;
    }
  }

  /// Called when the app is resumed (foreground)
  void _onAppResumed() {
    log('App resumed - User returned to app', name: 'AppLifeCycle');
  }

  /// Called when the app becomes inactive
  void _onAppInactive() {
    log('App inactive - Transitioning state', name: 'AppLifeCycle');
  }

  /// Called when the app is paused (background)
  void _onAppPaused() {
    log('App paused - Moved to background', name: 'AppLifeCycle');
  }

  /// Called when the app is detached
  void _onAppDetached() {
    log('App detached - About to terminate', name: 'AppLifeCycle');
  }

  /// Called when the app is hidden
  void _onAppHidden() {
    log('App hidden - UI not visible', name: 'AppLifeCycle');
  }

  /// Called when the system is running low on memory
  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    log(
      'Memory pressure detected - System low on memory',
      name: 'AppLifeCycle',
    );
  }

  /// Called when the platform brightness changes (dark/light mode)
  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    log(
      'Platform brightness changed to: ${brightness.name}',
      name: 'AppLifeCycle',
    );
  }

  /// Called when the system locale changes
  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    log(
      'System locales changed: ${locales?.map((l) => l.toString()).join(", ")}',
      name: 'AppLifeCycle',
    );
  }

  /// Check if the lifecycle observer is initialized
  bool get isInitialized => _isInitialized;
}
