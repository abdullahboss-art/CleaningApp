import 'package:flutter/material.dart';
import '../app_data.dart';
import '../common.dart';
import 'my_bookings_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bars = [0.30, 0.45, 0.38, 0.62, 0.55, 0.85];

    Widget quick(IconData icon, String label, Color color, VoidCallback tap) =>
        GestureDetector(
          onTap: tap,
          child: Column(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: color.withAlpha(35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                      color: AC.text,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        );

    return PurpleScaffold(
      title: 'SparkClean',
      actions: [
        IconButton(
          onPressed: () => snack(context, 'Koi nayi notification nahi.'),
          icon: const Icon(Icons.notifications_rounded),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AC.gradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Bookings',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Text('48',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.w800)),
                            SizedBox(width: 8),
                            Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text('↑ 12%',
                                  style: TextStyle(
                                      color: Color(0xFF6EF0B0),
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 70,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: bars
                          .map((h) => Container(
                                width: 12,
                                height: 70 * h,
                                margin: const EdgeInsets.only(left: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(150),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('Quick Actions',
                style: TextStyle(
                    color: AC.text, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                quick(Icons.add_circle_rounded, 'Book Service', AC.primary,
                    () => Navigator.pushNamed(context, Routes.search)),
                quick(
                    Icons.calendar_month_rounded,
                    'My Bookings',
                    const Color(0xFF6B4DF0),
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const MyBookingsPage(showBack: true)))),
                quick(Icons.local_offer_rounded, 'Offers',
                    const Color(0xFFFF9F43),
                    () => snack(context, 'Offers jald aayenge.')),
                quick(Icons.support_agent_rounded, 'Support', AC.dark,
                    () => snack(context, 'Support jald aayega.')),
              ],
            ),
            const SizedBox(height: 22),
            const Text('Recent Activity',
                style: TextStyle(
                    color: AC.text, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ValueListenableBuilder<List<Booking>>(
              valueListenable: BookingStore.items,
              builder: (_, all, __) {
                final recent = all.take(3).toList();
                return Column(
                  children: recent
                      .map((b) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: WhiteCard(
                              child: Row(
                                children: [
                                  AppImage(b.image,
                                      width: 48, height: 48, radius: 10),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(b.title,
                                            style: const TextStyle(
                                                color: AC.text,
                                                fontWeight: FontWeight.w700)),
                                        Text('${b.date} • ${b.status}',
                                            style: const TextStyle(
                                                color: AC.grey, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: AC.grey),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
