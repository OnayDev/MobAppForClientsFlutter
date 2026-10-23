import 'package:flutter/material.dart';

import 'package:flutter_client_oi/core/theme/app_theme.dart';
import 'package:flutter_client_oi/shared/widgets/base_bottom_sheet.dart';
import 'package:flutter_client_oi/shared/widgets/base_icon.dart';

const _steps = [
  (title: 'Телефон', description: '+7 (777) 000-00-00', icon: 'call'),
  (title: 'Почта', description: 'support@onayipoteka.kz', icon: 'mail'),
  (title: 'Время работы', description: 'Ежедневно, 09:00–21:00', icon: 'time'),
];

Future<void> showHelpDeskInfo(BuildContext context) {
  return showBaseBottomSheet(
    context,
    backdrop: true,
    showHandle: false,
    title: 'Нужна помощь?',
    subtitle: 'Свяжитесь с нашей службой поддержки любым удобным способом',
    child: Column(
      children: [
        for (var i = 0; i < _steps.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: i == _steps.length - 1
                  ? null
                  : const Border(
                      bottom: BorderSide(color: Color(0xFFE9ECEA)),
                    ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary10OnWhite,
                  ),
                  child: BaseIcon(
                    _steps[i].icon,
                    size: IconSize.sm,
                    color: IconTint.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _steps[i].title,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 17 / 12,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _steps[i].description,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
