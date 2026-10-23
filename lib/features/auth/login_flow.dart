import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_client_oi/core/theme/app_theme.dart';
import 'package:flutter_client_oi/features/auth/help_desk_info.dart';
import 'package:flutter_client_oi/features/auth/login_step.dart';
import 'package:flutter_client_oi/features/auth/waiting_step.dart';
import 'package:flutter_client_oi/shared/widgets/base_icon.dart';
import 'package:flutter_client_oi/store/auth_store.dart';

enum LoginStepType { splash, login, waiting }

class LoginFlow extends StatefulWidget {
  const LoginFlow({super.key, required this.auth, this.onAuthorized});

  final AuthStore auth;
  final VoidCallback? onAuthorized;

  @override
  State<LoginFlow> createState() => _LoginFlowState();
}

class _LoginFlowState extends State<LoginFlow> {
  LoginStepType step = LoginStepType.splash;
  String iin = '';
  String error = '';
  bool loading = false;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(
      const Duration(milliseconds: 1500),
      () => setState(() => step = LoginStepType.login),
    );
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  Future<void> _continue(String value) async {
    if (value.length != 12 || loading) return;
    setState(() {
      loading = true;
      error = '';
    });
    try {
      // TODO: Start authentication API
      // final response = await api.post('/api/auth/start', {'iin': value});
      setState(() => step = LoginStepType.waiting);
      // TODO: startPolling(response.requestId)
    } catch (_) {
      setState(() => error = 'Не удалось выполнить вход. Попробуйте снова.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _openEgov() {
    // TODO: Open verification URL returned by API (url_launcher)
  }

  @override
  Widget build(BuildContext context) {
    final splash = step == LoginStepType.splash;
    const dur = Duration(milliseconds: 700);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: LayoutBuilder(
        builder: (context, c) {
          final h = c.maxHeight;
          return Stack(
            children: [
              // Background
              AnimatedPositioned(
                duration: dur,
                curve: Curves.easeInOut,
                left: 0,
                right: 0,
                top: 0,
                height: splash ? h : 180,
                child: const DecoratedBox(
                  decoration: BoxDecoration(gradient: splashGradient),
                ),
              ),

              // Logo
              AnimatedPositioned(
                duration: dur,
                curve: Curves.easeInOut,
                left: 0,
                right: 0,
                top: splash ? h / 2 - 16 : 32,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BaseIcon('logo-white', size: IconSize.xl),
                    const SizedBox(height: 4),
                    AnimatedOpacity(
                      opacity: splash ? 0 : 1,
                      duration: const Duration(milliseconds: 500),
                      child: const Text(
                        'Вход в приложение',
                        style: TextStyle(fontSize: 13, color: Color(0xCCFFFFFF)),
                      ),
                    ),
                  ],
                ),
              ),

              // Steps sheet
              AnimatedPositioned(
                duration: const Duration(milliseconds: 650),
                curve: const Cubic(0.22, 1, 0.36, 1),
                left: 0,
                right: 0,
                top: splash ? h : 112,
                height: h - 112,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  decoration: const BoxDecoration(
                    color: AppColors.bg,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                 child: Column(
                    children: [
                      if (step == LoginStepType.waiting)
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: WaitingStep(
                              key: const ValueKey('waiting'),
                              error: error,
                              onOpenEgov: _openEgov,
                              onAuthorized: () async {
                                await widget.auth.onEgovApproved();
                                widget.onAuthorized?.call();
                              },
                            ),
                          ),
                        )
                      else ...[
                        LoginStep(
                          key: const ValueKey('login'),
                          iin: iin,
                          loading: loading,
                          error: error,
                          onChanged: (v) => setState(() {
                            iin = v;
                            error = '';
                          }),
                          onContinue: _continue,
                        ),
                        const Spacer(),
                      ],

                      _HelpButton(onTap: () => showHelpDeskInfo(context)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HelpButton extends StatelessWidget {
  const _HelpButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: const Row(
            children: [
              BaseIcon('question', size: IconSize.sm, color: IconTint.green),
              SizedBox(width: 8),
              Text(
                'Нужна помощь?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
