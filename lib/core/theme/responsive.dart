import 'package:flutter/material.dart';

/// أدوات مساعدة لتخطيط متجاوب — تضمن أن التطبيق يبان مزيان على
/// الهاتف الصغير، الهاتف الكبير، والتابلت، بلا عناصر ممطوطة أو
/// صغيرة بزاف.
class Responsive {
  Responsive._();

  static const double _tabletBreakpoint = 600;
  static const double _maxContentWidth = 640;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= _tabletBreakpoint;

  /// عامل تحجيم بسيط للعناصر ذات الحجم الثابت (بطاقات، أزرار...)
  /// — 1.0 على الهاتف العادي، أكبر شوية على التابلت باش العناصر ما
  /// تبقاش صغيرة وسط شاشة كبيرة.
  static double scaleFactor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= _tabletBreakpoint) return 1.35;
    if (width <= 360) return 0.9; // هواتف صغيرة جداً
    return 1.0;
  }

  /// يحيط المحتوى بعرض أقصى ويوسّطه أفقياً — يمنع أن تمتد الشاشات
  /// (خريطة الوحدات، الأنشطة) لعرض التابلت الكامل بشكل مبالغ فيه
  static Widget constrainedCenter({
    required Widget child,
    double maxWidth = _maxContentWidth,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
