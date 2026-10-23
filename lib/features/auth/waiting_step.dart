import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_client_oi/core/theme/app_theme.dart';
import 'package:flutter_client_oi/shared/widgets/base_button.dart';

class WaitingStep extends StatefulWidget {
  const WaitingStep({
    super.key,
    this.error,
    required this.onOpenEgov,
    required this.onAuthorized,
  });

  final String? error;
  final VoidCallback onOpenEgov;
  final VoidCallback onAuthorized;

  @override
  State<WaitingStep> createState() => _WaitingStepState();
}

class _WaitingStepState extends State<WaitingStep> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    // MOCK (same as the Vue code): authorize after 2s.
    // TODO: replace with real polling of the eGov approval status.
    _t = Timer(const Duration(seconds: 2), widget.onAuthorized);
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Ожидаем разрешения',
                style: TextStyle(fontSize: 13, color: AppColors.primary),
              ),
            ],
          ),
        ),

        const Spacer(),

        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              BaseButton(
                text: 'Открыть eGov',
                variant: ButtonVariant.login,
                block: true,
                verticalPadding: 16,
                onPressed: widget.onOpenEgov,
              ),
              const Text(
                'После подтверждения вернитесь сюда',
                style: TextStyle(fontSize: 12, color: Color(0xFF7A827E)),
              ),
              if (widget.error?.isNotEmpty == true)
                Text(
                  widget.error!,
                  style: const TextStyle(fontSize: 13, color: Colors.red),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
