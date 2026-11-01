import 'package:cleaning/home_screen.dart';
import 'package:flutter/material.dart';

import 'my_bookings_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';

// ---------------------------------------------------------------------------
//  NAV COLORS (home page wali dark theme se match)
// ---------------------------------------------------------------------------
const Color _navBg = Color(0xFF0D0A22);
const Color _navBorder = Color(0xFF2E2763);
const Color _navAccent = Color(0xFF9B7DFF);
const Color _navInactive = Colors.white;

class _NavItem {
  const _NavItem(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const List<_NavItem> _items = [
  _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
  _NavItem(Icons.calendar_month_outlined, Icons.calendar_month_rounded,
      'Bookings'),
  _NavItem(Icons.notifications_none_rounded, Icons.notifications_rounded,
      'Notifications'),
  _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
];

/// Bottom navigation: Home / Bookings / Notifications / Profile.
/// Kisi aur page se tab kholne ke liye:
/// Navigator.pushNamedAndRemoveUntil(context, Routes.main, (_) => false, arguments: 1);
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      final a = ModalRoute.of(context)?.settings.arguments;
      if (a is int) _index = a;
      _init = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navBg,
      body: IndexedStack(
        index: _index,
        children: const [
          HomePage(),
          MyBookingsPage(showBack: false, initialTab: 2,),
          NotificationsPage(showBack: false),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: _navBg,
          border: Border(top: BorderSide(color: _navBorder, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (int i = 0; i < _items.length; i++)
                  Expanded(
                    child: _NavButton(
                      item: _items[i],
                      selected: i == _index,
                      onTap: () => setState(() => _index = i),
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

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _navAccent : _navInactive;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(begin: color, end: color),
        duration: const Duration(milliseconds: 250),
        builder: (context, c, _) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              size: 26,
              color: c,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}