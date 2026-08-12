import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/progress/progress_tracker.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/responsive.dart';
import '../models/units_data.dart';
import '../widgets/shared/certificate_widget.dart';

/// شاشة شهادة الإنجاز — تُعرض بعد إكمال كل الوحدات (أو الوحدة
/// الأخيرة على الأقل). تسمح للأهل بمشاركة الشهادة كصورة عبر أي
/// تطبيق (واتساب، إلخ) بلا الحاجة لأي حساب أو إنترنت.
class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final GlobalKey _captureKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareCertificate() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final boundary = _captureKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      // دقة أعلى من الشاشة (3x) باش الصورة المشتركة تبان واضحة
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/arqami_certificate.png');
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'أكملت طفلي/طفلتي تطبيق أرقامي! 🎉',
        ),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final units = UnitsData.units;
    final completedIds = ProgressTracker.instance.getCompletedUnitIds();
    final completedUnits = completedIds.length;

    int totalStars = 0;
    for (final unit in units) {
      totalStars += ProgressTracker.instance.getUnitProgress(unit.id).stars;
    }
    final maxStars = units.length * 3;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('شهادتك'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Responsive.constrainedCenter(
          maxWidth: 420,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: RepaintBoundary(
                      key: _captureKey,
                      child: CertificateWidget(
                        completedUnits: completedUnits,
                        totalUnits: units.length,
                        totalStars: totalStars,
                        maxStars: maxStars,
                        completionDate: DateTime.now(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSharing ? null : _shareCertificate,
                    icon: _isSharing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.share_rounded),
                    label: Text(_isSharing ? 'جاري التحضير...' : 'شارك الشهادة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('رجوع'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
