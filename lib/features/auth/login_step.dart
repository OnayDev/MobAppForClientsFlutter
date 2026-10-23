import 'package:flutter/material.dart';

import 'package:flutter_client_oi/shared/widgets/base_button.dart';
import 'package:flutter_client_oi/shared/widgets/base_input.dart';
import 'package:flutter_client_oi/shared/widgets/security_notice.dart';

class LoginStep extends StatelessWidget {
  const LoginStep({
    super.key,
    required this.iin,
    required this.loading,
    required this.error,
    required this.onChanged,
    required this.onContinue,
  });

  final String iin, error;
  final bool loading;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BaseInput(
          value: iin,
          label: 'ИИН',
          iinMask: true,
          masked: true,
          placeholder: 'Введите ИИН',
          error: error,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        BaseButton(
          text: 'Продолжить',
          block: true,
          variant: ButtonVariant.login,
          verticalPadding: 16,
          loading: loading,
          onPressed: () => onContinue(iin),
        ),
        const SizedBox(height: 12),
        const SecurityNotice(
          'Мы используем данные только для входа и не храним их на устройстве',
          backgroundColor: Colors.transparent,
          textColor: Color(0x80000000),
        ),
      ],
    );
  }
}
