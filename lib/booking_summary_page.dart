import 'package:cleaning/app_data.dart'; // BookingPhone
import 'package:cleaning/booking_confirmed_page.dart'; // BookingConfirmedPage
import 'package:cleaning/common.dart'; // fmtDate
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String _kCurrency = 'AED';

// ---------------------------------------------------------------------------
//  DARK THEME COLORS (sirf is file ke liye)
// ---------------------------------------------------------------------------
const Color _bg = Color(0xFF0D0A22);
const Color _top = Color(0xFF1A1250);
const Color _card = Color(0xFF1A1640);
const Color _line = Color(0xFF2E2763);
const Color _soft = Color(0xFF2A2360);
const Color _accentC = Color(0xFF9B7DFF);
const Color _primary = Color(0xFF6F4FF2);
const Color _sub = Colors.white60;

/// Review & Confirm screen.
/// Choose Category page se aati hai, "Confirm Booking" dabane par
/// BookingConfirmedPage khulti hai.
class BookingSummaryPage extends StatelessWidget {
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
  final num price;
  final Object duration; // "2-3 Hours" ya number, dono chalega
  final DateTime date;
  final TimeOfDay time;
  final String packageImage;
  final Color accent;
  final Color cardBg;

  String _fmtTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:$m $p';
  }

  void _confirm(BuildContext context) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingConfirmedPage(
          serviceTitle: serviceTitle,
          packageName: packageName,
          price: price.toInt(),
          date: date,
          time: time,
          image: packageImage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phone = BookingPhone.value;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ---- header ----
              Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_top, _bg],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Review & Confirm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---- body ----
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                  child: Column(
                    children: [
                      _packageCard(),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _line),
                        ),
                        child: Column(
                          children: [
                            _row(Icons.cleaning_services_rounded, 'Service',
                                serviceTitle),
                            _div(),
                            _row(Icons.workspace_premium_rounded, 'Package',
                                packageName),
                            _div(),
                            _row(Icons.calendar_today_rounded, 'Date',
                                fmtDate(date)),
                            _div(),
                            _row(Icons.access_time_rounded, 'Time',
                                _fmtTime(time)),
                            _div(),
                            _row(Icons.timelapse_rounded, 'Duration',
                                '$duration'),
                            if (phone.isNotEmpty) ...[
                              _div(),
                              _row(Icons.phone_outlined, 'Phone', phone),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _line),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 20, color: _accentC),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Please check your details. Our admin will '
                                'confirm your booking after you submit it.',
                                style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.35,
                                    color: _sub),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---- bottom: total + confirm ----
              Container(
                padding: EdgeInsets.fromLTRB(
                    20, 12, 20, 14 + MediaQuery.of(context).padding.bottom),
                decoration: const BoxDecoration(
                  color: _bg,
                  border: Border(top: BorderSide(color: _line)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text('Total Amount',
                            style: TextStyle(
                                color: _sub,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text(
                          '$_kCurrency ${price.toInt()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => _confirm(context),
                        icon: const Icon(Icons.check_circle_outline_rounded,
                            size: 22),
                        label: const Text('Confirm Booking',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shadowColor: _primary.withAlpha(100),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
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

  // ---------------- package card ----------------
  Widget _packageCard() {
    // Dark theme: card ka background dark rakha hai, package ka rang
    // (accent) sirf border, glow aur halki tint me use hota hai.
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(accent.withAlpha(48), _card),
            Color.alphaBlend(cardBg.withAlpha(18), _card),
          ],
        ),
        border: Border.all(color: accent.withAlpha(150), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: accent.withAlpha(45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withAlpha(36),
              border: Border.all(color: accent.withAlpha(90)),
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  packageImage,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.workspace_premium_rounded,
                    color: accent,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent.withAlpha(34),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$packageName Package',
                    style: TextStyle(
                      color: accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$_kCurrency ${price.toInt()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _div() => Divider(height: 1, color: _line.withAlpha(180));

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _soft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: _accentC),
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
}