import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'auth_service.dart';
import 'booking_details_page.dart';
import 'login_screen.dart';

// ---------------------------------------------------------------------------
//  IMAGE PATHS  (sab images assets/images/ folder me rakhni hain)
// ---------------------------------------------------------------------------
const String kHeroImg = 'assets/images/Girl_image.png'; // banner ki image (right side)

// Banner image ki setting (yahin se aasani se badal sakte ho)
// contain = poori image dikhti hai | cover = banner bhar deti hai (kat sakti hai)
const BoxFit kHeroFit = BoxFit.contain;
const Alignment kHeroAlign = Alignment.bottomRight; // image ko neeche/right rakhta hai
const double kHeroWidthFactor = 0.52; // screen width ka kitna hissa image ko

const String kUserAddress = 'Flat 1203, Tower A';

// ---------------------------------------------------------------------------
//  DARK THEME COLORS
// ---------------------------------------------------------------------------
const Color _pageBg = Color(0xFF0D0A22);
const Color _headerTop = Color(0xFF241A5E);
const Color _cardBg = Color(0xFF1A1640);
const Color _cardBorder = Color(0xFF2E2763);
const Color _iconBg = Color(0xFF2A2360);
const Color _textColor = Colors.white;
const Color _accent = Color(0xFF9B7DFF);

// 3 per row x 2 rows: 5 services + "More" tile. More dabane par saari services.
const int _collapsedCount = 5;

void _openBooking(BuildContext context, _Item item) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BookingDetailsPage(
        title: item.title,
        desc: item.desc,
        price: item.price,
        image: item.image,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
//  DATA
// ---------------------------------------------------------------------------
class _Item {
  const _Item({
    required this.title,
    required this.tileTitle,
    required this.desc,
    required this.price,
    required this.image,
    required this.icon,
  });
  final String title;
  final String tileTitle;
  final String desc;
  final int price;
  final String image;
  final IconData icon;
}

const List<_Item> _categories = [
  _Item(
    title: 'Home Cleaning',
    tileTitle: 'Regular\nCleaning',
    desc: 'Keep your home spotless',
    price: 49,
    image: 'assets/images/Room_Cleaning.jpg',
    icon: Icons.home_outlined,
  ),
  _Item(
    title: 'Deep Cleaning',
    tileTitle: 'Deep\nCleaning',
    desc: 'A deeper clean for better living',
    price: 79,
    image: 'assets/images/Room_Cleaning.jpg',
    icon: Icons.auto_awesome_outlined,
  ),
  _Item(
    title: 'Kitchen Cleaning',
    tileTitle: 'Kitchen\nCleaning',
    desc: 'Shine your kitchen',
    price: 39,
    image: 'assets/images/Room_Cleaning.jpg',
    icon: Icons.kitchen_outlined,
  ),
  _Item(
    title: 'Bathroom Cleaning',
    tileTitle: 'Bathroom\nCleaning',
    desc: 'Fresh & Hygienic',
    price: 29,
    image: 'assets/images/Room_Cleaning.jpg',
    icon: Icons.bathtub_outlined,
  ),
  _Item(
    title: 'Move-In/Move-Out',
    tileTitle: 'Move-in/Out\nCleaning',
    desc: 'Fresh start, spotless space',
    price: 99,
    image: 'assets/images/Room_Cleaning.jpg',
    icon: Icons.local_shipping_outlined,
  ),
  _Item(
    title: 'Office Cleaning',
    tileTitle: 'Office\nCleaning',
    desc: 'Professional workspace',
    price: 89,
    image: 'assets/images/Room_Cleaning.jpg',
    icon: Icons.business_center_outlined,
  ),
  _Item(
    title: 'Sofa Cleaning',
    tileTitle: 'Sofa\nCleaning',
    desc: 'Revive your furniture',
    price: 59,
    image: 'assets/images/Room_Cleaning.jpg',
    icon: Icons.weekend_outlined,
  ),
  _Item(
    title: 'Carpet Cleaning',
    tileTitle: 'Carpet\nCleaning',
    desc: 'Remove stains & dirt',
    price: 45,
    image: 'assets/images/Room_Cleaning.jpg',
    icon: Icons.layers_outlined,
  ),
];

String _greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good Morning,';
  if (h < 17) return 'Good Afternoon,';
  return 'Good Evening,';
}

// ---------------------------------------------------------------------------
//  PAGE
// ---------------------------------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _expanded = false;

  Future<void> _logout() async {
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final shown =
        _expanded ? _categories : _categories.take(_collapsedCount).toList();
    final screenH = MediaQuery.of(context).size.height;
    final bannerH = (screenH * 0.24).clamp(170.0, 230.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: _pageBg,
        drawer: _AppDrawer(onLogout: _logout),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_headerTop, _pageBg],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(
                    onAvatarTap: () => _scaffoldKey.currentState?.openDrawer()),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: _pageBg,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(28)),
                      child: SingleChildScrollView(
                        // neeche extra padding: apna bottom nav isi ke upar aayega
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HeroBanner(
                              height: bannerH,
                              onTap: () =>
                                  _openBooking(context, _categories.first),
                            ),
                            const SizedBox(height: 26),
                            const Text(
                              'Our Services',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: _textColor,
                              ),
                            ),
                            const SizedBox(height: 14),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              alignment: Alignment.topCenter,
                              child: _ServiceGrid(
                                items: shown,
                                expanded: _expanded,
                                onToggle: () =>
                                    setState(() => _expanded = !_expanded),
                              ),
                            ),
                            const SizedBox(height: 26),
                            const Text(
                              'Why Choose Us',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: _textColor,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const _TrustStrip(),
                            const SizedBox(height: 22),
                            _OfferCard(
                              onTap: () =>
                                  _openBooking(context, _categories.first),
                            ),
                          ],
                        ),
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
//  SERVICE GRID (1 row me 3 icon tiles, aakhir me More / Less)
// ---------------------------------------------------------------------------
class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid({
    required this.items,
    required this.expanded,
    required this.onToggle,
  });
  final List<_Item> items;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        const gap = 12.0;
        final w = (box.maxWidth - gap * 2) / 3;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final c in items)
              SizedBox(
                width: w,
                child: _IconTile(
                  icon: c.icon,
                  label: c.tileTitle,
                  onTap: () => _openBooking(context, c),
                ),
              ),
            SizedBox(
              width: w,
              child: _IconTile(
                icon: expanded
                    ? Icons.expand_less_rounded
                    : Icons.more_horiz_rounded,
                label: expanded ? 'Less' : 'More',
                onTap: onToggle,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
//  AVATAR
// ---------------------------------------------------------------------------
class _Avatar extends StatelessWidget {
  const _Avatar({required this.user, this.radius = 25});
  final User? user;
  final double radius;

  String? get _photo {
    var url = user?.photoURL;
    if (url == null || url.isEmpty) {
      for (final p in user?.providerData ?? const <UserInfo>[]) {
        if (p.photoURL != null && p.photoURL!.isNotEmpty) {
          url = p.photoURL;
          break;
        }
      }
    }
    if (url == null || url.isEmpty) return null;
    return url.replaceAll(RegExp(r'=s\d+-c'), '=s200-c');
  }

  String get _initial {
    final n = user?.displayName?.trim();
    if (n != null && n.isNotEmpty) return n[0].toUpperCase();
    final e = user?.email;
    if (e != null && e.isNotEmpty) return e[0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;

    Widget letter() => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              color: Colors.white, shape: BoxShape.circle),
          child: Text(
            _initial,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: radius * 0.9,
              fontWeight: FontWeight.w800,
            ),
          ),
        );

    final photo = _photo;
    if (photo == null) return letter();

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          photo,
          fit: BoxFit.cover,
          // Web par Google photo CORS ki wajah se fail hoti hai, isliye
          // HTML <img> par fallback
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : letter(),
          errorBuilder: (_, e, __) => letter(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  HEADER
// ---------------------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header({required this.onAvatarTap});
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final name = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : 'Welcome';

    // DEBUG: photo kyun nahi aa rahi? Console me dekho (kaam hone ke baad hata dena)
    debugPrint('AVATAR photoURL=${user?.photoURL} | providers=' +
        (user?.providerData ?? const <UserInfo>[])
            .map((p) => '${p.providerId}:${p.photoURL}')
            .join(', '));

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: _Avatar(user: user, radius: 26),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()}\n$name',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  kUserAddress,
                  style: TextStyle(color: Colors.white60, fontSize: 12.5),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  // TODO: notifications page kholein
                },
                icon: const Icon(Icons.notifications_rounded,
                    size: 30, color: Colors.white),
              ),
              Positioned(
                right: 12,
                top: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: _headerTop, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  HERO BANNER
// ---------------------------------------------------------------------------
class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onTap, required this.height});
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B2A9A).withAlpha(60),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B2A9A), Color(0xFF7A5CF0)],
              ),
            ),
            child: Stack(
              children: [
                // right side image (left edge fade hoti hai)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: MediaQuery.of(context).size.width * kHeroWidthFactor,
                  child: ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.transparent, Colors.black],
                      stops: [0.0, 0.35],
                    ).createShader(rect),
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      kHeroImg,
                      fit: kHeroFit,
                      alignment: kHeroAlign,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'A Cleaner Home\nA Happier You',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Professional cleaning\nservices for your apartment.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
//  ICON TILE (services aur Why Choose Us dono isi ko use karte hain)
// ---------------------------------------------------------------------------
BoxDecoration _tileDecoration() => BoxDecoration(
      color: _cardBg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _cardBorder),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(90),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _tileDecoration(),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: SizedBox(
            height: 112,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _iconBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: _accent, size: 26),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      color: _textColor,
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

// ---------------------------------------------------------------------------
//  WHY CHOOSE US (1 row me 3, services jaisi hi tiles)
// ---------------------------------------------------------------------------
class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _IconTile(
              icon: Icons.verified_user_outlined,
              label: 'Trusted\nProfessionals'),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _IconTile(
              icon: Icons.eco_outlined, label: 'Eco-friendly\nProducts'),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _IconTile(
              icon: Icons.thumb_up_alt_outlined, label: '100%\nSatisfaction'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  OFFER CARD (page ke neeche ka hissa bharta hai)
// ---------------------------------------------------------------------------
class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B2A9A), Color(0xFF7A5CF0)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B2A9A).withAlpha(50),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.local_offer_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'First Booking Offer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Get 20% off on your first cleaning',
                  style: TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3B2A9A),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  DRAWER
// ---------------------------------------------------------------------------
class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.onLogout});
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    return Drawer(
      backgroundColor: _pageBg,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 24, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_headerTop, _cardBg],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(user: user, radius: 32),
                const SizedBox(height: 12),
                Text(
                  user?.displayName ?? 'Welcome',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (user?.email != null)
                  Text(user!.email!,
                      style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const Spacer(),
          const Divider(height: 1, color: _cardBorder),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: _textColor)),
            onTap: onLogout,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}