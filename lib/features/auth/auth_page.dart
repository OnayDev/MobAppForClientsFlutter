import 'package:flutter/material.dart';

import 'package:flutter_client_oi/features/auth/login_flow.dart';
import 'package:flutter_client_oi/features/auth/pin_code_screen.dart';
import 'package:flutter_client_oi/features/auth/pin_mode.dart';
import 'package:flutter_client_oi/store/auth_store.dart';
import 'package:flutter_client_oi/features/splash_screen.dart';

/// LoginFlow <-> PinCodeScreen (the first Vue component).
class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.auth});

  final AuthStore auth;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _pinKey = GlobalKey<PinCodeScreenState>();
  PinMode pinMode = PinMode.enter;
  String firstPin = '';
  bool loading = false;
  String error = '';

  AuthStore get auth => widget.auth;

  @override
  void initState() {
    super.initState();
    auth.addListener(_onAuthChanged);
    auth.initialize().then((_) {
      if (mounted) setState(_syncMode);
    });
  }

  @override
  void dispose() {
    auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _syncMode() => pinMode = auth.pinMode;

  void _onAuthChanged() {
    if (!mounted) return;
    setState(() {
      if (auth.isAuthorized) _syncMode();
    });
  }

  Future<void> _handlePin(String pin) async {
    if (loading) return;
    setState(() => error = '');

    if (pinMode == PinMode.create) {
      setState(() {
        firstPin = pin;
        pinMode = PinMode.confirm;
      });
      return;
    }

    if (pinMode == PinMode.confirm && pin != firstPin) {
      setState(() {
        error = 'PIN-коды не совпадают';
        firstPin = '';
        pinMode = PinMode.create;
      });
      return;
    }

    setState(() => loading = true);
    try {
      if (pinMode == PinMode.confirm) {
        await auth.createPin(pin);
        firstPin = '';
      } else {
        await auth.verifyPin(pin);
      }
      auth.unlock();
      if (mounted) Navigator.of(context).pushReplacementNamed('/main');
    } catch (_) {
      setState(() => error = 'Неверный PIN-код или ошибка авторизации');
      _pinKey.currentState?.reset();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _recoverPin() async {
    // TODO: Start secure PIN recovery through eGov
    await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    if (auth.isInitializing) {
      return const SplashScreen();
    }

    if (!auth.isAuthorized) {
      return LoginFlow(auth: auth);
    }

    return PinCodeScreen(
      key: _pinKey,
      mode: pinMode,
      userName: auth.userName.isEmpty ? 'Имя. Ф' : auth.userName,
      loading: loading,
      error: error,
      onComplete: _handlePin,
      onRecover: _recoverPin,
    );
  }
}
