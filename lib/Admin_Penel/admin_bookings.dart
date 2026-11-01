import 'dart:async';

import 'package:cleaning/Admin_Penel/admin_toast.dart';
import 'package:cleaning/admin_booking_details_page.dart';
import 'package:cleaning/app_data.dart';
import 'package:flutter/material.dart';

class AdminBookingsPage extends StatefulWidget {
  const AdminBookingsPage({super.key});

  @override
  State<AdminBookingsPage> createState() => AdminBookingsPageState();
}

// Public hai taake AdminShell GlobalKey se show() call kar sake
class AdminBookingsPageState extends State<AdminBookingsPage> {
  static const _bg = Color(0xFF0B0B18);
  static const _card = Color(0xFF121C30);
  static const _border = Color(0xFF1F2B45);
  static const _purple = Color(0xFF8B5CF6);
  static const _muted = Color(0xFF8A94A8);
  static const _green = Color(0xFF2EC27E);
  static const _orange = Color(0xFFFFA726);
  static const _red = Color(0xFFFF4D4F);
  static const _blue = Color(0xFF4DA3FF);

  // SAB users ki bookings, Firestore se live
  late final Stream<List<Booking>> _stream = BookingStore.allStream();

  String _filter = 'All';
  String _query = '';
  String? _focusedKey;
  Timer? _timer;
  final _searchCtrl = TextEditingController();
  final Map<String, GlobalKey> _keys = {};

  // Confirm ke 2 minute baad booking khud Completed (admin page khula ho to)
  Timer? _autoTimer;
  List<Booking> _latest = const [];

  @override
  void initState() {
    super.initState();
    _autoTimer = Timer.periodic(
        const Duration(seconds: 5), (_) => _autoComplete());
  }

  void _autoComplete() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final wait = BookingStore.autoCompleteAfter.inMilliseconds;
    for (final b in _latest) {
      if (b.status != 'Upcoming' || !b.confirmed) continue;
      if (b.confirmedAt == 0) {
        // purani confirmed booking (time save nahi tha): ab se 2 minute
        b.confirmedAt = now;
        BookingStore.update(b);
      } else if (now - b.confirmedAt >= wait) {
        b.status = 'Completed';
        // Firestore me save + customer ko "Cleaning Completed" notification
        BookingStore.update(b);
      }
    }
  }

  String _kid(Booking b) =>
      b.id.isNotEmpty ? b.id : 'local_${identityHashCode(b)}';

  @override
  void dispose() {
    _autoTimer?.cancel();
    _timer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Dashboard se call hota hai: filter lagao, aur booking ho to usko highlight + scroll
  void show({required String filter, Booking? booking}) {
    _timer?.cancel();
    setState(() {
      _filter = filter;
      _query = '';
      _searchCtrl.clear();
      _focusedKey = booking == null ? null : _kid(booking);
    });
    if (booking == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _keys[_kid(booking)]?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          alignment: 0.1,
        );
      }
    });
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _focusedKey = null);
    });
  }

  // ---- status helpers (confirmed ka bhi khayal rakhte hain) ----
  String _statusLabel(Booking b) {
    if (b.status == 'Completed') return 'Completed';
    if (b.status == 'Cancelled') return 'Cancelled';
    return b.confirmed ? 'Confirmed' : 'Pending';
  }

  Color _statusColor(Booking b) {
    switch (_statusLabel(b)) {
      case 'Completed':
      case 'Confirmed':
        return _green;
      case 'Cancelled':
        return _red;
      default:
        return _orange;
    }
  }

  bool _matchesFilter(Booking b) {
    switch (_filter) {
      case 'All':
        return true;
      case 'Pending':
        return b.status == 'Upcoming' && !b.confirmed;
      case 'Confirmed':
        return b.status == 'Upcoming' && b.confirmed;
      default:
        return b.status == _filter; // Completed / Cancelled
    }
  }

  void _openDetails(Booking b) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AdminBookingDetailsPage(booking: b),
    ));
  }

  // Menu se status badalna + acha alert (customer ko notification update() se jati hai)
  Future<void> _changeStatus(Booking b, String s) async {
    final messenger = ScaffoldMessenger.of(context);

    final AdminToastType type;
    final String title;

    if (s == 'Pending') {
      b.status = 'Upcoming';
      b.confirmed = false;
      type = AdminToastType.pending;
      title = 'Marked as Pending';
    } else if (s == 'Confirmed') {
      b.status = 'Upcoming';
      b.confirmed = true;
      type = AdminToastType.confirmed;
      title = 'Booking Confirmed';
    } else if (s == 'Completed') {
      b.status = 'Completed';
      b.confirmed = true;
      type = AdminToastType.completed;
      title = 'Booking Completed';
    } else {
      b.status = 'Cancelled';
      b.confirmed = false;
      type = AdminToastType.cancelled;
      title = 'Booking Cancelled';
    }

    // Firestore me save + customer ko notification
    final ok = await BookingStore.update(b);
    if (!ok) {
      messenger.showSnackBar(SnackBar(
        backgroundColor: _red,
        duration: const Duration(seconds: 8),
        content: Text('Save nahi hua! Firestore Rules check karo.\n'
            '${BookingStore.lastWriteError}'),
      ));
      return;
    }

    showAdminToast(
      messenger,
      type: type,
      title: title,
      message: '${b.title} • ${b.date}',
    );
  }

  Widget _chip(String label) {
    final sel = _filter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() {
          _filter = label;
          _focusedKey = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: sel ? _purple : _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: sel ? _purple : _border),
          ),
          child: Text(label,
              style: TextStyle(
                  color: sel ? Colors.white : _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  // Customer ki photo (Customers page jaisi). Photo na ho ya load na ho to
  // naam ka pehla harf, aur naam bhi na ho to service ki image.
  Widget _avatar(Booking b) {
    Widget serviceImg() => Image.asset(
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
        );

    Widget initial() {
      final name = b.customerName.trim();
      if (name.isEmpty) return serviceImg();
      return Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        color: _purple.withAlpha(60),
        child: Text(name[0].toUpperCase(),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
      );
    }

    return ClipOval(
      child: b.customerPhoto.isNotEmpty
          ? Image.network(
              b.customerPhoto,
              width: 46,
              height: 46,
              fit: BoxFit.cover,
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              errorBuilder: (_, __, ___) => initial(),
            )
          : initial(),
    );
  }

  Widget _tile(Booking b) {
    final c = _statusColor(b);
    final focused = _focusedKey != null && _focusedKey == _kid(b);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: focused ? _purple : _border, width: focused ? 1.6 : 1),
        boxShadow: focused
            ? [BoxShadow(color: _purple.withAlpha(90), blurRadius: 14)]
            : [],
      ),
      child: Row(
        children: [
          _avatar(b),
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
                if (b.customerName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(b.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
                const SizedBox(height: 2),
                Text(b.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 11)),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: c.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: c.withAlpha(120)),
                ),
                child: Text(_statusLabel(b),
                    style: TextStyle(
                        color: c,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
              PopupMenuButton<String>(
                color: _card,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_horiz_rounded,
                    color: _muted, size: 20),
                onSelected: (s) => _changeStatus(b, s),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                      value: 'Pending',
                      child: Text('Mark Pending',
                          style: TextStyle(color: Colors.white))),
                  PopupMenuItem(
                      value: 'Confirmed',
                      child: Text('Mark Confirmed',
                          style: TextStyle(color: Colors.white))),
                  PopupMenuItem(
                      value: 'Completed',
                      child: Text('Mark Completed',
                          style: TextStyle(color: Colors.white))),
                  PopupMenuItem(
                      value: 'Cancelled',
                      child: Text('Mark Cancelled',
                          style: TextStyle(color: Colors.white))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: StreamBuilder<List<Booking>>(
          stream: _stream,
          builder: (context, snap) {
            final all = snap.data ?? const <Booking>[];
            _latest = all;
            final q = _query.trim().toLowerCase();
            final shown = all.where((b) {
              final okQuery = q.isEmpty ||
                  b.title.toLowerCase().contains(q) ||
                  b.address.toLowerCase().contains(q) ||
                  b.package.toLowerCase().contains(q) ||
                  b.customerName.toLowerCase().contains(q) ||
                  b.customerEmail.toLowerCase().contains(q);
              return _matchesFilter(b) && okQuery;
            }).toList();

            final Widget content;
            if (snap.hasError) {
              content = Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Firestore se bookings nahi aa rahi.\n'
                    'Firestore Rules check karo (read/write allow hona chahiye).\n\n'
                    '${snap.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _muted, fontSize: 12.5),
                  ),
                ),
              );
            } else if (!snap.hasData) {
              content = const Center(
                  child: CircularProgressIndicator(color: _purple));
            } else if (shown.isEmpty) {
              content = const Center(
                  child: Text('No bookings found.',
                      style: TextStyle(color: _muted)));
            } else {
              content = SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    for (final b in shown)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: KeyedSubtree(
                          key: _keys.putIfAbsent(_kid(b), () => GlobalKey()),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _openDetails(b),
                            child: _tile(b),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _purple.withAlpha(40),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.calendar_today_rounded,
                            color: _purple, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text('Bookings (${all.length})',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: _purple,
                    decoration: InputDecoration(
                      hintText: 'Search service, customer or address',
                      hintStyle: const TextStyle(color: _muted, fontSize: 13),
                      prefixIcon:
                          const Icon(Icons.search_rounded, color: _muted),
                      filled: true,
                      fillColor: _card,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _purple),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _chip('All'),
                        _chip('Pending'),
                        _chip('Confirmed'),
                        _chip('Completed'),
                        _chip('Cancelled'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: content),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}