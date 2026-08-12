import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// شهادة إنجاز مرسومة بالكامل بـ CustomPainter — بلا أي صورة خارجية،
/// وبلا أي حقل اسم أو بيانات شخصية (توافقاً مع سياسة الخصوصية:
/// أرقامي ما كيجمعش أي بيانات عن الطفل).
///
/// تُستخدم داخل RepaintBoundary فـ CertificateScreen باش تُلتقط
/// كصورة للمشاركة.
class CertificateWidget extends StatelessWidget {
  final int completedUnits;
  final int totalUnits;
  final int totalStars;
  final int maxStars;
  final DateTime completionDate;

  const CertificateWidget({
    super.key,
    required this.completedUnits,
    required this.totalUnits,
    required this.totalStars,
    required this.maxStars,
    required this.completionDate,
  });

  String _formatDate(DateTime date) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'ماي', 'يونيو',
      'يوليوز', 'غشت', 'شتنبر', 'أكتوبر', 'نونبر', 'دجنبر',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: CustomPaint(
          painter: _ZelligeBorderPainter(),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 72,
                  color: AppColors.gold,
                ),
                const SizedBox(height: 16),
                const Text(
                  'شهادة إنجاز',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'أرقامي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.terracotta,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'أحسنت يا بطل! 🎉',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'أكملت $completedUnits من $totalUnits وحدة تعليمية\nوتعلّمت الأرقام من 0 إلى 10',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    maxStars > 15 ? 15 : maxStars, // سقف بصري معقول
                    (i) => Icon(
                      i < totalStars
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: AppColors.gold,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 60,
                  height: 2,
                  color: AppColors.locked,
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(completionDate),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// يرسم إطاراً زخرفياً مستوحى من الزليج المغربي — أشكال معينية
/// متكررة بألوان متناوبة حول حدود الشهادة، بلا أي صورة أو أصل خارجي
class _ZelligeBorderPainter extends CustomPainter {
  static const double _borderThickness = 20;
  static const double _tileSize = 24;

  @override
  void paint(Canvas canvas, Size size) {
    // خط حدودي خارجي وداخلي
    final outerBorderPaint = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final innerBorderPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final outerRect = Rect.fromLTWH(6, 6, size.width - 12, size.height - 12);
    final innerRect = Rect.fromLTWH(
      _borderThickness,
      _borderThickness,
      size.width - _borderThickness * 2,
      size.height - _borderThickness * 2,
    );

    canvas.drawRect(outerRect, outerBorderPaint);
    canvas.drawRect(innerRect, innerBorderPaint);

    // أشكال معينية زخرفية على طول الحافة العلوية والسفلية
    _drawDiamondRow(canvas, size, top: true);
    _drawDiamondRow(canvas, size, top: false);
  }

  void _drawDiamondRow(Canvas canvas, Size size, {required bool top}) {
    final y = top ? _borderThickness / 2 : size.height - _borderThickness / 2;
    final count = (size.width / _tileSize).floor();
    final startX = (size.width - count * _tileSize) / 2 + _tileSize / 2;

    for (int i = 0; i < count; i++) {
      final x = startX + i * _tileSize;
      final color = i.isEven ? AppColors.terracotta : AppColors.tealLight;
      final paint = Paint()..color = color;

      final path = Path()
        ..moveTo(x, y - 6)
        ..lineTo(x + 6, y)
        ..lineTo(x, y + 6)
        ..lineTo(x - 6, y)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ZelligeBorderPainter oldDelegate) => false;
}
