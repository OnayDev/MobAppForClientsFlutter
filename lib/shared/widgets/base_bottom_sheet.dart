import 'package:flutter/material.dart';

import 'package:flutter_client_oi/shared/widgets/base_icon.dart';

/// Replacement for <BaseBottomSheet v-model>.
/// Swipe-down and barrier tap close it.
Future<T?> showBaseBottomSheet<T>(
  BuildContext context, {
  required Widget child,
  String? title,
  String? subtitle,
  bool backdrop = true,
  bool showHandle = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: backdrop ? Colors.black.withOpacity(0.2) : Colors.transparent,
    builder: (ctx) => Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            24,
            20,
            MediaQuery.of(ctx).padding.bottom.clamp(20.0, 100.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (showHandle)
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9DDDB),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null)
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF252927),
                              ),
                            ),
                          if (subtitle != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 310),
                                child: Text(
                                  subtitle,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 16 / 13,
                                    color: Color(0xFF8F95A3),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: const Opacity(
                      opacity: 0.7,
                      child: BaseIcon('close', color: Colors.black),
                    ),
                  ),
                ],
              ),
              child,
            ],
          ),
        ),
      ),
    ),
  );
}
