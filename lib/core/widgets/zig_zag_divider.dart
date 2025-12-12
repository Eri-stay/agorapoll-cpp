import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Віджет, що малює кастомний розділювач у вигляді квадратного зигзагу.
class ZigZagDivider extends StatelessWidget {
  final Color color;
  final double height;
  final double strokeWidth;
  final double segmentLength;

  const ZigZagDivider({
    Key? key,
    this.color = AppColors.cardOutline, // Колір за замовчуванням
    this.height = 12.0, // Загальна висота віджета
    this.strokeWidth = 1.5, // Товщина лінії
    this.segmentLength = 12.0, // Довжина одного "зубця"
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _ZigZagPainter(
          color: color,
          strokeWidth: strokeWidth,
          segmentLength: segmentLength,
        ),
      ),
    );
  }
}

/// Внутрішній клас, який безпосередньо виконує малювання на Canvas.
class _ZigZagPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double segmentLength;

  _ZigZagPainter({
    required this.color,
    required this.strokeWidth,
    required this.segmentLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Починаємо малювати з лівого верхнього кута
    path.moveTo(0, 0);

    // Малюємо зигзаг сегментами по всій ширині
    // Один повний цикл (вниз-вправо, вгору-вправо) має ширину 2 * segmentLength
    for (double x = 0; x < size.width; x += (2 * segmentLength)) {
      path.lineTo(x + segmentLength, segmentLength); // Лінія вниз-вправо
      path.lineTo(x + (2 * segmentLength), 0); // Лінія вгору-вправо
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ZigZagPainter oldDelegate) {
    // Перемальовувати, тільки якщо змінилися параметри
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.segmentLength != segmentLength;
  }
}
