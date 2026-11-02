import 'package:cleaning/app_data.dart';
import 'admin_config.dart'; // adminLogout(), adminLoginEmail (folder alag ho to path badlo)
import 'package:cleaning/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  /// Shell se aata hai: Bookings tab kholne ke liye
  final void Function(String filter, Booking? booking)? onOpenBookings;

  const AdminHomePage({super.key, this.onOpenBookings});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  static const _bg = Color(0xFF0B0B18);
  static const _card = Color(0xFF121C30);
  static const _border = Color(0xFF1F2B45);
  static const _purple = Color(0xFF8B5CF6);
  static const _muted = Color(0xFF8A94A8);
  static const _green = Color(0xFF2EC27E);
  static const _orange = Color(0xFFFFA726);
  static const _red = Color(0xFFFF4D4F);
  static const _blue = Color(0xFF4DA3FF);

  // SAB users ki bookings, Firestore se live (pehle sirf local list thi)
  late final Stream<List<Booking>> _stream = BookingStore.allStream();

  void _open(String filter, [Booking? booking]) =>
      widget.onOpenBookings?.call(filter, booking);

  // ---------------- profile + logout ----------------
  Future<void> _logout() async {
    final nav = Navigator.of(context);
    // Agar push_service.dart lagayi hai to ye line chalu karo (is phone par
    // admin ki push band karne ke liye):
    // await PushService.instance.removeToken();
    // admin session (SharedPreferences) bhi saaf + Firebase signOut
    await adminLogout();
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: _border),
        ),
        title: const Text('Logout?',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text('Aap admin panel se logout ho jayenge.',
            style: TextStyle(color: _muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: _muted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout',
                style:
                    TextStyle(color: _red, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok == true) await _logout();
  }

  /// Avatar par tap: admin ki profile + Logout button
  void _showProfile() {
    final u = FirebaseAuth.instance.currentUser;
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 18),
              _AdminAvatar(user: u, radius: 40),
              const SizedBox(height: 12),
              Text(_nameOf(u),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(
                (u?.email ?? '').isNotEmpty ? u!.email! : adminLoginEmail,
                style: const TextStyle(color: _muted, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _purple.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Admin',
                    style: TextStyle(
                        color: _purple,
                        fontSize: 12,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _confirmLogout();
                  },
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text('Logout',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _red,
                    side: const BorderSide(color: _red, width: 1.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Completed':
      case 'Confirmed':
        return _green;
      case 'Cancelled':
        return _red;
      default:
        return _orange;
    }
  }

  String _labelOf(Booking b) {
    if (b.status == 'Completed') return 'Completed';
    if (b.status == 'Cancelled') return 'Cancelled';
    return b.confirmed ? 'Confirmed' : 'Pending';
  }

  String _pct(int part, int total) =>
      total == 0 ? '0%' : '${(part * 100 / total).round()}%';

  // ---------------- stat card (tap -> Bookings tab) ----------------
  Widget _stat({
    required String label,
    required String value,
    required String sub,
    required Color color,
    required IconData icon,
    required String filter,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _open(filter),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 11)),
              const SizedBox(height: 6),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(icon, color: color, size: 13),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- booking tile (tap -> that booking) ----------------
  Widget _bookingTile(Booking b) {
    final c = _statusColor(_labelOf(b));
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Booking par tap: Bookings tab khulta hai, usi booking ki category
      // (Pending/Confirmed/Completed/Cancelled) ka filter lagta hai aur wo
      // booking highlight hoti hai
      onTap: () => _open(_labelOf(b), b),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                b.image,
                width: 46,
                height: 46,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 46,
                  height: 46,
                  color: const Color(0xFF1B2742),
                  child: const Icon(Icons.cleaning_services_rounded,
                      color: _purple, size: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(b.package,
                      style: const TextStyle(color: _blue, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(b.date,
                      style: const TextStyle(color: _muted, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: c.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: c.withAlpha(120)),
              ),
              child: Text(_labelOf(b),
                  style: TextStyle(
                      color: c, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Admin ki apni profile (login wale account se)
    final admin = FirebaseAuth.instance.currentUser;
    final adminName = _nameOf(admin);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: StreamBuilder<List<Booking>>(
          stream: _stream,
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Firestore se bookings nahi aa rahi.\nRules check karo.\n\n${snap.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _muted, fontSize: 12.5),
                  ),
                ),
              );
            }
            if (!snap.hasData) {
              return const Center(
                  child: CircularProgressIndicator(color: _purple));
            }
            final all = snap.data!;
            int count(String s) => all.where((b) => b.status == s).length;
            final total = all.length;
            // Pending = jo abhi admin ne confirm nahi ki
            final pending =
                all.where((b) => b.status == 'Upcoming' && !b.confirmed).length;
            final done = count('Completed');
            final cancelled = count('Cancelled');

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                // ---- top bar: admin ki profile ----
                Row(
                  children: [
                    GestureDetector(
                      onTap: _showProfile,
                      child: _AdminAvatar(user: admin, radius: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Dashboard',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text('Welcome, $adminName',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: _muted, fontSize: 12.5)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ---- summary banner ----
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded,
                          color: _purple, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text('All bookings from the user panel',
                            style: TextStyle(
                                color: Colors.white, fontSize: 13)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _green.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('LIVE',
                            style: TextStyle(
                                color: _green,
                                fontSize: 10,
                                fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ---- stats row 1 ----
                Row(
                  children: [
                    _stat(
                        label: 'Total Bookings',
                        value: '$total',
                        sub: 'All time',
                        color: _blue,
                        icon: Icons.sync_rounded,
                        filter: 'All'),
                    const SizedBox(width: 8),
                    _stat(
                        label: 'Pending',
                        value: '$pending',
                        sub: _pct(pending, total),
                        color: _orange,
                        icon: Icons.arrow_upward_rounded,
                        filter: 'Pending'),
                    const SizedBox(width: 8),
                    _stat(
                        label: 'Completed',
                        value: '$done',
                        sub: _pct(done, total),
                        color: _green,
                        icon: Icons.arrow_upward_rounded,
                        filter: 'Completed'),
                  ],
                ),
                const SizedBox(height: 8),

                // ---- stats row 2 ----
                Row(
                  children: [
                    _stat(
                        label: 'Cancelled',
                        value: '$cancelled',
                        sub: _pct(cancelled, total),
                        color: _red,
                        icon: Icons.arrow_downward_rounded,
                        filter: 'Cancelled'),
                    const SizedBox(width: 8),
                    _stat(
                        label: 'Success Rate',
                        value: _pct(done, total),
                        sub: 'Completed',
                        color: _green,
                        icon: Icons.check_circle_outline_rounded,
                        filter: 'Completed'),
                    const SizedBox(width: 8),
                    _stat(
                        label: 'Cancel Rate',
                        value: _pct(cancelled, total),
                        sub: 'Cancelled',
                        color: _red,
                        icon: Icons.cancel_outlined,
                        filter: 'Cancelled'),
                  ],
                ),
                const SizedBox(height: 22),

                // ---- recent bookings (all) ----
                const Text('Recent Bookings',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),

                if (all.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('No bookings yet.',
                          style: TextStyle(color: _muted)),
                    ),
                  )
                else
                  ...all.take(10).map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _bookingTile(b),
                      )),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Login wale admin ka naam (displayName, warna email ka pehla hissa)
String _nameOf(User? u) {
  final n = u?.displayName?.trim();
  if (n != null && n.isNotEmpty) return n;
  final e = u?.email;
  if (e != null && e.contains('@')) return e.split('@').first;
  return 'Admin';
}

// ---------------------------------------------------------------------------
//  ADMIN AVATAR (Google ki photo, na aaye to naam ka pehla harf)
//  Neeche harf hota hai, uske upar photo aati hai (isliye load hone tak ya
//  fail hone par harf hi dikhta hai).
// ---------------------------------------------------------------------------
class _AdminAvatar extends StatelessWidget {
  const _AdminAvatar({required this.user, this.radius = 24});

  final User? user;
  final double radius;

  static const _purple = Color(0xFF8B5CF6);
  static const _soft = Color(0xFF2A2360);

  String get _photo {
    var url = user?.photoURL;
    if (url == null || url.isEmpty) {
      for (final p in user?.providerData ?? const <UserInfo>[]) {
        if (p.photoURL != null && p.photoURL!.isNotEmpty) {
          url = p.photoURL;
          break;
        }
      }
    }
    if (url == null || !url.startsWith('http')) return '';
    return url.replaceAll(RegExp(r'=s\d+-c'), '=s200-c');
  }

  String get _initial {
    final n = _nameOf(user).trim();
    return n.isEmpty ? 'A' : n[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final inner = radius * 2 - 4; // 2px ring
    final photo = _photo;

    final letter = Container(
      width: inner,
      height: inner,
      alignment: Alignment.center,
      color: _soft,
      child: Text(
        _initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.85,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(color: _purple, shape: BoxShape.circle),
      child: ClipOval(
        child: SizedBox(
          width: inner,
          height: inner,
          child: Stack(
            fit: StackFit.expand,
            children: [
              letter,
              // photo nahi (admin@gmail.com / password login) -> app ka logo
              if (photo.isEmpty)
                Padding(
                  padding: EdgeInsets.all(radius * 0.22),
                  child: Image.asset(
                    'assets/images/Logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              if (photo.isNotEmpty)
                Image.network(
                  photo,
                  key: ValueKey(photo),
                  fit: BoxFit.cover,
                  // Flutter web par Google photo CORS se fail hoti hai:
                  // <img> tag se load karo (Flutter 3.22+)
                  webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}