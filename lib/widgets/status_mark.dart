import 'package:flutter/material.dart';

class StatusMark extends StatelessWidget {
  final String status; // 'todo' | 'done' | 'partial'
  final double size;

  const StatusMark({super.key, required this.status, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        width: size,
        height: size,
        child: switch (status) {
          'done' => Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('√',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF059669))),
              ),
            ),
          'partial' => Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '√\u{0336}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD97706)),
                ),
              ),
            ),
          _ => Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
                color: Colors.white,
              ),
              child: const Center(
                child: Text('□',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8))),
              ),
            ),
        },
      ),
    );
  }
}
