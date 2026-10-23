import 'package:flutter/foundation.dart';

import '../features/auth/pin_mode.dart';

class AuthStore extends ChangeNotifier {
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  bool _isAuthorized = false;
  bool _isUnlocked = false;
  bool _hasPin = false;
  String _userName = '';

  bool get isAuthorized => _isAuthorized;
  bool get isUnlocked => _isUnlocked;
  bool get hasPin => _hasPin;
  String get userName => _userName;

  PinMode get pinMode => !_hasPin ? PinMode.create : PinMode.enter;

  Future<void> initialize() async {
    _isInitializing = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }
  
  Future<void> onEgovApproved() async {
    // Call only after the backend has confirmed eGov approval
    // and established an authenticated session.
    _isAuthorized = true;
    _isUnlocked = false;
    notifyListeners();
  }

  Future<void> verifyPin(String pin) async {
    // TODO: Verify PIN using a secure backend endpoint
    // POST /api/auth/pin/verify { pin }  -> throw on failure
  }

  Future<void> createPin(String pin) async {
    // TODO: Save PIN securely through your backend
    // POST /api/auth/pin { pin }
    _hasPin = true; // remove once the backend call is connected and sets it
  }

  void lock() {
    if (!_isAuthorized || !_isUnlocked) return;

    _isUnlocked = false;
    notifyListeners();
  }

  void unlock() {
    _isUnlocked = true;
    notifyListeners();
  }

  Future<void> logout() async {
    // TODO: Revoke session on backend
    _isAuthorized = false;
    _isUnlocked = false;
    _hasPin = false;
    _userName = '';
    notifyListeners();
  }
}
