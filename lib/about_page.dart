import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
//  DARK THEME COLORS (profile page jaise hi)
// ---------------------------------------------------------------------------
const Color _bg = Color(0xFF0D0A22);
const Color _top = Color(0xFF1A1250);
const Color _card = Color(0xFF1A1640);
const Color _border = Color(0xFF2E2763);
const Color _iconBg = Color(0xFF2A2360);
const Color _accent = Color(0xFF9B7DFF);
const Color _primary = Color(0xFF6F4FF2);
const Color _sub = Colors.white60;

const String kAppVersion = '1.0.0';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_top, _bg],
              stops: [0.0, 0.35],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 20, 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'About SparkClean',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                // body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                    child: Column(
                      children: [
                        const _Logo(),
                        const SizedBox(height: 16),
                        const Text(
                          'SparkClean',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Clean Homes. Brighter Living.',
                          style: TextStyle(color: _sub, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: _iconBg,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: _border),
                          ),
                          child: Text(
                            'Version $kAppVersion',
                            style: const TextStyle(
                              color: _accent,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Who we are
                        const _SectionTitle('Who We Are'),
                        const _InfoCard(
                          child: Text(
                            'SparkClean apartment residents ke liye bani ek '
                            'easy cleaning booking app hai. Bas service chuno, '
                            'date aur time select karo, package pasand karo '
                            'aur booking confirm karo. Baaki kaam hamare '
                            'trained professionals sambhal lete hain.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13.5,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // What we offer
                        const _SectionTitle('What We Offer'),
                        const _ServiceChips(),
                        const SizedBox(height: 22),

                        // Why SparkClean
                        const _SectionTitle('Why SparkClean'),
                        const _InfoCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _Feature(
                                icon: Icons.verified_user_rounded,
                                title: 'Trusted Professionals',
                                sub: 'Verified aur trained cleaning staff',
                              ),
                              _Sep(),
                              _Feature(
                                icon: Icons.eco_rounded,
                                title: 'Eco-friendly Products',
                                sub: 'Aapke ghar aur family ke liye safe',
                              ),
                              _Sep(),
                              _Feature(
                                icon: Icons.shield_rounded,
                                title: 'Secure & Reliable',
                                sub: 'Aapka data hamesha safe rehta hai',
                              ),
                              _Sep(),
                              _Feature(
                                icon: Icons.support_agent_rounded,
                                title: '24/7 Support',
                                sub: 'Hum yahan hain jab bhi zaroorat ho',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26),

                        // footer
                        const Text(
                          'Better Management, Happier Residents',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _accent,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '© 2025 SparkClean. All rights reserved.',
                          style: TextStyle(color: _sub, fontSize: 12),
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
    );
  }
}

// ---------------------------------------------------------------------------
//  LOGO (house + sparkle)
// ---------------------------------------------------------------------------
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B2A9A), Color(0xFF7A5CF0)],
        ),
        border: Border.all(color: _accent.withAlpha(120), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _primary.withAlpha(110),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.home_rounded, color: Colors.white, size: 54),
          Positioned(
            top: 14,
            right: 14,
            child: Icon(Icons.auto_awesome_rounded,
                color: Color(0xFFE2D8FF), size: 20),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  SMALL WIDGETS
// ---------------------------------------------------------------------------
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: child,
    );
  }
}

class _Sep extends StatelessWidget {
  const _Sep();

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: _border.withAlpha(180));
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.title, required this.sub});
  final IconData icon;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: _iconBg),
            child: Icon(icon, color: _accent, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(color: _sub, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceChips extends StatelessWidget {
  const _ServiceChips();

  static const _items = <(IconData, String)>[
    (Icons.home_outlined, 'Regular'),
    (Icons.auto_awesome_outlined, 'Deep'),
    (Icons.kitchen_outlined, 'Kitchen'),
    (Icons.bathtub_outlined, 'Bathroom'),
    (Icons.local_shipping_outlined, 'Move-in/Out'),
    (Icons.business_center_outlined, 'Office'),
    (Icons.weekend_outlined, 'Sofa'),
    (Icons.layers_outlined, 'Carpet'),
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final it in _items)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(it.$1, color: _accent, size: 18),
                  const SizedBox(width: 7),
                  Text(
                    it.$2,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
