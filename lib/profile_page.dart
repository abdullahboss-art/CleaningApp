import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common.dart';
import 'about_page.dart';
import 'app_settings_page.dart';
import 'help_support_page.dart';
import 'my_bookings_page.dart';
import 'notifications_page.dart';

// ---------------------------------------------------------------------------
//  DARK THEME COLORS
// ---------------------------------------------------------------------------
const Color _bg = Color(0xFF0D0A22);
const Color _top = Color(0xFF1A1250);
const Color _card = Color(0xFF1A1640);
const Color _border = Color(0xFF2E2763);
const Color _iconBg = Color(0xFF2A2360);
const Color _accent = Color(0xFF9B7DFF);
const Color _primary = Color(0xFF6F4FF2);
const Color _sub = Colors.white60;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Logout ke baad poora stack clear hokar seedha Login page khulta hai.
  // rootNavigator: true isliye taake bottom-nav ke andar ka nested
  // navigator bhi clear ho jaye.
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil(Routes.login, (_) => false);
  }

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
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'My Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AppSettingsPage(),
                          ),
                        ),
                        icon: const Icon(Icons.settings_rounded,
                            color: Colors.white, size: 26),
                      ),
                    ],
                  ),
                ),

                // body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      children: [
                        // ---- Google user (naam, email, photo) ----
                        StreamBuilder<User?>(
                          stream: FirebaseAuth.instance.userChanges(),
                          initialData: FirebaseAuth.instance.currentUser,
                          builder: (context, snap) {
                            final user = snap.data;
                            final email = user?.email ?? '';
                            final name = (user?.displayName != null &&
                                    user!.displayName!.trim().isNotEmpty)
                                ? user.displayName!
                                : (email.isNotEmpty
                                    ? email.split('@').first
                                    : 'Guest');
                            final photo = user?.photoURL;

                            return Column(
                              children: [
                                _avatar(photo),
                                const SizedBox(height: 12),
                                Text(
                                  name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if (email.isNotEmpty)
                                  Text(
                                    email,
                                    style: const TextStyle(
                                        color: _sub, fontSize: 13),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // menu card
                        Container(
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _border),
                          ),
                          child: Column(
                            children: [
                              _tile(
                                icon: Icons.calendar_month_rounded,
                                title: 'My Bookings',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MyBookingsPage(
                                        showBack: true, initialTab: 0),
                                  ),
                                ),
                              ),
                              _divider(),
                              _tile(
                                icon: Icons.notifications_rounded,
                                title: 'Notifications',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const NotificationsPage(showBack: true),
                                  ),
                                ),
                              ),
                              _divider(),
                              _tile(
                                icon: Icons.help_rounded,
                                title: 'Help & Support',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HelpSupportPage(),
                                  ),
                                ),
                              ),
                              _divider(),
                              _tile(
                                icon: Icons.info_rounded,
                                title: 'About SparkClean',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AboutPage(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),

                        // logout
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _logout(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.logout_rounded, size: 20),
                            label: const Text(
                              'Log Out',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 15),
                            ),
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
    );
  }

  // Google photo; na mile ya load na ho to icon dikhata hai
  Widget _avatar(String? photoUrl) {
    const fallback = CircleAvatar(
      radius: 44,
      backgroundColor: _iconBg,
      child: Icon(Icons.person_rounded, color: _accent, size: 48),
    );

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _accent, width: 2),
        boxShadow: [
          BoxShadow(color: _primary.withAlpha(90), blurRadius: 18),
        ],
      ),
      child: (photoUrl == null || photoUrl.isEmpty)
          ? fallback
          : ClipOval(
              child: Image.network(
                photoUrl,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : fallback,
              ),
            ),
    );
  }

  Widget _divider() => Divider(height: 1, color: _border.withAlpha(180));

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration:
                  const BoxDecoration(shape: BoxShape.circle, color: _iconBg),
              child: Icon(icon, color: _accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _sub, size: 22),
          ],
        ),
      ),
    );
  }
}
