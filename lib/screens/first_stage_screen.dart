import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/progress/progress_tracker.dart';
import '../core/theme/game_theme.dart';
import '../models/units_data.dart';

/// A self-contained rebuild of the first learning stage (number zero).
/// It deliberately avoids the legacy curriculum planner and its activity widgets.
class FirstStageScreen extends StatefulWidget {
  const FirstStageScreen({super.key});

  @override
  State<FirstStageScreen> createState() => _FirstStageScreenState();
}

class _FirstStageScreenState extends State<FirstStageScreen> {
  int _step = 0;
  bool _emptyBasketFound = false;
  bool _traceAccepted = false;
  bool _answerWrong = false;
  bool _saving = false;
  final List<Offset> _stroke = [];

  static const _steps = 4;

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ProgressTracker.instance.markUnitComplete(
        UnitsData.units.first.id,
        stars: 3,
      );
      if (!mounted) return;
      setState(() => _step = _steps);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حفظ التقدم. حاول مرة أخرى.')),
      );
    }
  }

  void _next() {
    if (_step < _steps - 1) setState(() => _step++);
  }

  void _checkTrace(Size size) {
    if (_stroke.length < 10) {
      setState(() => _stroke.clear());
      return;
    }
    final xs = _stroke.map((p) => p.dx).toList();
    final ys = _stroke.map((p) => p.dy).toList();
    final width = xs.reduce(math.max) - xs.reduce(math.min);
    final height = ys.reduce(math.max) - ys.reduce(math.min);
    final closes = (_stroke.first - _stroke.last).distance < size.shortestSide * .28;
    final oval = width > size.width * .18 &&
        height > size.height * .18 &&
        width / math.max(height, 1) > .35 &&
        width / math.max(height, 1) < 2.8;
    setState(() {
      _traceAccepted = closes && oval;
      _stroke.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final finished = _step >= _steps;
    return Scaffold(
      backgroundColor: GameTheme.sky,
      appBar: AppBar(
        backgroundColor: GameTheme.sky,
        foregroundColor: GameTheme.ink,
        title: const Text('المرحلة الأولى · نتعرّف على الصفر'),
        centerTitle: true,
        leading: IconButton(
          tooltip: 'العودة إلى الخريطة',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: finished ? _buildFinished() : Column(
                children: [
                  _buildProgress(),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: _buildStep(key: ValueKey(_step)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_step == 0)
                    _primaryButton('هيا نبدأ', _next)
                  else if (_step == 1)
                    _primaryButton(
                      _emptyBasketFound ? 'أحسنت، تابع' : 'أين السلة الفارغة؟',
                      _emptyBasketFound ? _next : () => setState(() => _answerWrong = true),
                    )
                  else if (_step == 2)
                    _primaryButton(_traceAccepted ? 'رائع، تابع' : 'تحقّق من كتابة الصفر', () {
                      if (_traceAccepted) {
                        _next();
                      } else {
                        setState(() => _answerWrong = true);
                      }
                    })
                  else
                    _primaryButton('هذا هو الصفر: 0', () => _finish(), enabled: !_saving),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: GameTheme.sunshine),
            const SizedBox(width: 8),
            const Expanded(child: Text('مغامرة الرقم 0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
            Text('${_step + 1} / $_steps', style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(value: (_step + 1) / _steps, minHeight: 8),
        ),
      ],
    );
  }

  Widget _buildStep({required Key key}) {
    switch (_step) {
      case 0:
        return Column(
          key: key,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _ZeroBadge(size: 124),
            const SizedBox(height: 22),
            const Text('ما معنى الصفر؟', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            const Text('الصفر يعني أن المجموعة فارغة؛ لا يوجد فيها أي شيء.', style: TextStyle(fontSize: 18, height: 1.6), textAlign: TextAlign.center),
            const SizedBox(height: 18),
            const Wrap(spacing: 10, alignment: WrapAlignment.center, children: [
              _CountChip(icon: Icons.apple_rounded, label: '0 تفاحات'),
              _CountChip(icon: Icons.toys_rounded, label: '0 ألعاب'),
            ]),
          ],
        );
      case 1:
        return Column(
          key: key,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('اختر السلة التي لا تحتوي على أي نجمة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _BasketOption(stars: 3, onTap: () => setState(() { _answerWrong = true; _emptyBasketFound = false; })),
                _BasketOption(stars: 0, onTap: () => setState(() { _emptyBasketFound = true; _answerWrong = false; })),
                _BasketOption(stars: 1, onTap: () => setState(() { _answerWrong = true; _emptyBasketFound = false; })),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _emptyBasketFound ? 'صحيح! لا توجد نجوم، إذن العدد 0.' : (_answerWrong ? 'جرّب مرة أخرى: ابحث عن السلة الخالية تماماً.' : 'المس إحدى السلال.'),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, color: _emptyBasketFound ? Colors.green.shade700 : GameTheme.ink),
            ),
          ],
        );
      case 2:
        return Column(
          key: key,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('ارسم دائرة حول المسار لتكتب 0', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  return GestureDetector(
                    onPanStart: (d) => setState(() => _stroke
                      ..clear()
                      ..add(d.localPosition)),
                    onPanUpdate: (d) => setState(() => _stroke.add(d.localPosition)),
                    onPanEnd: (_) => _checkTrace(size),
                    child: CustomPaint(
                      painter: _ZeroTracePainter(points: List.of(_stroke), accepted: _traceAccepted),
                      child: const SizedBox.expand(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _traceAccepted ? 'أحسنت! كتبت مساراً مغلقاً يشبه الصفر.' : (_answerWrong ? 'حاول رسم حلقة مغلقة تشبه 0.' : 'ابدأ من أي نقطة وأغلق الدائرة.'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextButton.icon(
              onPressed: () => setState(() { _stroke.clear(); _traceAccepted = false; _answerWrong = false; }),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة الرسم'),
            ),
          ],
        );
      default:
        return Column(
          key: key,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('أي رقم يدل على عدم وجود أشياء؟', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
            const SizedBox(height: 28),
            Wrap(
              spacing: 14,
              children: [0, 1, 2].map((n) => SizedBox(
                width: 76,
                height: 76,
                child: ElevatedButton(
                  onPressed: () {
                    if (n == 0) {
                      _finish();
                    } else {
                      setState(() => _answerWrong = true);
                    }
                  },
                  child: Text('$n', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 18),
            if (_answerWrong) const Text('ليس هذا الرقم. تذكّر السلة الفارغة.', textAlign: TextAlign.center),
          ],
        );
    }
  }

  Widget _buildFinished() => Center(
    child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _ZeroBadge(size: 132),
          const SizedBox(height: 20),
          const Text('أحسنت! أكملت المرحلة الأولى', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          const Text('أصبحت تعرف أن الصفر يعني عدم وجود أي عنصر.', style: TextStyle(fontSize: 18, height: 1.5), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.star_rounded, color: GameTheme.sunshine, size: 42),
            Icon(Icons.star_rounded, color: GameTheme.sunshine, size: 42),
            Icon(Icons.star_rounded, color: GameTheme.sunshine, size: 42),
          ]),
          const SizedBox(height: 24),
          _primaryButton('العودة إلى الخريطة', () => Navigator.of(context).pop(true)),
        ],
      ),
    ),
  );

  Widget _primaryButton(String label, VoidCallback onPressed, {bool enabled = true}) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: GameTheme.ocean,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
    ),
  );
}

class _ZeroBadge extends StatelessWidget {
  final double size;
  const _ZeroBadge({required this.size});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(colors: [GameTheme.ocean, GameTheme.mint]),
      boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 7))],
    ),
    child: Text('0', style: TextStyle(fontSize: size * .58, color: Colors.white, fontWeight: FontWeight.w900)),
  );
}

class _CountChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CountChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, color: GameTheme.ocean),
    label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
  );
}

class _BasketOption extends StatelessWidget {
  final int stars;
  final VoidCallback onTap;
  const _BasketOption({required this.stars, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      width: 100,
      height: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: GameTheme.sunshine.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GameTheme.ocean.withValues(alpha: .25), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_basket_rounded, size: 42, color: GameTheme.ocean),
          const SizedBox(height: 5),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 1,
            children: List.generate(stars, (_) => const Icon(Icons.star_rounded, size: 18, color: GameTheme.sunshine)),
          ),
        ],
      ),
    ),
  );
}

class _ZeroTracePainter extends CustomPainter {
  final List<Offset> points;
  final bool accepted;
  const _ZeroTracePainter({required this.points, required this.accepted});

  @override
  void paint(Canvas canvas, Size size) {
    final guide = Paint()..color = GameTheme.ocean.withValues(alpha: .16)..style = PaintingStyle.stroke..strokeWidth = 18;
    final rect = Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: size.width * .48, height: size.height * .68);
    canvas.drawOval(rect, guide);
    final pathPaint = Paint()..color = accepted ? Colors.green : GameTheme.coral..style = PaintingStyle.stroke..strokeWidth = 12..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    for (var i = 1; i < points.length; i++) {
      canvas.drawLine(points[i - 1], points[i], pathPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ZeroTracePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.accepted != accepted;
}
