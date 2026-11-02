import 'dart:math' as math;

import 'package:cleaning/app_data.dart';
import 'package:flutter/material.dart';

/// Admin > Reports (LIVE): Firestore ki bookings se khud update hota hai.
/// Tabs: Bookings / Revenue / Services. Date range badal sakte ho.
class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  static const _bg = Color(0xFF0B0B18);
  static const _card = Color(0xFF121C30);
  static const _border = Color(0xFF1F2B45);
  static const _purple = Color(0xFF8B5CF6);
  static const _muted = Color(0xFF8A94A8);
  static const _green = Color(0xFF2EC27E);
  static const _red = Color(0xFFFF4D4F);

  static const _tabs = ['Bookings', 'Revenue', 'Services'];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  // SAB users ki bookings, Firestore se live
  late final Stream<List<Booking>> _stream = BookingStore.allStream();

  int _tab = 0;
  late DateTimeRange _range = _thisMonth();

  static DateTimeRange _thisMonth() {
    final n = DateTime.now();
    return DateTimeRange(
      start: DateTime(n.year, n.month, 1),
      end: DateTime(n.year, n.month + 1, 0),
    );
  }

  // ---------------- helpers ----------------
  String _d(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';
  String _short(DateTime d) => '${_months[d.month - 1]} ${d.day}';

  /// "Nov 1, 2026 • 09:00 AM" -> DateTime(2026, 11, 1)
  DateTime? _dateOf(Booking b) {
    final m = RegExp(r'([A-Za-z]{3})[A-Za-z]*\.?\s+(\d{1,2}),?\s+(\d{4})')
        .firstMatch(b.date);
    if (m == null) return null;
    final mi = _months.indexWhere(
        (x) => x.toLowerCase() == m.group(1)!.toLowerCase());
    if (mi < 0) return null;
    return DateTime(
        int.parse(m.group(3)!), mi + 1, int.parse(m.group(2)!));
  }

  bool _in(DateTime d, DateTime a, DateTime b) =>
      !d.isBefore(a) && !d.isAfter(b);

  /// Revenue: sirf confirmed ya completed bookings (pending/cancelled nahi)
  double _revenue(Booking b) {
    final ok = b.status == 'Completed' ||
        (b.status == 'Upcoming' && b.confirmed);
    return ok ? b.price.toDouble() : 0;
  }

  String _money(num v) {
    final s = v.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '\$$buf';
  }

  String _serviceName(String t) => t == 'Home Cleaning' ? 'Regular Cleaning' : t;

  Future<void> _pickRange() async {
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      initialDateRange: _range,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _purple,
            surface: _card,
          ),
        ),
        child: child!,
      ),
    );
    if (r != null) setState(() => _range = r);
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: StreamBuilder<List<Booking>>(
          stream: _stream,
          builder: (context, snap) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 14),
                  _tabBar(),
                  const SizedBox(height: 12),
                  _rangeRow(),
                  const SizedBox(height: 12),
                  Expanded(child: _body(snap)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _purple.withAlpha(40),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.bar_chart_rounded, color: _purple, size: 20),
        ),
        const SizedBox(width: 10),
        const Text('Reports',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        const Spacer(),
        // LIVE badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _green.withAlpha(30),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _green.withAlpha(110)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, color: _green, size: 8),
              SizedBox(width: 5),
              Text('Live',
                  style: TextStyle(
                      color: _green,
                      fontSize: 11,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabBar() {
    return Row(
      children: [
        for (var i = 0; i < _tabs.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == _tabs.length - 1 ? 0 : 8),
              child: GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _tab == i ? _purple : _card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _tab == i ? _purple : _border),
                  ),
                  child: Text(_tabs[i],
                      style: TextStyle(
                          color: _tab == i ? Colors.white : _muted,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _rangeRow() {
    return GestureDetector(
      onTap: _pickRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: _muted, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text('${_d(_range.start)} - ${_d(_range.end)}',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
            ),
            const Icon(Icons.chevron_right_rounded, color: _muted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _body(AsyncSnapshot<List<Booking>> snap) {
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
      return const Center(child: CircularProgressIndicator(color: _purple));
    }

    // ---- data tayyar karo ----
    final entries = <(DateTime, Booking)>[];
    for (final b in snap.data!) {
      final d = _dateOf(b);
      if (d != null) entries.add((d, b));
    }

    final start = DateTime(_range.start.year, _range.start.month, _range.start.day);
    final end = DateTime(_range.end.year, _range.end.month, _range.end.day);
    final days = end.difference(start).inDays + 1;
    final prevEnd = start.subtract(const Duration(days: 1));
    final prevStart = prevEnd.subtract(Duration(days: days - 1));

    final cur = entries.where((e) => _in(e.$1, start, end)).toList();
    final prev = entries.where((e) => _in(e.$1, prevStart, prevEnd)).toList();

    final isRevenue = _tab == 1;
    double val(Booking b) => isRevenue ? _revenue(b) : 1;

    final total = cur.fold<double>(0, (s, e) => s + val(e.$2));
    final prevTotal = prev.fold<double>(0, (s, e) => s + val(e.$2));

    // ---- chart: 31 din tak har din ka ek point (har booking nazar aati hai),
    //      us se lambi range me 8 hisse ----
    final perDay = days <= 31;
    final n = perDay ? days : math.min(8, days);
    final size = perDay ? 1 : (days / n).ceil();
    final values = List<double>.filled(n, 0);
    for (final e in cur) {
      final i = math.min(n - 1, e.$1.difference(start).inDays ~/ size);
      values[i] += val(e.$2);
    }
    // x-axis par ~5 labels (baaki khali) taake bheed na ho
    final step = math.max(1, (n / 5).ceil());
    final labels = <String>[
      for (var i = 0; i < n; i++)
        (i == 0 || i == n - 1 || (i % step == 0 && (n - 1 - i) > step ~/ 2))
            ? _short(i == n - 1
                ? end
                : start.add(Duration(days: i * size)))
            : '',
    ];

    // ---- top services ----
    final byService = <String, double>{};
    for (final e in cur) {
      final v = _tab == 2 ? 1.0 : val(e.$2);
      if (v == 0) continue;
      byService[_serviceName(e.$2.title)] =
          (byService[_serviceName(e.$2.title)] ?? 0) + v;
    }
    final services = byService.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sum = services.fold<double>(0, (s, e) => s + e.value);
    final shownServices = _tab == 2 ? services : services.take(5).toList();

    final String totalLabel = _tab == 0
        ? 'Total Bookings'
        : _tab == 1
            ? 'Total Revenue'
            : 'Services Booked';
    final String totalText = _tab == 2
        ? '${services.length}'
        : (isRevenue ? _money(total) : total.round().toString());

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- total + chart ----------
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(totalLabel,
                    style: const TextStyle(color: _muted, fontSize: 12.5)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(totalText,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800)),
                    const Spacer(),
                    if (_tab != 2) _changeBadge(total, prevTotal),
                  ],
                ),
                if (_tab != 2) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 170,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _AreaChartPainter(
                        values: values,
                        labels: labels,
                        money: isRevenue,
                      ),
                    ),
                  ),
                ],
                if (cur.isEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Is period me koi booking nahi.',
                      style: TextStyle(color: _muted, fontSize: 12)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ---------- top services ----------
          Text(_tab == 2 ? 'All Services' : 'Top Services',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: shownServices.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Center(
                      child: Text('No data',
                          style: TextStyle(color: _muted)),
                    ),
                  )
                : Column(
                    children: [
                      for (final s in shownServices)
                        _serviceRow(
                          s.key,
                          isRevenue ? _money(s.value) : s.value.round().toString(),
                          sum == 0 ? 0 : (s.value / sum * 100).round(),
                          s.value / (sum == 0 ? 1 : sum),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _changeBadge(double cur, double prev) {
    if (prev == 0) {
      if (cur == 0) return const SizedBox.shrink();
      return _badge('New', _green, Icons.arrow_upward_rounded);
    }
    final pct = ((cur - prev) / prev * 100).round();
    final up = pct >= 0;
    return _badge('${pct.abs()}%', up ? _green : _red,
        up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded);
  }

  Widget _badge(String text, Color c, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: c, size: 14),
          const SizedBox(width: 3),
          Text(text,
              style: TextStyle(
                  color: c, fontSize: 12, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _serviceRow(String name, String value, int pct, double frac) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _purple.withAlpha(50),
                  border: Border.all(color: _purple.withAlpha(150)),
                ),
                child: const Icon(Icons.circle, color: Colors.white, size: 9),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600)),
              ),
              Text('$value ($pct%)',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: frac.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: _border,
              valueColor: const AlwaysStoppedAnimation(_purple),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  AREA CHART (bina kisi package ke)
// ---------------------------------------------------------------------------
class _AreaChartPainter extends CustomPainter {
  _AreaChartPainter({
    required this.values,
    required this.labels,
    required this.money,
  });

  final List<double> values;
  final List<String> labels;
  final bool money;

  static const _line = Color(0xFFA78BFA);
  static const _fill = Color(0xFF8B5CF6);
  static const _grid = Color(0xFF1F2B45);
  static const _muted = Color(0xFF8A94A8);

  double _niceStep(double max) {
    if (max <= 0) return 1;
    final raw = max / 4;
    final mag =
        math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    for (final m in const [1.0, 2.0, 2.5, 5.0, 10.0]) {
      if (raw <= m * mag) return math.max(1, m * mag);
    }
    return math.max(1, 10 * mag);
  }

  String _fmt(double v) {
    if (v >= 1000) {
      final k = v / 1000;
      return '${k.toStringAsFixed(k % 1 == 0 ? 0 : 1)}k';
    }
    return v.toStringAsFixed(v % 1 == 0 ? 0 : 1);
  }

  void _text(Canvas c, String s, Offset o,
      {bool rightAlign = false, bool center = false}) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: const TextStyle(color: _muted, fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    var dx = o.dx;
    if (rightAlign) dx -= tp.width;
    if (center) dx -= tp.width / 2;
    c.save();
    tp.paint(c, Offset(dx, o.dy - tp.height / 2));
    c.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    const left = 34.0, right = 10.0, top = 8.0, bottom = 24.0;
    final w = size.width - left - right;
    final h = size.height - top - bottom;
    if (w <= 0 || h <= 0 || values.isEmpty) return;

    final maxRaw = values.reduce(math.max);
    final step = _niceStep(maxRaw);
    final maxV = step * 4;

    // grid + y labels
    final grid = Paint()
      ..color = _grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = top + h - h * i / 4;
      canvas.drawLine(Offset(left, y), Offset(left + w, y), grid);
      _text(canvas, _fmt(step * i), Offset(left - 6, y), rightAlign: true);
    }

    // points
    final n = values.length;
    final pts = <Offset>[
      for (var i = 0; i < n; i++)
        Offset(
          n > 1 ? left + w * i / (n - 1) : left + w / 2,
          top + h - h * (values[i] / maxV),
        ),
    ];

    // smooth line
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < n; i++) {
      final cx = (pts[i - 1].dx + pts[i].dx) / 2;
      path.cubicTo(cx, pts[i - 1].dy, cx, pts[i].dy, pts[i].dx, pts[i].dy);
    }

    // gradient fill
    if (n > 1) {
      final fill = Path.from(path)
        ..lineTo(pts.last.dx, top + h)
        ..lineTo(pts.first.dx, top + h)
        ..close();
      canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_fill.withAlpha(170), _fill.withAlpha(8)],
          ).createShader(Rect.fromLTWH(left, top, w, h)),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = _line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    }

    // dots + x labels
    final many = n > 12; // bohot points ho to chhote dots, sirf booking wale din
    for (var i = 0; i < n; i++) {
      if (!many) {
        canvas.drawCircle(pts[i], 4, Paint()..color = _fill);
        canvas.drawCircle(pts[i], 2.2, Paint()..color = Colors.white);
      } else if (values[i] > 0) {
        canvas.drawCircle(pts[i], 2.6, Paint()..color = Colors.white);
      }
      if (i < labels.length && labels[i].isNotEmpty) {
        var x = pts[i].dx;
        // kinare ke labels bahar na jayein
        x = x.clamp(14.0, size.width - 16.0);
        _text(canvas, labels[i], Offset(x, top + h + 14), center: true);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter old) =>
      old.values != values || old.labels != labels || old.money != money;
}