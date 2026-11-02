import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common.dart';
import 'user_prefs.dart';

// ---------------------------------------------------------------------------
//  DARK THEME COLORS (baaki app jaise hi)
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

void _snack(BuildContext context, String text) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    content: Text(text),
    backgroundColor: _card,
    behavior: SnackBarBehavior.floating,
  ));
}

// ---------------------------------------------------------------------------
//  PAGE
// ---------------------------------------------------------------------------
class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  final _p = UserPrefs.instance;

  @override
  void initState() {
    super.initState();
    _p.load();
  }

  Future<void> _editDetails() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _DetailsSheet(),
    );
    if (saved == true && mounted) _snack(context, 'Details save ho gayi');
  }

  void _showText(String title, String body) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              body,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Account delete karein?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Aapka account hamesha ke liye delete ho jayega. Ye kaam wapas '
          'nahi ho sakta.',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: _sub)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await FirebaseAuth.instance.currentUser?.delete();
      await _p.clear();
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true)
          .pushNamedAndRemoveUntil(Routes.login, (_) => false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _snack(
        context,
        e.code == 'requires-recent-login'
            ? 'Security ke liye pehle logout karo, dobara login karo, phir '
                'delete karo.'
            : 'Account delete nahi hua: ${e.message ?? e.code}',
      );
    } catch (_) {
      if (!mounted) return;
      _snack(context, 'Account delete nahi hua, dobara try karo.');
    }
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
              stops: [0.0, 0.4],
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
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.userChanges(),
                    initialData: FirebaseAuth.instance.currentUser,
                    builder: (context, snap) {
                      final user = snap.data;
                      final email = user?.email ?? '';
                      final name = (user?.displayName != null &&
                              user!.displayName!.trim().isNotEmpty)
                          ? user.displayName!.trim()
                          : (email.isNotEmpty
                              ? email.split('@').first
                              : 'Guest');
                      final photo = user?.photoURL;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // profile summary
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: _cardDecoration(),
                              child: Row(
                                children: [
                                  _MiniAvatar(photoUrl: photo),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        if (email.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            email,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: _sub, fontSize: 13),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ---- My details ----
                            const _SectionTitle('My Details'),
                            const SizedBox(height: 10),
                            Container(
                              decoration: _cardDecoration(),
                              child: AnimatedBuilder(
                                animation:
                                    Listenable.merge([_p.phone, _p.address]),
                                builder: (context, _) => Column(
                                  children: [
                                    _Row(
                                      icon: Icons.person_rounded,
                                      title: 'Name',
                                      subtitle: name,
                                      onTap: _editDetails,
                                    ),
                                    const _Divider(),
                                    _Row(
                                      icon: Icons.phone_rounded,
                                      title: 'Phone',
                                      subtitle: _p.phone.value.isEmpty
                                          ? 'Add phone number'
                                          : _p.phone.value,
                                      onTap: _editDetails,
                                    ),
                                    const _Divider(),
                                    _Row(
                                      icon: Icons.apartment_rounded,
                                      title: 'Address',
                                      subtitle: _p.address.value.isEmpty
                                          ? 'Add tower & flat number'
                                          : _p.address.value,
                                      onTap: _editDetails,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ---- Notifications ----
                            const _SectionTitle('Notifications'),
                            const SizedBox(height: 10),
                            Container(
                              decoration: _cardDecoration(),
                              child: Column(
                                children: [
                                  ValueListenableBuilder<bool>(
                                    valueListenable: _p.notifBooking,
                                    builder: (_, v, __) => _SwitchRow(
                                      icon: Icons.event_available_rounded,
                                      title: 'Booking updates',
                                      subtitle:
                                          'Confirmation, reminder aur status',
                                      value: v,
                                      onChanged: _p.setNotifBooking,
                                    ),
                                  ),
                                  const _Divider(),
                                  ValueListenableBuilder<bool>(
                                    valueListenable: _p.notifOffers,
                                    builder: (_, v, __) => _SwitchRow(
                                      icon: Icons.local_offer_rounded,
                                      title: 'Offers & promotions',
                                      subtitle: 'Discounts aur nayi deals',
                                      value: v,
                                      onChanged: _p.setNotifOffers,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ---- Legal ----
                            const _SectionTitle('About & Legal'),
                            const SizedBox(height: 10),
                            Container(
                              decoration: _cardDecoration(),
                              child: Column(
                                children: [
                                  _Row(
                                    icon: Icons.privacy_tip_rounded,
                                    title: 'Privacy Policy',
                                    onTap: () => _showText(
                                        'Privacy Policy', _privacyText),
                                  ),
                                  const _Divider(),
                                  _Row(
                                    icon: Icons.description_rounded,
                                    title: 'Terms of Service',
                                    onTap: () => _showText(
                                        'Terms of Service', _termsText),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ---- Danger zone ----
                            const _SectionTitle('Account'),
                            const SizedBox(height: 10),
                            Container(
                              decoration: _cardDecoration(),
                              child: _Row(
                                icon: Icons.delete_forever_rounded,
                                title: 'Delete Account',
                                subtitle: 'Account hamesha ke liye hata do',
                                danger: true,
                                onTap: _deleteAccount,
                              ),
                            ),
                            const SizedBox(height: 28),

                            const Center(
                              child: Text(
                                'SparkClean v$kAppVersion',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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

// TODO: apni asli policy / terms yahan daal do
const String _privacyText =
    'Hum sirf wohi information lete hain jo booking ke liye zaroori hai: '
    'aapka naam, email, phone number aur address (tower aur flat).\n\n'
    'Ye information sirf aapki booking confirm karne, cleaner ko bhejne aur '
    'support dene ke liye use hoti hai.\n\n'
    'Hum aapka data kisi third party ko bechte nahi hain.\n\n'
    'Aap kisi bhi waqt Settings se apni details badal sakte ho ya account '
    'delete kar sakte ho.';

const String _termsText =
    '1. Booking confirm hone ke baad cleaner aapke diye gaye time par '
    'pohnchega.\n\n'
    '2. Booking cancel ya reschedule karna ho to service se kam az kam 4 '
    'ghante pehle bata do.\n\n'
    '3. Payment Cash on Service ya card se ki ja sakti hai. Kaam poora hone '
    'par payment due hoti hai.\n\n'
    '4. Cleaning ke waqt ghar me kisi ka maujood hona ya access dena zaroori '
    'hai.\n\n'
    '5. Service se khush na hon to 24 ghante ke andar support ko batao, hum '
    'masla theek karwa denge.';

// ---------------------------------------------------------------------------
//  EDIT DETAILS SHEET
// ---------------------------------------------------------------------------
class _DetailsSheet extends StatefulWidget {
  const _DetailsSheet();

  @override
  State<_DetailsSheet> createState() => _DetailsSheetState();
}

class _DetailsSheetState extends State<_DetailsSheet> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _tower;
  late final TextEditingController _flat;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = UserPrefs.instance;
    final user = FirebaseAuth.instance.currentUser;
    _name = TextEditingController(text: user?.displayName ?? '');
    _phone = TextEditingController(text: p.phone.value);
    _tower = TextEditingController(text: p.tower.value);
    _flat = TextEditingController(text: p.flat.value);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _tower.dispose();
    _flat.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Naam likhna zaroori hai');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && name != (user.displayName ?? '')) {
        await user.updateDisplayName(name);
        await user.reload();
      }
      await UserPrefs.instance.setDetails(
        phone: _phone.text.trim(),
        tower: _tower.text.trim(),
        flat: _flat.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Save nahi hua, dobara try karo.';
      });
    }
  }

  InputDecoration _decoration(String label, IconData icon, {String? hint}) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c),
        );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30),
      labelStyle: const TextStyle(color: _sub),
      floatingLabelStyle: const TextStyle(color: _accent),
      prefixIcon: Icon(icon, color: _accent, size: 20),
      filled: true,
      fillColor: _bg,
      enabledBorder: border(_border),
      focusedBorder: border(_accent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              style: const TextStyle(color: Colors.white),
              cursorColor: _accent,
              textCapitalization: TextCapitalization.words,
              decoration: _decoration('Name', Icons.person_rounded),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              style: const TextStyle(color: Colors.white),
              cursorColor: _accent,
              keyboardType: TextInputType.phone,
              decoration: _decoration('Phone', Icons.phone_rounded,
                  hint: '+971 50 123 4567'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tower,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: _accent,
                    textCapitalization: TextCapitalization.words,
                    decoration: _decoration('Tower', Icons.apartment_rounded,
                        hint: 'Tower A'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _flat,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: _accent,
                    decoration: _decoration('Flat', Icons.door_front_door_rounded,
                        hint: '1203'),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!,
                  style: const TextStyle(
                      color: Colors.redAccent, fontSize: 13)),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  SMALL WIDGETS
// ---------------------------------------------------------------------------
BoxDecoration _cardDecoration() => BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _border),
    );

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: _border.withAlpha(180));
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({this.photoUrl});
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    const fallback = CircleAvatar(
      radius: 28,
      backgroundColor: _iconBg,
      child: Icon(Icons.person_rounded, color: _accent, size: 30),
    );
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _accent, width: 1.5),
      ),
      child: (photoUrl == null || photoUrl!.isEmpty)
          ? fallback
          : ClipOval(
              child: Image.network(
                photoUrl!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : fallback,
              ),
            ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.danger = false,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.redAccent : _accent;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: danger ? Colors.redAccent.withAlpha(30) : _iconBg,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: danger ? Colors.redAccent : Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _sub, fontSize: 12.5),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _sub, size: 22),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                  subtitle,
                  style: const TextStyle(color: _sub, fontSize: 12.5),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _accent,
            activeTrackColor: _primary,
          ),
        ],
      ),
    );
  }
}
