import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_screen.dart'; // apne folder ke hisab se path rakhein (e.g. '../login_screen.dart')

/// Asset paths – asal file names se match hone chahiye.
const String _kLogoAsset = 'assets/images/Logo.png';
const String _kBackgroundAsset = 'assets/images/GetStarted_bg.png';

// SparkClean dark theme
const Color _navy = Color(0xFF070B2A);
const Color _navyDeep = Color(0xFF04051A);
const Color _purple = Color(0xFF6F4FF2);
const Color _purpleLight = Color(0xFF9B7DFF);
const Color _accent = Color(0xFF9D8BFF);
const Color _subText = Color(0xFFC9C6F2);

/// SparkClean welcome screen (Get Started).
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..forward();

  late final Animation<double> _topFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
  );
  late final Animation<double> _textFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.25, 0.75, curve: Curves.easeOut),
  );
  late final Animation<Offset> _textSlide =
      Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
    CurvedAnimation(
      parent: _c,
      curve: const Interval(0.25, 0.8, curve: Curves.easeOutCubic),
    ),
  );
  late final Animation<double> _btnFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
  );
  late final Animation<Offset> _btnSlide =
      Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
    CurvedAnimation(
      parent: _c,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
    ),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _goLogin() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _navyDeep,
        body: Stack(
          children: [
            // ---- upar photo (overlay image me already hai) ----
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.56,
              child: Image.asset(
                _kBackgroundAsset,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) =>
                    const DecoratedBox(
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

            // ---- photo ke neeche navy fade (text ke liye) ----
          // ---- photo ke neeche navy fade (smooth, hard edge nahi) ----
Positioned.fill(
  child: DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.14, 0.34, 0.46, 0.55, 0.62, 1.0],
        colors: [
          _navyDeep.withAlpha(150),
          _navy.withAlpha(20),
          Colors.transparent,
          _navy.withAlpha(90),
          _navy.withAlpha(200),
          _navy,
          _navyDeep,
        ],
      ),
    ),
  ),
),

            // ---- content ----
            SafeArea(
              child: LayoutBuilder(
                builder: (context, box) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: box.maxHeight),
                      child: IntrinsicHeight(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 10),

                                  // ---- top bar: logo + name + Skip ----
                                  FadeTransition(
                                    opacity: _topFade,
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          _kLogoAsset,
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, st) =>
                                              const Icon(
                                            Icons.home_rounded,
                                            size: 40,
                                            color: _accent,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        RichText(
                                          text: const TextSpan(
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Spark',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              TextSpan(
                                                text: 'Clean',
                                                style:
                                                    TextStyle(color: _accent),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        InkWell(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          onTap: _goLogin,
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 8),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Text(
                                                //   'Skip',
                                                //   style: TextStyle(
                                                //     color: Colors.white,
                                                //     fontSize: 16,
                                                //     fontWeight:
                                                //         FontWeight.w600,
                                                //   ),
                                                // ),
                                                SizedBox(width: 4),
                                                Icon(
                                                  Icons.arrow_forward_rounded,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // photo ki jagah khali
                                  SizedBox(height: size.height * 0.40),

                                  // ---- headline + subtitle ----
                                  FadeTransition(
                                    opacity: _textFade,
                                    child: SlideTransition(
                                      position: _textSlide,
                                      child: Column(
                                        children: [
                                          RichText(
                                            textAlign: TextAlign.center,
                                            text: const TextSpan(
                                              style: TextStyle(
                                                fontSize: 36,
                                                height: 1.15,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              ),
                                              children: [
                                                TextSpan(
                                                    text:
                                                        'A Cleaner Home,\nOn Your '),
                                                TextSpan(
                                                  text: 'Schedule.',
                                                  style: TextStyle(
                                                      color: _purpleLight),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          const Text(
                                            'Book trusted home cleaning in just a few taps.\nPick your service, choose a time, and relax.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: _subText,
                                              fontSize: 15,
                                              height: 1.4,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // ---- 3 feature cards ----
                                  FadeTransition(
                                    opacity: _textFade,
                                    child: const Row(
                                      children: [
                                        Expanded(
                                          child: _FeatureCard(
                                            icon: Icons.verified_user_outlined,
                                            line1: 'Trusted',
                                            line2: 'cleaners',
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: _FeatureCard(
                                            icon: Icons.calendar_month_rounded,
                                            line1: 'Flexible',
                                            line2: 'booking',
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: _FeatureCard(
                                            icon: Icons.auto_awesome_rounded,
                                            line1: 'Sparkling',
                                            line2: 'results',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Spacer(),
                                  const SizedBox(height: 22),

                                  // ---- Get Started button ----
                                  FadeTransition(
                                    opacity: _btnFade,
                                    child: SlideTransition(
                                      position: _btnSlide,
                                      child: _PrimaryButton(
                                        label: 'Get Started',
                                        onTap: _goLogin,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // ---- footer line ----
                                  FadeTransition(
                                    opacity: _btnFade,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 2,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Colors.transparent,
                                                  _purple,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Text(
                                            'Your home deserves a fresh start.',
                                            style: TextStyle(
                                              color: _subText,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 2,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                              gradient: const LinearGradient(
                                                colors: [
                                                  _purple,
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
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
          ],
        ),
      ),
    );
  }
}

/// Chota feature card (icon + 2 line text).
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.line1,
    required this.line2,
  });

  final IconData icon;
  final String line1;
  final String line2;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withAlpha(14),
        border: Border.all(color: Colors.white.withAlpha(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _purpleLight, size: 30),
          const SizedBox(height: 10),
          Text(
            '$line1\n$line2',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Purple gradient button.
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_purpleLight, _purple],
        ),
        boxShadow: [
          BoxShadow(
            color: _purple.withAlpha(140),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
