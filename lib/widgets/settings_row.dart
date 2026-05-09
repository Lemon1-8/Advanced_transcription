import 'package:flutter/material.dart';

class SettingsRow extends StatelessWidget {
  final String label;
  final String value;
  final bool danger;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.label,
    required this.value,
    this.danger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: danger ? const Color(0xFFE11D48) : const Color(0xFF334155),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right,
                    size: 18, color: Color(0xFFCBD5E1)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
