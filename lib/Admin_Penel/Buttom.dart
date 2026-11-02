<<<<<<< HEAD
=======
import 'package:cleaning/Admin_Penel/Admin%20reports%20page.dart';
>>>>>>> 552025e (Update Cleaning App)
import 'package:cleaning/Admin_Penel/admin_bookings.dart';
import 'package:cleaning/Admin_Penel/admin_customers.dart';
import 'package:cleaning/Admin_Penel/admin_penel.dart';
import 'package:flutter/material.dart';



class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  late final List<Widget> _pages = [
  const AdminHomePage(),
  const AdminBookingsPage(),
  const AdminCustomersPage(),
<<<<<<< HEAD
  // const _MorePage(),
=======
  const AdminReportsPage(),
>>>>>>> 552025e (Update Cleaning App)
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B18),
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          NavItem(
              label: 'Dashboard',
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded),
          NavItem(
              label: 'Bookings',
              icon: Icons.calendar_today_outlined,
              activeIcon: Icons.calendar_today_rounded),
          NavItem(
              label: 'Customers',
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded),
          NavItem(
              label: 'More',
              icon: Icons.grid_view_outlined,
              activeIcon: Icons.grid_view_rounded),
        ],
      ),
    );
  }
}

class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  static const Color _bg = Color(0xFF0B0B18);
  static const Color _purple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(items.length, (i) {
              return Expanded(
                child: _NavButton(
                  item: items[i],
                  selected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const purple = CustomBottomNav._purple;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: purple.withOpacity(0.15),
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: 40,
            height: 36,
            decoration: BoxDecoration(
              color: selected ? purple.withOpacity(0.18) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? purple.withOpacity(0.7) : Colors.transparent,
                width: 1.2,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: purple.withOpacity(0.35),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              selected ? item.activeIcon : item.icon,
              size: 22,
              color: selected ? purple : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected ? purple : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}