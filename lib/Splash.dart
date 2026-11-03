import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:cleaning/Admin_Penel/Buttom.dart';
import 'package:cleaning/Admin_Penel/admin_config.dart';
import 'package:cleaning/GetStarted.dart';
import 'package:cleaning/main_shell.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
//  THEME
// ---------------------------------------------------------------------------
const Color _navy = Color(0xFF070B2A);
const Color _navyDeep = Color(0xFF04051A);
const Color _accent = Color(0xFF9D8BFF);
const Color _hint = Color(0xFFC9C6F2);
const Color _barStart = Color(0xFFB79CFF);
const Color _barEnd = Color(0xFF6F4FF2);

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 3500),
  });

  /// 1% se 100% tak kul time
  final Duration duration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
  );
  late final Animation<double> _logoScale = Tween<double>(begin: 0.85, end: 1)
      .animate(CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
  ));
  late final Animation<double> _textFade = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.3, 0.85, curve: Curves.easeOut),
  );
  late final Animation<double> _bottomFade = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
  );

  // dots + wave ke liye
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  // loader ka percent (1..100)
  final ValueNotifier<int> _percent = ValueNotifier<int>(1);
  Timer? _timer;

  bool _navigated = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _intro.forward();

    // pehla frame draw hone ke baad loader shuru (taake 1% zaroor dikhe)
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  /// 1, 2, 3 ... 100 : har tick par sirf +1 (number skip nahi hota).
  Future<void> _runLoader() {
    final completer = Completer<void>();
    final stepMs = (widget.duration.inMilliseconds / 99).round();

    _timer = Timer.periodic(Duration(milliseconds: stepMs), (t) {
      if (_disposed) {
        t.cancel();
        if (!completer.isCompleted) completer.complete();
        return;
      }
      if (_percent.value < 100) {
        _percent.value = _percent.value + 1;
      }
      if (_percent.value >= 100) {
        t.cancel();
        if (!completer.isCompleted) completer.complete();
      }
    });

    return completer.future;
  }

  /// Loader 1% se 100% tak poora chalta hai, sath hi auth check (parallel).
  /// 100% par thora ruk kar agli screen khulti hai.
  Future<void> _start() async {
    final pageFuture = _decidePage();

    await _runLoader();
    if (_disposed) return;

    // 100% screen par thora dikhe
    await Future.delayed(const Duration(milliseconds: 400));

    final page = await pageFuture;
    if (!mounted || _navigated) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  /// - admin (password login ya Google admin email) -> HomeShell
  /// - baqi login user                              -> MainShell
  /// - login nahi (pehli baar / logout)             -> Get Started
  Future<Widget> _decidePage() async {
    final adminSession = await hasAdminSession();

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null && !adminSession) {
      try {
        user = await FirebaseAuth.instance
            .authStateChanges()
            .first
            .timeout(const Duration(seconds: 2));
      } catch (_) {
        user = null;
      }
    }

    debugPrint('SPLASH: adminSession=$adminSession emails=${emailsOf(user)}');

    if (adminSession || isAdminUser(user)) {
      return const HomeShell();
    } else if (user != null) {
      return const MainShell();
    } else {
      return const WelcomeScreen();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _intro.dispose();
    _pulse.dispose();
    _percent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _navyDeep,
        body: Stack(
          children: [
            // ---- upar room photo ----
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.62,
              child: Image.asset(
                'assets/images/Loader_background.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF2A2470), _navy],
                    ),
                  ),
                ),
              ),
            ),

            // ---- photo ke neeche dark navy fade ----
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.40, 0.58, 0.72, 1.0],
                    colors: [
                      _navy.withAlpha(60),
                      _navy.withAlpha(20),
                      _navy.withAlpha(235),
                      _navy,
                      _navyDeep,
                    ],
                  ),
                ),
              ),
            ),

            // ---- bottom purple wave glow ----
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 90,
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => CustomPaint(
                  painter: _WavePainter(_pulse.value),
                ),
              ),
            ),

            // ---- CONTENT: ek hi Column, isliye kuch overlap nahi hota ----
            SafeArea(
              child: LayoutBuilder(
                builder: (context, box) {
                  final h = box.maxHeight;
                  final logo = (h * 0.13).clamp(72.0, 100.0).toDouble();
                  final name = (h * 0.055).clamp(32.0, 42.0).toDouble();
                  final tag = (h * 0.025).clamp(15.0, 19.0).toDouble();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Spacer(flex: 6),

                        // logo + name + tagline
                        FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: Image.asset(
                              'assets/images/Logo.png',
                              width: logo,
                              height: logo,
                              fit: BoxFit.contain,
                              errorBuilder: (_, e, __) {
                                debugPrint('Logo.png load nahi hua: $e');
                                return Icon(
                                  Icons.home_rounded,
                                  size: logo * 0.9,
                                  color: _accent,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        FadeTransition(
                          opacity: _textFade,
                          child: Column(
                            children: [
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: name,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Spark',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    TextSpan(
                                      text: 'Clean',
                                      style: TextStyle(color: _accent),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Clean spaces. Clear minds.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _hint,
                                  fontSize: tag,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(flex: 1),

                        // status text + dots
                        FadeTransition(
                          opacity: _bottomFade,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Preparing your fresh start...',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(235),
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              AnimatedBuilder(
                                animation: _pulse,
                                builder: (_, __) => _Dots(t: _pulse.value),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 26),

                        // patli line + neeche 1% -> 100%
                        FadeTransition(
                          opacity: _bottomFade,
                          child: _LineLoader(percent: _percent),
                        ),

                        const SizedBox(height: 46),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  LINE LOADER: patli glowing line, neeche percent (1% -> 100%)
// ---------------------------------------------------------------------------
class _LineLoader extends StatelessWidget {
  const _LineLoader({required this.percent});

  final ValueListenable<int> percent;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: percent,
      builder: (context, p, _) {
        final v = p / 100.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 4,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    // track
                    Container(color: Colors.white.withAlpha(28)),
                    // fill
                    FractionallySizedBox(
                      widthFactor: v,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_barEnd, _barStart],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _barEnd.withAlpha(200),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$p%',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.6,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
//  3 dots: smooth wave (ek ke baad ek upar uthte, bade aur roshan hote hain)
// ---------------------------------------------------------------------------
class _Dots extends StatelessWidget {
  const _Dots({required this.t});
  final double t; // 0..1 (loop)

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26, // bounce ke liye jagah, kisi aur cheez se takra nahi hota
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (i) {
          // har dot thora late: wave jaisa effect
          final phase = (t - i * 0.16) * 2 * math.pi;
          final s = (math.sin(phase - math.pi / 2) + 1) / 2; // 0..1

          final size = 8 + 5 * s;
          final lift = 8 * s;
          final color = Color.lerp(_barEnd.withAlpha(140), _barStart, s)!;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Transform.translate(
              offset: Offset(0, -lift),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: _barEnd.withAlpha((40 + 170 * s).round()),
                      blurRadius: 4 + 10 * s,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Neeche glowing purple wave
// ---------------------------------------------------------------------------
class _WavePainter extends CustomPainter {
  _WavePainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final shift = math.sin(t * math.pi * 2) * 10;

    final path = Path()..moveTo(0, size.height * 0.55 + shift);
    path.cubicTo(
      size.width * 0.25, size.height * 0.15 - shift,
      size.width * 0.6, size.height * 0.95 + shift,
      size.width, size.height * 0.45 - shift,
    );

    // glow
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = _barEnd.withAlpha(170)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // line
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..shader = const LinearGradient(
          colors: [_barEnd, _barStart, _barEnd],
        ).createShader(Offset.zero & size),
    );

    // wave ke neeche halka purple fill
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_barEnd.withAlpha(70), Colors.transparent],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.t != t;
}
