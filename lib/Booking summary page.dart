import 'package:cleaning/app_data.dart'; // userPhotoOf, userNameOf
import 'package:cleaning/auth_service.dart';
import 'package:cleaning/booking_confirmed_page.dart'; // apni confirmed file ka naam yahan likho
import 'package:cleaning/common.dart'; // fmtDate
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String kCurrency = 'AED';

// Design wali Building / Flat Number (baad me user ke profile se aayegi)
const String kBuilding = 'Tower A';
const String kFlat = '1203';

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
const Color _sub = Colors.white60;

class BookingSummaryPage extends StatefulWidget {
  const BookingSummaryPage({
    super.key,
    required this.serviceTitle,
    required this.packageName,
    required this.price,
    required this.duration,
    required this.date,
    required this.time,
    required this.packageImage,
    required this.accent,
    required this.cardBg,
  });

  final String serviceTitle;
  final String packageName;
  final int price;
  final String duration;
  final DateTime date;
  final TimeOfDay time;
  final String packageImage;
  final Color accent;
  final Color cardBg;

  @override
  State<BookingSummaryPage> createState() => _BookingSummaryPageState();
}

class _BookingSummaryPageState extends State<BookingSummaryPage> {
  int _pay = 0; // 0 = Cash on Service, 1 = Card Payment

  String _fmtTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:$m $p';
  }

  void _confirm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingConfirmedPage(
          serviceTitle: widget.serviceTitle,
          packageName: widget.packageName,
          price: widget.price,
          date: widget.date,
          time: widget.time,
          image: widget.packageImage,
          address: '$kBuilding, Flat $kFlat',
        ),
      ),
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
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ---- top bar ----
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
                          'Booking Details',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
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
                          Expanded(
                            child: SingleChildScrollView(
                              padding:
                                  const EdgeInsets.fromLTRB(18, 20, 18, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _profileCard(),
                                  const SizedBox(height: 14),
                                  _detailsCard(),
                                  const SizedBox(height: 22),
                                  const Text(
                                    'Payment Method',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _paymentCard(),
                                ],
                              ),
                            ),
                          ),

                          // ---- Confirm Booking ----
                          SafeArea(
                            top: false,
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(18, 8, 18, 14),
                              child: SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _confirm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primary,
                                    foregroundColor: Colors.white,
                                    elevation: 6,
                                    shadowColor: _primary.withAlpha(100),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  child: const Text('Confirm Booking',
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

  // ---------------- booking karne wale user ki profile ----------------
  Widget _profileCard() {
    final user = AuthService.instance.currentUser;
    final userName = userNameOf(user);
    final name = userName.isNotEmpty ? userName : 'Guest';
    final contact = (user?.email?.isNotEmpty ?? false)
        ? user!.email!
        : (user?.phoneNumber ?? '');
    final photo = userPhotoOf(user);
    final initial = userName.isNotEmpty
        ? userName[0].toUpperCase()
        : (contact.isNotEmpty ? contact[0].toUpperCase() : '?');

    Widget letter() => Container(
          color: _soft,
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDeco(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
                color: _accent, shape: BoxShape.circle),
            child: ClipOval(
              child: SizedBox(
                width: 54,
                height: 54,
                child: photo == null
                    ? letter()
                    : Image.network(
                        photo,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) =>
                            progress == null ? child : letter(),
                        errorBuilder: (_, e, __) => letter(),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Booking for',
                    style: TextStyle(fontSize: 11.5, color: _sub)),
                const SizedBox(height: 2),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (contact.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    contact,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, color: _sub),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- details card ----------------
  Widget _detailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        children: [
          // service + package
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: widget.cardBg),
                child: ClipOval(
                  child: Image.asset(
                    widget.packageImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                        Icons.workspace_premium_rounded,
                        color: widget.accent,
                        size: 30),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.serviceTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${widget.packageName} Package',
                      style: const TextStyle(fontSize: 13, color: _sub),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: _line, height: 20),
          _row(Icons.calendar_today_rounded, 'Date', fmtDate(widget.date)),
          _row(Icons.access_time_rounded, 'Time', _fmtTime(widget.time)),
          _row(Icons.apartment_rounded, 'Building', kBuilding),
          _row(Icons.meeting_room_outlined, 'Flat Number', kFlat),
          _row(Icons.timer_outlined, 'Duration', widget.duration),
          _row(Icons.payments_outlined, 'Total Amount',
              '$kCurrency ${widget.price}',
              bold: true),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _accent),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14, color: _sub)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 18 : 14,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- payment method ----------------
  Widget _paymentCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: _cardDeco(),
      child: Column(
        children: [
          _payTile(0, 'Cash on Service'),
          const Divider(color: _line, height: 1),
          _payTile(1, 'Card Payment'),
        ],
      ),
    );
  }

  Widget _payTile(int i, String label) {
    final sel = _pay == i;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _pay = i),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _card,
                  border: Border.all(
                    color: sel ? _accent : Colors.white38,
                    width: 1.8,
                  ),
                ),
                child: sel
                    ? Container(
                        width: 11,
                        height: 11,
                        decoration: const BoxDecoration(
                            color: _accent, shape: BoxShape.circle),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Text(label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDeco() => BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(90),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      );
} 