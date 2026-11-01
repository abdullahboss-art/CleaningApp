import 'package:cleaning/Admin_Penel/Buttom.dart'; // HomeShell (admin + bottom nav)
import 'package:cleaning/Admin_Penel/admin_config.dart';
import 'package:cleaning/GetStarted.dart'; // WelcomeScreen (Get Started)
import 'package:cleaning/main_shell.dart'; // Home + bottom navigation
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
//  DARK THEME COLORS (sirf is file ke liye)
// ---------------------------------------------------------------------------
const Color _bgTop = Color(0xFF171049);
const Color _bgBottom = Color(0xFF090714);
const Color _accent = Color(0xFF8E7BFF);
const Color _hint = Color(0xFF8C93B5);
const Color _barStart = Color(0xFF8B6CFF);
const Color _barEnd = Color(0xFF6F4FF2);
const Color _track = Color(0xFF121A38);

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.duration = const Duration(seconds: 2),
  });

  final Duration duration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 0.85,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ),
  );

  late final AnimationController _loader = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller.forward();
    _loader.forward();

    _start();
  }

  /// Loader chalta rahe, sath hi sath auth check hota rahe (parallel).
  /// Loader poora hote hi agli screen khul jati hai.
  Future<void> _start() async {
    final pageFuture = _decidePage();
    await Future.delayed(widget.duration);
    final page = await pageFuture;
    if (!mounted || _navigated) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  /// - admin (password login ya Google admin email) -> HomeShell (bottom nav ke sath)
  /// - baqi login user                              -> Home (MainShell)
  /// - login nahi (pehli baar / logout)             -> Get Started
  Future<Widget> _decidePage() async {
    // admin@gmail.com + 123456 wala saved session pehle dekho
    final adminSession = await hasAdminSession();

    // Firebase se saved login session check karein.
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
      return const HomeShell(); // login wali same screen (bottom nav ke sath)
    } else if (user != null) {
      return const MainShell();
    } else {
      return const WelcomeScreen();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _loader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bgBottom,
        body: Stack(
          children: [
            // dark gradient
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_bgTop, _bgBottom],
                  ),
                ),
              ),
            ),

            // upar halki purple chamak
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.35),
                    radius: 0.85,
                    colors: [
                      _barEnd.withAlpha(90),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Logo, app name and tagline (beech me)
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(
                      scale: _scale,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _barEnd.withAlpha(110),
                                  blurRadius: 50,
                                  spreadRadius: 6,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/Logo.png',
                              width: 130,
                              height: 130,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('Logo.png load nahi hua: $error');
                                return const Icon(
                                  Icons.cleaning_services_rounded,
                                  size: 100,
                                  color: _accent,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'SparkClean',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Clean Homes. Brighter Living.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _hint,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom loader and welcome message
            Positioned(
              left: 24,
              right: 24,
              bottom: 36,
              child: SafeArea(
                top: false,
                child: FadeTransition(
                  opacity: _fade,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LineLoader(progress: _loader),
                      const SizedBox(height: 18),
                      const Text(
                        'Welcome to SparkClean',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineLoader extends StatelessWidget {
  const _LineLoader({
    required this.progress,
  });

  final Animation<double> progress;

  static const double _width = 220;
  static const double _height = 7;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final percent = (progress.value * 100).round();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: _width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Loading...',
                    style: TextStyle(
                      color: _hint,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: _width,
                height: _height,
                color: _track,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress.value,
                  child: Container(
                    height: _height,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_barStart, _barEnd],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: _barEnd.withAlpha(140),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}