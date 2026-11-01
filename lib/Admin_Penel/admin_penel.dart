import 'package:cleaning/app_data.dart';
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

  void _open(String filter, [Booking? booking]) =>
      widget.onOpenBookings?.call(filter, booking);

  Color _statusColor(String s) {
    switch (s) {
      case 'Completed':
        return _green;
      case 'Cancelled':
        return _red;
      default:
        return _orange;
    }
  }

  String _statusLabel(String s) => s == 'Upcoming' ? 'Pending' : s;

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
    final c = _statusColor(b.status);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _open('All', b),
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
              child: Text(_statusLabel(b.status),
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
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ValueListenableBuilder<List<Booking>>(
          valueListenable: BookingStore.items,
          builder: (context, all, _) {
            int count(String s) => all.where((b) => b.status == s).length;
            final total = all.length;
            final pending = count('Upcoming');
            final done = count('Completed');
            final cancelled = count('Cancelled');

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                // ---- top bar ----
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _purple.withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.dashboard_rounded,
                          color: _purple, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Dashboard',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                    ),
                    IconButton(
                      onPressed: () => _open('All'),
                      tooltip: 'Search bookings',
                      icon: const Icon(Icons.search_rounded,
                          color: Colors.white),
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
                  ...all.map((b) => Padding(
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