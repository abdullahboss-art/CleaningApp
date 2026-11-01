import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_data.dart';
import '../common.dart';

// ---------------------------------------------------------------------------
//  DARK THEME COLORS (sirf is file ke liye)
// ---------------------------------------------------------------------------
const Color _bg = Color(0xFF0D0A22);
const Color _top = Color(0xFF1A1250);
const Color _card = Color(0xFF1A1640);
const Color _border = Color(0xFF2E2763);
const Color _iconBg = Color(0xFF2A2360);
const Color _accent = Color(0xFF9B7DFF);
const Color _primary = Color(0xFF6F4FF2);
const Color _red = Color(0xFFFF6B6B);
const Color _green = Color(0xFF3DDC84);
const Color _orange = Color(0xFFFFB84D);
const Color _sub = Colors.white60;

// ---------------------------------------------------------------------------
//  ALERT (nice toast)
// ---------------------------------------------------------------------------
void _toast(
  BuildContext context,
  String message, {
  IconData icon = Icons.check_circle_rounded,
  Color color = _green,
}) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: const Duration(seconds: 3),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(140)),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(50),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(35),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Booking me tier nahi hai, isliye price se bana rahe hain.
// Apna tier field ho to yahan replace kar dein.
({String name, IconData icon, Color color}) _tier(Booking b) {
  final p = b.price;
  if (p >= 99) {
    return (
      name: 'Platinum',
      icon: Icons.workspace_premium_rounded,
      color: const Color(0xFFE0A526)
    );
  }
  if (p >= 79) {
    return (
      name: 'Diamond',
      icon: Icons.diamond_rounded,
      color: const Color(0xFF2F7BE8)
    );
  }
  if (p >= 59) {
    return (
      name: 'Gold',
      icon: Icons.emoji_events_rounded,
      color: const Color(0xFFE59A1F)
    );
  }
  if (p >= 45) {
    return (
      name: 'Silver',
      icon: Icons.military_tech_rounded,
      color: const Color(0xFF8A93A6)
    );
  }
  return (
    name: 'Premium',
    icon: Icons.star_rounded,
    color: const Color(0xFF7A5CF0)
  );
}

class MyBookingsPage extends StatefulWidget {
  final bool showBack;

  // Purani files `initialTab:` bhejti hain to compile error na aaye, isliye
  // parameter rakha hai. Lekin ab ye IGNORE hota hai: page hamesha
  // Upcoming tab se khulta hai.
  final int initialTab;

  const MyBookingsPage({super.key, this.showBack = true, this.initialTab = 0});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  static const _tabs = ['Upcoming', 'Completed', 'Cancelled'];

  int _tab = 0; // hamesha Upcoming se shuru
  bool _wasActive = true;
  final Set<String> _tracking = {}; // booking keys

  String _kid(Booking b) =>
      b.id.isNotEmpty ? b.id : 'local_${identityHashCode(b)}';

  // Admin ne confirm kiya => user ko Completed dikhao (sirf display,
  // Firestore me admin ka status nahi badalta)
  String _st(Booking b) =>
      (b.status == 'Upcoming' && b.confirmed) ? 'Completed' : b.status;

  @override
  void initState() {
    super.initState();
    // User ki bookings Firestore se live aati rahein (admin confirm/reject
    // kare to yahan khud badal jaye)
    BookingStore.startUserSync();
  }

  // Bottom nav (IndexedStack) me ye page doosre tab se wapas dikhe
  // to Upcoming par reset kar do.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final active = TickerMode.of(context);
    if (active && !_wasActive) {
      _tab = 0;
      BookingStore.startUserSync();
    }
    _wasActive = active;
  }

  Future<void> _reschedule(Booking b) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d == null) return;
    final time = b.date.contains('•') ? b.date.split('•').last.trim() : '';
    b.date = '${fmtDate(d)} • $time';
    // refresh() khud notification bhi bhej deta hai
    BookingStore.refresh();
    if (mounted) {
      _toast(
        context,
        'Booking rescheduled to ${fmtDate(d)}.',
        icon: Icons.event_repeat_rounded,
        color: _accent,
      );
    }
  }

  // Cancel se pehle confirmation alert
  Future<void> _cancel(Booking b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: _border),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _red.withAlpha(35),
                  border: Border.all(color: _red.withAlpha(110)),
                ),
                child: const Icon(Icons.event_busy_rounded,
                    color: _red, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cancel Booking?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to cancel your ${b.title} booking? '
                'This action cannot be undone.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _sub,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _accent,
                        side: const BorderSide(color: _accent),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Keep Booking',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Yes, Cancel',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (ok != true || !mounted) return;

    b.status = 'Cancelled';
    _tracking.remove(_kid(b));
    // refresh() khud notification bhi bhej deta hai
    BookingStore.refresh();
    _toast(
      context,
      'Your booking has been cancelled.',
      icon: Icons.cancel_rounded,
      color: _red,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              stops: [0.0, 0.35],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ---------------- header ----------------
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      widget.showBack ? 4 : 20, 8, 16, 4),
                  child: Row(
                    children: [
                      if (widget.showBack)
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white, size: 26),
                        ),
                      const Text(
                        'My Bookings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------------- tabs ----------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: Row(
                    children: List.generate(_tabs.length, (i) {
                      final sel = i == _tab;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: i == _tabs.length - 1 ? 0 : 8),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => _tab = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: sel ? _primary : _card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: sel ? _primary : _border),
                              ),
                              child: Text(
                                _tabs[i],
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: sel ? Colors.white : Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // ---------------- list ----------------
                Expanded(
                  child: ValueListenableBuilder<List<Booking>>(
                    valueListenable: BookingStore.items,
                    builder: (context, all, _) {
                      // Sirf login user ki apni bookings (dusron ki nahi)
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      final mine = uid == null
                          ? <Booking>[]
                          : all.where((b) => b.customerId == uid).toList();

                      final list =
                          mine.where((b) => _st(b) == _tabs[_tab]).toList();
                      if (list.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.event_busy_rounded,
                                  size: 54, color: _accent.withAlpha(120)),
                              const SizedBox(height: 10),
                              Text(
                                'No ${_tabs[_tab].toLowerCase()} bookings yet.',
                                style: const TextStyle(color: _sub),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: list.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 14),
                        itemBuilder: (_, i) => _bookingCard(list[i]),
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

  // Booking wale user ki photo. Booking me saved photo, warna login user ki
  // (Google login ho to uski photo). Photo na ho to purana tier icon.
  Widget _userAvatar(
      Booking b, ({String name, IconData icon, Color color}) tier) {
    final photo = b.customerPhoto.isNotEmpty
        ? b.customerPhoto
        : (userPhotoOf(FirebaseAuth.instance.currentUser) ?? '');

    final Widget fallback = Center(
      child: Icon(tier.icon, color: tier.color, size: 30),
    );

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tier.color.withAlpha(30),
        border: Border.all(color: tier.color.withAlpha(110), width: 1.6),
      ),
      child: ClipOval(
        child: photo.isEmpty
            ? fallback
            : Image.network(
                photo,
                width: 58,
                height: 58,
                fit: BoxFit.cover,
                webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                errorBuilder: (_, __, ___) => fallback,
              ),
      ),
    );
  }

  // ---------------- ek booking card ----------------
  Widget _bookingCard(Booking b) {
    final tier = _tier(b);
    final upcoming = _st(b) == 'Upcoming';
    final canTrack = upcoming && b.confirmed; // admin confirm kare tab tracking
    final key = _kid(b);
    final open = canTrack && _tracking.contains(key);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(90),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // user ki photo (Google/integration se aayi ho to), warna tier icon
              _userAvatar(b, tier),
              const SizedBox(width: 12),

              // text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tier.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      b.date,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      b.address,
                      style: const TextStyle(color: _sub, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // status chip (top right)
              _StatusChip(status: _st(b), confirmed: b.confirmed),
            ],
          ),

          // price
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '\$${b.price}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // upcoming ke buttons
          if (upcoming) ...[
            const SizedBox(height: 12),

            // Pending: admin ke confirm karne ka intezar
            if (!b.confirmed)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: _orange.withAlpha(28),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _orange.withAlpha(110)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.hourglass_top_rounded,
                        color: _orange, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Waiting for admin confirmation',
                        style: TextStyle(
                          color: _orange,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Confirmed: tracking button
            if (canTrack) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => setState(() {
                    open ? _tracking.remove(key) : _tracking.add(key);
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: Icon(
                    open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.location_on_rounded,
                    size: 18,
                  ),
                  label: Text(
                    open ? 'Hide Tracking' : 'Track Booking',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (open) _TrackTile(key: ValueKey(key), booking: b),
            ],

            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _reschedule(b),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _accent,
                      side: const BorderSide(color: _accent),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Reschedule',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _cancel(b),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _red,
                      side: const BorderSide(color: _red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card ke upar right wala status chip (orange / green / red)
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.confirmed});
  final String status;
  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color c;

    switch (status) {
      case 'Completed':
        label = 'Completed';
        c = _green;
        break;
      case 'Cancelled':
        label = 'Cancelled';
        c = _red;
        break;
      default:
        // Upcoming: admin ne confirm kiya? warna Pending
        label = confirmed ? 'Confirmed' : 'Pending';
        c = confirmed ? _green : _orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withAlpha(35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withAlpha(120)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: c,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Live tracking: Upcoming card ke andar dikhta hai
class _TrackTile extends StatefulWidget {
  final Booking booking;
  const _TrackTile({super.key, required this.booking});

  @override
  State<_TrackTile> createState() => _TrackTileState();
}

class _TrackTileState extends State<_TrackTile> {
  static const _steps = [
    ('Booking Confirmed', Icons.check_circle_rounded),
    ('Cleaner Assigned', Icons.person_rounded),
    ('On the Way', Icons.directions_car_rounded),
    ('Arrived', Icons.home_rounded),
    ('Cleaning in Progress', Icons.cleaning_services_rounded),
    ('Completed', Icons.verified_rounded),
  ];
  static const _pos = [-0.85, -0.85, -0.1, 0.85, 0.85, 0.85];
  static const _eta = [
    '--',
    '15 min',
    '8 min',
    'Arrived',
    'Cleaning in progress',
    'Done'
  ];

  int _step = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (t) {
      if (!mounted || _step >= _steps.length - 1) return t.cancel();
      setState(() => _step++);
      if (_step == _steps.length - 1) {
        // alert pehle, phir status change (card list se hat jata hai)
        _toast(
          context,
          'Cleaning completed! Your booking is now marked as completed.',
          icon: Icons.verified_rounded,
          color: _green,
        );
        widget.booking.status = 'Completed';
        // refresh() khud "Cleaning Completed" notification bhej deta hai
        BookingStore.refresh();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(height: 4, color: _accent.withAlpha(60)),
              const Align(
                alignment: Alignment(0.95, 0),
                child: Icon(Icons.home_rounded, color: _accent, size: 30),
              ),
              AnimatedAlign(
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeInOut,
                alignment: Alignment(_pos[_step], 0),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                      color: _primary, shape: BoxShape.circle),
                  child: const Icon(Icons.person_pin_circle_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
        Text('ETA: ${_eta[_step]}',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14)),
        const SizedBox(height: 8),
        for (var i = 0; i < _steps.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i <= _step ? _primary : _iconBg,
                  ),
                  child: Icon(_steps[i].$2,
                      size: 18, color: i <= _step ? Colors.white : _sub),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _steps[i].$1,
                    style: TextStyle(
                      fontSize: 13,
                      color: i <= _step ? Colors.white : _sub,
                      fontWeight:
                          i == _step ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
                if (i == _step)
                  const Icon(Icons.radio_button_checked,
                      color: _accent, size: 16),
              ],
            ),
          ),
      ],
    );
  }
}