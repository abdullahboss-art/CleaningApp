import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_data.dart';
import 'my_bookings_page.dart'; // <-- agar file ka naam alag hai to yahan badlo

// ---------------------------------------------------------------------------
//  DARK THEME (bookings page jaisa hi)
// ---------------------------------------------------------------------------
const Color _bg = Color(0xFF0D0A22);
const Color _top = Color(0xFF1A1250);
const Color _card = Color(0xFF1A1640);
const Color _border = Color(0xFF2E2763);
const Color _accent = Color(0xFF9B7DFF);
const Color _primary = Color(0xFF6F4FF2);
const Color _red = Color(0xFFFF6B6B);
const Color _green = Color(0xFF3DDC84);
const Color _amber = Color(0xFFE0A84B);
const Color _orange = Color(0xFFFF9F43);
const Color _sub = Colors.white60;

class NotificationsPage extends StatefulWidget {
  final bool showBack;
  const NotificationsPage({super.key, this.showBack = true});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const _filters = ['All', 'Unread', 'Bookings'];
  String _filter = 'All';

  // Ye types booking se related hain, inpar tap karne se bookings page khulta hai
  static const _bookingTypes = {
    'booking',
    'cancel',
    'reschedule',
    'tracking',
    'payment',
  };

  static IconData _icon(String t) {
    switch (t) {
      case 'booking':
        return Icons.check_circle_rounded;
      case 'cancel':
        return Icons.cancel_rounded;
      case 'reschedule':
        return Icons.event_repeat_rounded;
      case 'tracking':
        return Icons.cleaning_services_rounded;
      case 'offer':
        return Icons.local_offer_rounded;
      case 'payment':
        return Icons.payments_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  static Color _color(String t) {
    switch (t) {
      case 'booking':
      case 'payment':
        return _green;
      case 'cancel':
        return _red;
      case 'reschedule':
        return _amber;
      case 'offer':
        return _orange;
      default:
        return _accent;
    }
  }

  static String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  // Notification ke hisab se bookings page ka sahi tab
  // 0 = Upcoming, 1 = Completed, 2 = Cancelled
  int _tabFor(AppNotification n) {
    if (n.type == 'cancel') return 2;
    // admin ne confirm kiya => user ko Completed tab me dikhta hai
    if (n.type == 'booking' && n.title == 'Booking Confirmed') return 1;
    if (n.type == 'tracking' &&
        (n.title + n.body).toLowerCase().contains('complet')) {
      return 1;
    }
    return 0;
  }

  void _open(AppNotification n) {
    NotificationStore.markRead(n);
    if (_bookingTypes.contains(n.type)) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MyBookingsPage(initialTab: _tabFor(n)),
        ),
      );
    }
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
            child: ValueListenableBuilder<List<AppNotification>>(
              valueListenable: NotificationStore.items,
              builder: (context, all, _) {
                final unread = all.where((n) => !n.read).length;
                final list = all.where((n) {
                  if (_filter == 'Unread') return !n.read;
                  if (_filter == 'Bookings') {
                    return _bookingTypes.contains(n.type);
                  }
                  return true;
                }).toList();

                return Column(
                  children: [
                    _header(all.isNotEmpty),
                    _chips(unread),
                    Expanded(
                      child: list.isEmpty ? _empty() : _list(list),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- header ----------------
  Widget _header(bool hasItems) {
    return Padding(
      padding: EdgeInsets.fromLTRB(widget.showBack ? 4 : 20, 8, 8, 4),
      child: Row(
        children: [
          if (widget.showBack)
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 26),
            ),
          const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          if (hasItems)
            TextButton(
              onPressed: NotificationStore.clear,
              child: const Text(
                'Clear all',
                style: TextStyle(color: _red, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- filter chips ----------------
  Widget _chips(int unread) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          for (final t in _filters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _filter = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: _filter == t ? _primary : _card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _filter == t ? _primary : _border),
                  ),
                  child: Text(
                    t == 'Unread' && unread > 0 ? 'Unread ($unread)' : t,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _filter == t ? Colors.white : Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
          const Spacer(),
          if (unread > 0)
            TextButton(
              onPressed: NotificationStore.markAllRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                    color: _accent,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- empty ----------------
  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 54, color: _accent.withAlpha(120)),
          const SizedBox(height: 10),
          const Text('Abhi koi notification nahi.',
              style: TextStyle(color: _sub)),
        ],
      ),
    );
  }

  // ---------------- list ----------------
  Widget _list(List<AppNotification> list) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final n = list[i];
        final c = _color(n.type);
        final tappable = _bookingTypes.contains(n.type);

        return Dismissible(
          key: ValueKey(n.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => NotificationStore.remove(n),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 22),
            decoration: BoxDecoration(
              color: _red.withAlpha(40),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: _red),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _open(n),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: n.read ? _border : _primary.withAlpha(170),
                ),
                boxShadow: [
                  BoxShadow(
                    color: n.read
                        ? Colors.black.withAlpha(90)
                        : _primary.withAlpha(50),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.withAlpha(30),
                      border: Border.all(color: c.withAlpha(110)),
                    ),
                    child: Icon(_icon(n.type), color: c, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight:
                                n.read ? FontWeight.w600 : FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          n.body,
                          style: const TextStyle(
                              color: _sub, fontSize: 12.5, height: 1.35),
                        ),
                        if (tappable) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'View booking  ›',
                            style: TextStyle(
                              color: _accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_ago(n.time),
                          style:
                              const TextStyle(color: _sub, fontSize: 11)),
                      const SizedBox(height: 8),
                      if (!n.read)
                        Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: _accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}