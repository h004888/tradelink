import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../utils/theme.dart';
import '../../viewmodels/splash_viewmodel.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SplashViewModel(),
      child: const _SplashBody(),
    );
  }
}

class _SplashBody extends StatefulWidget {
  const _SplashBody();
  @override
  State<_SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<_SplashBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<SplashViewModel>().captureDeepLink(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SplashViewModel>();

    // Trigger navigation when splash delay completes
    if (vm.state is Success) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) vm.navigateNext(context);
      });
    }

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      body: SafeArea(
        child: Center(
          child: Container(
            // ── Phone frame: rounded corners + subtle shadow ──
            margin: const EdgeInsets.all(TradeLinkSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 40,
                  offset: Offset(0, 8),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 12,
                  offset: Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Column(
                children: [
                  // ── iOS Status Bar ──
                  _iOSStatusBar(),

                  // ── Main content ──
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Spacer(flex: 3),

                          // ── Logo ──
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: TradeLinkSpacing.huge,
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 120,
                              height: 120,
                            ),
                          ),

                          const SizedBox(height: TradeLinkSpacing.lg),

                          // ── App name ──
                          Text(
                            'TradeLink',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.02 * 36,
                              color: TradeLinkColors.onSurface,
                              height: 1.15,
                            ),
                          ),

                          const Spacer(flex: 2),

                          // ── Tagline ──
                          Text(
                            'Mua bán an toàn,\nKết nối cộng đồng.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: TradeLinkColors.onSurface,
                              height: 1.5,
                            ),
                          ),

                          const Spacer(flex: 2),

                          // ── Security badge ──
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: TradeLinkSpacing.xl,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Shield icon with checkmark
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Shield shape
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: _ShieldPainter(),
                                        ),
                                      ),
                                      // Checkmark
                                      const Positioned(
                                        top: 6,
                                        left: 0,
                                        right: 0,
                                        child: IgnorePointer(
                                          child: Text(
                                            '✓',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: TradeLinkSpacing.sm),
                                // Text
                                Text(
                                  'Được bảo vệ bởi TradeLink',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: TradeLinkColors.onSurfaceVariant,
                                    letterSpacing: 0.01,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// iOS Status Bar
// ──────────────────────────────────────────────

class _iOSStatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: TradeLinkSpacing.lg + 4,
        right: TradeLinkSpacing.sm,
        top: TradeLinkSpacing.sm,
        bottom: TradeLinkSpacing.xs,
      ),
      color: Colors.white,
      child: Row(
        children: [
          // ── Time 9:41 ──
          const Text(
            '9:41',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
              letterSpacing: 0,
            ),
          ),
          const Spacer(),

          // ── Signal bars ──
          SizedBox(
            width: 18,
            height: 12,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(4, (i) {
                    final heights = [4.0, 7.0, 10.0, 12.0];
                    return Padding(
                      padding: const EdgeInsets.only(right: 1.5),
                      child: Container(
                        width: 3,
                        height: heights[i],
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          const SizedBox(width: TradeLinkSpacing.xs),

          // ── Wi-Fi icon ──
          SizedBox(
            width: 16,
            height: 12,
            child: CustomPaint(
              painter: _WiFiPainter(),
              size: const Size(16, 12),
            ),
          ),
          const SizedBox(width: TradeLinkSpacing.xs),

          // ── Battery icon ──
          SizedBox(
            width: 25,
            height: 12,
            child: CustomPaint(
              painter: _BatteryPainter(),
              size: const Size(25, 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Custom painters for iOS status bar icons
// ──────────────────────────────────────────────

class _WiFiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height;

    // Three concentric arcs
    for (int i = 0; i < 3; i++) {
      final radius = (2 + i * 3.5);
      final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
      canvas.drawArc(rect, -2.0, 4.0, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BatteryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final h = size.height;
    final w = size.width;

    // Battery body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w - 3, h),
      const Radius.circular(2),
    );
    canvas.drawRRect(bodyRect, paint);

    // Battery fill (roughly 75%)
    final fillPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    final fillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, (w - 7) * 0.75, h - 4),
      const Radius.circular(1),
    );
    canvas.drawRRect(fillRect, fillPaint);

    // Battery tip (the little + on the right)
    final tipPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w - 2.5, h * 0.25, 2.5, h * 0.5),
        const Radius.circular(1),
      ),
      tipPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ──────────────────────────────────────────────
// Shield icon painter — teal shield with notch
// ──────────────────────────────────────────────

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TradeLinkColors.tradeTeal
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final path = Path();

    // Shield shape: wider top, pointed bottom
    path.moveTo(w * 0.5, h * 0.95);          // bottom tip
    path.lineTo(w * 0.05, h * 0.65);         // bottom-left
    path.lineTo(w * 0.05, h * 0.25);         // top-left
    path.lineTo(w * 0.2, h * 0.1);           // left shoulder
    path.lineTo(w * 0.5, 0);                  // top center
    path.lineTo(w * 0.8, h * 0.1);           // right shoulder
    path.lineTo(w * 0.95, h * 0.25);         // top-right
    path.lineTo(w * 0.95, h * 0.65);         // bottom-right
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
