import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? desc;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionTitle({
    super.key,
    required this.title,
    this.desc,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              if (desc != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    desc!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4F46E5),
              ),
            ),
          ),
      ],
    );
  }
}
