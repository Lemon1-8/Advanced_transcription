import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subMessage;
  final Widget? action;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.message = '暂无数据',
    this.subMessage,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            if (subMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  subMessage!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (action != null) Padding(
              padding: const EdgeInsets.only(top: 24),
              child: action!,
            ),
          ],
        ),
      ),
    );
  }
}
