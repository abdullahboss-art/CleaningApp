import 'dart:math';

import 'package:cleaning/app_data.dart'; // Booking, BookingStore, NotificationStore
import 'package:cleaning/common.dart'; // fmtDate
import 'package:cleaning/my_bookings_page.dart'; // <-- apni MyBookingsPage file ka sahi path likho
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String kCurrency = 'AED';

// ---------------------------------------------------------------------------
//  DARK THEME COLORS (sirf is file ke liye)
// ---------------------------------------------------------------------------
const Color _bg = Color(0xFF0D0A22);
const Color _top = Color(0xFF1A1250);
const Color _card = Color(0xFF1A1640);
const Color _line = Color(0xFF2E2763);
const Color _soft = Color(0xFF2A2360);
const Color _accent = Color(0xFF9B7DFF);
const Color _primary = Color(0xFF6F4FF2);
const Color _green = Color(0xFF3DDC84);
const Color _sub = Colors.white60;

class BookingConfirmedPage extends StatefulWidget {
  const BookingConfirmedPage({
    super.key,
    required this.serviceTitle,
    required this.packageName,
    required this.price,
    required this.date,
    required this.time,
    required this.image,
    this.address = 'Tower A, Flat 1203',
  });

  final String serviceTitle;
  final String packageName;
  final int price;
  final DateTime date;
  final TimeOfDay time;
  final String image;
  final String address;

  @override
  State<BookingConfirmedPage> createState() => _BookingConfirmedPageState();
}

class _BookingConfirmedPageState extends State<BookingConfirmedPage>
    with SingleTickerProviderStateMixin {
  late final String _id =
      'SC-${(DateTime.now().millisecondsSinceEpoch % 100000).toString().padLeft(5, '0')}';

  // ---------------- animations ----------------
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  // sparkles (tick ke gird)
  late final Animation<double> _sparkle = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
  );

  // card neeche se upar
  late final Animation<Offset> _cardSlide = Tween<Offset>(
    begin: const Offset(0, 1.1),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.2, 0.75, curve: Curves.easeOutCubic),
  ));
  late final Animation<double> _cardFade = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
  );

  // buttons neeche se upar
  late final Animation<Offset> _btnSlide = Tween<Offset>(
    begin: const Offset(0, 1.6),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
  ));
  late final Animation<double> _btnFade = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
  );

  String _fmtTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:$m $p';
  }

  @override
  void initState() {
    super.initState();
    _ctrl.forward();

    // build ke baad ek hi baar: booking save + notification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // booking karne wale user ka data (Admin > Customers me dikhega)
      final u = FirebaseAuth.instance.currentUser;

      BookingStore.add(Booking(
        title: widget.serviceTitle,
        image: widget.image,
        package: widget.packageName,
        address: widget.address,
        date: '${fmtDate(widget.date)} • ${_fmtTime(widget.time)}',
        price: widget.price,
        status: 'Upcoming',
        customerId: u?.uid ?? '',
        customerName: userNameOf(u),
        customerEmail: u?.email ?? '',
        customerPhone: u?.phoneNumber ?? '',
        customerPhoto: userPhotoOf(u) ?? '',
      ));

      // Home ki bell par count aayega, Notifications page me dikhegi
      NotificationStore.add(
        type: 'booking',
        key: 'confirmed|$_id', // double na aaye
        title: 'Booking Received',
        body: 'Your ${widget.serviceTitle} (${widget.packageName}) request is '
            'sent for ${fmtDate(widget.date)} at ${_fmtTime(widget.time)}. '
            'Waiting for admin confirmation.',
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Home (pehli screen) tak wapas, phir My Bookings kholo
  void _openBookings() {
    final nav = Navigator.of(context);
    nav.popUntil((r) => r.isFirst);
    nav.push(MaterialPageRoute(
        builder: (_) => const MyBookingsPage(showBack: true)));
  }

  void _goHome() => Navigator.of(context).popUntil((r) => r.isFirst);

  // ------------------------------ UI ------------------------------
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: _bg,
          body: Stack(
            children: [
              // ---- top gradient ----
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 340,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_top, _bg],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // ---- green tick + sparkles ----
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _sparkle,
                            builder: (_, __) => CustomPaint(
                              size: const Size(160, 160),
                              painter: _SparklePainter(_sparkle.value),
                            ),
                          ),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutBack,
                            builder: (_, v, child) =>
                                Transform.scale(scale: v, child: child),
                            child: Container(
                              width: 98,
                              height: 98,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _green.withAlpha(40),
                              ),
                              child: Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  color: _green,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _green.withAlpha(110),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 48),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Booking Confirmed!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your cleaning service has been\nsuccessfully booked.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13.5, height: 1.4, color: Colors.white70),
                    ),
                    const SizedBox(height: 20),

                    // ---- ticket card + note (neeche se upar) ----
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: SlideTransition(
                          position: _cardSlide,
                          child: FadeTransition(
                            opacity: _cardFade,
                            child: Column(
                              children: [
                                _ticketCard(),
                                const SizedBox(height: 14),
                                _note(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ---- buttons (neeche se upar) ----
                    SlideTransition(
                      position: _btnSlide,
                      child: FadeTransition(
                        opacity: _btnFade,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: _openBookings,
                                  icon: const Icon(Icons.receipt_long_rounded,
                                      size: 22),
                                  label: const Text('View Booking',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primary,
                                    foregroundColor: Colors.white,
                                    elevation: 6,
                                    shadowColor: _primary.withAlpha(100),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: OutlinedButton.icon(
                                  onPressed: _goHome,
                                  icon: const Icon(Icons.home_rounded,
                                      size: 22),
                                  label: const Text('Back to Home',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _accent,
                                    side: const BorderSide(
                                        color: _primary, width: 1.4),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
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
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- ticket card ----------------
  Widget _ticketCard() {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(110),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // service + package + booking id
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: _soft),
                  child: ClipOval(
                    child: Image.asset(
                      widget.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.cleaning_services_rounded,
                          color: _accent,
                          size: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.serviceTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: _soft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.packageName} Package',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: _accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Booking ID',
                        style: TextStyle(fontSize: 10.5, color: _sub)),
                    const SizedBox(height: 2),
                    Text('#$_id',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        )),
                  ],
                ),
              ],
            ),
          ),

          _ticketDivider(),

          // details
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
            child: Column(
              children: [
                _row(Icons.calendar_today_rounded, 'Date',
                    fmtDate(widget.date)),
                _row(Icons.access_time_rounded, 'Time',
                    _fmtTime(widget.time)),
                _row(Icons.location_on_outlined, 'Address', widget.address),
              ],
            ),
          ),

          // total
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _soft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined,
                      color: _accent, size: 22),
                  const SizedBox(width: 10),
                  const Text('Total Amount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                  const Spacer(),
                  Text(
                    '$kCurrency ${widget.price}',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ticket jaisi dashed line, dono side notch ke saath
  Widget _ticketDivider() {
    Widget notch() => Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(color: _bg, shape: BoxShape.circle),
        );

    return SizedBox(
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(
                builder: (_, box) {
                  final n = (box.maxWidth / 10).floor();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0; i < n; i++)
                        Container(width: 5, height: 1.6, color: _line),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(left: -12, top: 0, child: notch()),
          Positioned(right: -12, top: 0, child: notch()),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _soft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: _accent),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14, color: _sub)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- info note ----------------
  Widget _note() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: _accent),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Our cleaner will contact you before arriving. '
              'You can track your booking from My Bookings.',
              style: TextStyle(fontSize: 12.5, height: 1.35, color: _sub),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Tick ke gird chhoti sparkle lines
// ---------------------------------------------------------------------------
class _SparklePainter extends CustomPainter {
  _SparklePainter(this.t);
  final double t; // 0 -> 1

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    const count = 12;
    for (var i = 0; i < count; i++) {
      final a = (i / count) * 2 * pi;
      final start = 56 + 8 * t;
      final end = start + (i.isEven ? 13 : 8) * t;
      paint.color = (i.isEven ? _green : _accent).withAlpha((230 * t).round());
      canvas.drawLine(
        c + Offset(cos(a), sin(a)) * start,
        c + Offset(cos(a), sin(a)) * end,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter old) => old.t != t;
}