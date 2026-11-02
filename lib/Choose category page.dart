import 'package:cleaning/booking_summary_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Currency yahan ek jagah se badal sakte hain (AED / PKR / $ ...)
const String kCurrency = 'AED';

// ---------------------------------------------------------------------------
//  DARK THEME COLORS (sirf is file ke liye)
// ---------------------------------------------------------------------------
const Color _bg = Color(0xFF0D0A22);
const Color _top = Color(0xFF1A1250);
const Color _card = Color(0xFF1A1640);
const Color _line = Color(0xFF2E2763);
const Color _soft = Color(0xFF2A2360);
const Color _selectedBg = Color(0xFF241E55);
const Color _accent = Color(0xFF9B7DFF);
const Color _primary = Color(0xFF6F4FF2);
const Color _sub = Colors.white60;

// ---------------------------------------------------------------------------
//  DATA  (naam, rate, description)
//  Images assets/images/ me rakho: pkg_premium.png, pkg_diamond.png,
//  pkg_silver.png, pkg_platinum.png
// ---------------------------------------------------------------------------
class _Package {
  const _Package({
    required this.name,
    required this.price,
    required this.duration,
    required this.line1,
    required this.line2,
    required this.bg,
    required this.accent,
    required this.image,
    required this.icon,
  });

  final String name;
  final int price;
  final String duration; // e.g. "3 - 4 Hours" (summary page par jata hai)
  final String line1;
  final String line2;
  final Color bg; // summary page ke liye
  final Color accent; // icon ka rang + summary page
  final String image; // gol image (na mile to icon dikhta hai)
  final IconData icon;
}

const List<_Package> _packages = [
  _Package(
    name: 'Silver',
    price: 20,
    duration: '3 - 4 Hours',
    line1: 'Extra detailed cleaning',
    line2: 'Includes kitchen & bathrooms',
    bg: Color(0xFFF1F1F5),
    accent: Color(0xFF4A4A58),
    image: 'assets/images/Silver.png',
    icon: Icons.shield_rounded,
  ),
  _Package(
    name: 'Platinum',
    price: 40,
    duration: '3 - 4 Hours',
    line1: 'Complete home cleaning',
    line2: 'Best for a fresh and healthy home',
    bg: Color(0xFFFFF2D9),
    accent: Color(0xFFD9962A),
    image: 'assets/images/Platimium.png',
    icon: Icons.workspace_premium_rounded,
  ),
  _Package(
    name: 'Diamond',
    price: 60,
    duration: '2 - 3 Hours',
    line1: 'Detailed cleaning',
    line2: 'More time, deeper cleaning',
    bg: Color(0xFFE9F0FF),
    accent: Color(0xFF3B6FE0),
    image: 'assets/images/Dimand.png',
    icon: Icons.diamond_rounded,
  ),
];

// ---------------------------------------------------------------------------
//  PAGE
// ---------------------------------------------------------------------------
/// Booking Details (date + time) ke baad ye screen khulti hai.
class ChooseCategoryPage extends StatefulWidget {
  const ChooseCategoryPage({
    super.key,
    required this.serviceTitle,
    required this.date,
    required this.time,
  });

  final String serviceTitle; // e.g. "Home Cleaning"
  final DateTime date; // pichle page par chuni hui tareekh
  final TimeOfDay time; // pichle page par chuna hua time

  @override
  State<ChooseCategoryPage> createState() => _ChooseCategoryPageState();
}

class _ChooseCategoryPageState extends State<ChooseCategoryPage> {
  int? _selected; // card par tap = sirf select, Next dabane par aage

  void _next() {
    final i = _selected;
    if (i == null) return;
    final p = _packages[i];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingSummaryPage(
          serviceTitle: widget.serviceTitle,
          packageName: p.name,
          price: p.price,
          duration: p.duration,
          date: widget.date,
          time: widget.time,
          packageImage: p.image,
          accent: p.accent,
          cardBg: p.bg,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPick = _selected != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_top, _bg],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ---- top bar: back + title ----
                SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const Expanded(
                        child: Text(
                          'Choose a Package',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ---- dark rounded sheet ----
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: _bg,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28)),
                      child: Column(
                        children: [
                          // ---- package cards ----
                          Expanded(
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(18, 20, 18, 8),
                              itemCount: _packages.length,
                              itemBuilder: (_, i) => _PackageCard(
                                pkg: _packages[i],
                                selected: _selected == i,
                                onTap: () => setState(() => _selected = i),
                              ),
                            ),
                          ),

                          // ---- Next button ----
                          SafeArea(
                            top: false,
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(18, 8, 18, 14),
                              child: SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: hasPick ? _next : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        _primary.withAlpha(90),
                                    disabledForegroundColor: Colors.white70,
                                    elevation: 6,
                                    shadowColor: _primary.withAlpha(100),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  child: const Text('Next',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ),
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
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  PACKAGE CARD
// ---------------------------------------------------------------------------
class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.pkg,
    required this.selected,
    required this.onTap,
  });

  final _Package pkg;
  final bool selected;
  final VoidCallback onTap;

  // dark background par accent dikhe, isliye thoda halka kiya
  Color get _lightAccent => Color.lerp(pkg.accent, Colors.white, 0.45)!;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _selectedBg : _card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? _primary : _line,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? _primary.withAlpha(70)
                  : Colors.black.withAlpha(80),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _icon(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pkg.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$kCurrency ${pkg.price}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pkg.line1,
                    style: const TextStyle(
                        fontSize: 12.5, color: _sub, height: 1.3),
                  ),
                  Text(
                    pkg.line2,
                    style: const TextStyle(
                        fontSize: 12.5, color: _sub, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _radio(),
          ],
        ),
      ),
    );
  }

  // gol image (apni image milne par wohi dikhti hai, warna icon)
  Widget _icon() {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _soft,
        border: Border.all(color: _lightAccent.withAlpha(110)),
      ),
      child: ClipOval(
        child: Image.asset(
          pkg.image,
          fit: BoxFit.cover,
          width: 62,
          height: 62,
          errorBuilder: (_, __, ___) =>
              Icon(pkg.icon, size: 32, color: _lightAccent),
        ),
      ),
    );
  }

  // right side radio: select hone par purple circle me check
  Widget _radio() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? _primary : Colors.transparent,
        border: Border.all(
          color: selected ? _primary : Colors.white38,
          width: 1.8,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
          : null,
    );
  }
}
