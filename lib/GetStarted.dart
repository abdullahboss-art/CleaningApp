import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_screen.dart'; // apne folder ke hisab se path rakhein (e.g. '../login_screen.dart')

/// Asset paths – asal file names se match hone chahiye.
const String _kLogoAsset = 'assets/images/Logo.png';
const String _kBackgroundAsset = 'assets/images/bg_image.png';

// Login / Sign Up jaisi dark theme
const Color _bgTop = Color(0xFF171049);
const Color _bgBottom = Color(0xFF090714);
const Color _purple = Color(0xFF6F4FF2);
const Color _purpleLight = Color(0xFF8B6CFF);
const Color _accent = Color(0xFF8E7BFF);

/// SparkClean welcome screen (Get Started).
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Login screen par seedha jaata hai (named route ki zaroorat nahi)
  void _goLogin() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bgBottom,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background image (na mile to dark gradient)
            Image.asset(
              _kBackgroundAsset,
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_bgTop, _bgBottom],
                  ),
                ),
              ),
            ),

            // Dark navy overlay (neeche ka hissa zyada gehra, button saaf dikhe)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _bgTop.withAlpha(225),
                    _bgTop.withAlpha(110),
                    _bgBottom.withAlpha(170),
                    _bgBottom.withAlpha(245),
                  ],
                  stops: const [0.0, 0.40, 0.75, 1.0],
                ),
              ),
            ),

            // upar halki purple chamak
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.7),
                  radius: 0.85,
                  colors: [
                    _purple.withAlpha(75),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  // Chhoti screen par scroll, bari par max-width 420
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final h = box.maxHeight;
                      final logo = (h * 0.13).clamp(70.0, 110.0).toDouble();
                      final title = (h * 0.045).clamp(28.0, 38.0).toDouble();

                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: h),
                          child: IntrinsicHeight(
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 420),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 28),
                                  child: Column(
                                    children: [
                                      SizedBox(height: h * 0.07),

                                      // Logo (halki purple glow ke saath)
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: _purple.withAlpha(110),
                                              blurRadius: 44,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Image.asset(
                                          _kLogoAsset,
                                          width: logo,
                                          height: logo,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(
                                            Icons.cleaning_services_rounded,
                                            size: logo * 0.85,
                                            color: _accent,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Title
                                      Text(
                                        'SparkClean',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: title,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Tagline
                                      Text(
                                        'Clean Homes. Brighter Living.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(215),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                        ),
                                      ),

                                      const Spacer(),
                                      const SizedBox(height: 24),

                                      // Get Started -> Login page
                                      _GetStartedButton(
                                        label: 'Get Started',
                                        onTap: _goLogin,
                                      ),
                                      const SizedBox(height: 32),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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

/// Purple gradient button (login jaisa).
class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_purpleLight, _purple],
        ),
        boxShadow: [
          BoxShadow(
            color: _purple.withAlpha(120),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}