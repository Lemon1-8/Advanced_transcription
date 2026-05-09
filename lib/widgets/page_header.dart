import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String? desc;
  final bool showBack;
  final List<Widget>? actions;

  const PageHeader({
    super.key,
    required this.title,
    this.desc,
    this.showBack = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showBack)
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(right: 8),
                    child: const Icon(Icons.arrow_back_ios,
                        size: 18, color: Color(0xFF0F172A)),
                  ),
                ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
          if (desc != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                desc!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
