// import 'package:cleaning/Choose%20category%20page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// // ---------------------------------------------------------------------------
// //  DARK THEME COLORS (sirf is file ke liye)
// // ---------------------------------------------------------------------------
// const Color _bg = Color(0xFF0D0A22);
// const Color _top = Color(0xFF1A1250);
// const Color _card = Color(0xFF1A1640);
// const Color _line = Color(0xFF2E2763);
// const Color _soft = Color(0xFF2A2360);
// const Color _accent = Color(0xFF9B7DFF);
// const Color _primary = Color(0xFF6F4FF2);
// const Color _sub = Colors.white60;
// const Color _warn = Color(0xFFFFB84D);

// // true  -> user apna time bhi chun sakta hai (chips ke neeche button)
// // false -> sirf 6 chips
// const bool kShowCustomTime = true;

// // ---------------------------------------------------------------------------
// //  ALERT (nice toast)
// // ---------------------------------------------------------------------------
// void _toast(
//   BuildContext context,
//   String message, {
//   IconData icon = Icons.info_rounded,
//   Color color = _warn,
// }) {
//   final m = ScaffoldMessenger.of(context);
//   m.hideCurrentSnackBar();
//   m.showSnackBar(
//     SnackBar(
//       behavior: SnackBarBehavior.floating,
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       padding: EdgeInsets.zero,
//       margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//       duration: const Duration(seconds: 3),
//       content: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: _card,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: color.withAlpha(140)),
//           boxShadow: [
//             BoxShadow(
//               color: color.withAlpha(50),
//               blurRadius: 16,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: color.withAlpha(35),
//               ),
//               child: Icon(icon, color: color, size: 22),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 13.5,
//                   fontWeight: FontWeight.w600,
//                   height: 1.3,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

// /// Booking Details: calendar + time slots
// class BookingDetailsPage extends StatefulWidget {
//   const BookingDetailsPage({
//     super.key,
//     required this.title,
//     required this.image,
//     this.desc,
//     this.price,
//   });

//   final String title;
//   final String? desc;
//   final int? price;
//   final String image;

//   @override
//   State<BookingDetailsPage> createState() => _BookingDetailsPageState();
// }

// class _BookingDetailsPageState extends State<BookingDetailsPage> {
//   // ---------------------------- slots ----------------------------
//   static const List<TimeOfDay> _slots = [
//     TimeOfDay(hour: 9, minute: 0),
//     TimeOfDay(hour: 11, minute: 0),
//     TimeOfDay(hour: 13, minute: 0),
//     TimeOfDay(hour: 15, minute: 0),
//     TimeOfDay(hour: 17, minute: 0),
//     TimeOfDay(hour: 19, minute: 0),
//   ];

//   static const _months = [
//     'January', 'February', 'March', 'April', 'May', 'June',
//     'July', 'August', 'September', 'October', 'November', 'December',
//   ];
//   static const _weekHeader = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

//   static const int _maxMonthsAhead = 11;

//   late DateTime _date;
//   late DateTime _month;
//   TimeOfDay? _time;
//   bool _custom = false;

//   // ---------------------------- lifecycle ----------------------------
//   @override
//   void initState() {
//     super.initState();
//     final now = DateTime.now();
//     var d = DateTime(now.year, now.month, now.day);
//     var t = _firstAvailable(d);
//     if (t == null) {
//       d = DateTime(d.year, d.month, d.day + 1);
//       t = _firstAvailable(d);
//     }
//     _date = d;
//     _month = DateTime(d.year, d.month, 1);
//     _time = t;
//   }

//   // ---------------------------- helpers ----------------------------
//   DateTime get _today {
//     final n = DateTime.now();
//     return DateTime(n.year, n.month, n.day);
//   }

//   bool _sameDay(DateTime a, DateTime b) =>
//       a.year == b.year && a.month == b.month && a.day == b.day;

//   int get _monthOffset {
//     final t = _today;
//     return (_month.year - t.year) * 12 + (_month.month - t.month);
//   }

//   String _fmtTime(TimeOfDay t) {
//     final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
//     final m = t.minute.toString().padLeft(2, '0');
//     final p = t.period == DayPeriod.am ? 'AM' : 'PM';
//     return '${h.toString().padLeft(2, '0')}:$m $p';
//   }

//   // Aaj ki date ho to guzra hua waqt select nahi hoga
//   bool _isPast(DateTime d, TimeOfDay t) {
//     final n = DateTime.now();
//     if (!_sameDay(d, n)) return false;
//     return t.hour * 60 + t.minute <= n.hour * 60 + n.minute;
//   }

//   TimeOfDay? _firstAvailable(DateTime d) {
//     for (final t in _slots) {
//       if (!_isPast(d, t)) return t;
//     }
//     return null;
//   }

//   // Custom time picker ke liye shuru ka waqt
//   TimeOfDay _pickerStart() {
//     if (_custom && _time != null) return _time!;
//     final n = DateTime.now();
//     if (_sameDay(_date, n)) {
//       final h = (n.hour + 1).clamp(0, 23);
//       return TimeOfDay(hour: h, minute: 0);
//     }
//     return const TimeOfDay(hour: 10, minute: 0);
//   }

//   // Custom time wale clock popup ka dark theme
//   Widget _pickerTheme(BuildContext context, Widget? child) {
//     final base = Theme.of(context);
//     const dial = Color(0xFF241E55);
//     const selectedBox = Color(0xFF3B2F8A);

//     Color pick(Set<WidgetState> st, {required Color on, required Color off}) =>
//         st.contains(WidgetState.selected) ? on : off;

//     return Theme(
//       data: base.copyWith(
//         colorScheme: const ColorScheme.dark(
//           primary: _primary,
//           onPrimary: Colors.white,
//           surface: _card,
//           onSurface: Colors.white,
//         ),
//         textButtonTheme: TextButtonThemeData(
//           style: TextButton.styleFrom(
//             foregroundColor: _accent,
//             textStyle:
//                 const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
//           ),
//         ),
//         timePickerTheme: TimePickerThemeData(
//           backgroundColor: _card,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
//           hourMinuteShape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           hourMinuteColor: WidgetStateColor.resolveWith(
//               (st) => pick(st, on: selectedBox, off: dial)),
//           hourMinuteTextColor: WidgetStateColor.resolveWith(
//               (st) => pick(st, on: Colors.white, off: Colors.white70)),
//           hourMinuteTextStyle:
//               const TextStyle(fontSize: 44, fontWeight: FontWeight.w700),
//           dayPeriodShape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//           dayPeriodBorderSide: const BorderSide(color: _line),
//           dayPeriodColor: WidgetStateColor.resolveWith(
//               (st) => pick(st, on: _primary, off: _card)),
//           dayPeriodTextColor: WidgetStateColor.resolveWith(
//               (st) => pick(st, on: Colors.white, off: Colors.white70)),
//           dayPeriodTextStyle:
//               const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
//           dialBackgroundColor: dial,
//           dialHandColor: _primary,
//           dialTextColor: WidgetStateColor.resolveWith(
//               (st) => pick(st, on: Colors.white, off: Colors.white)),
//           entryModeIconColor: _accent,
//           helpTextStyle: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w700,
//             color: _sub,
//           ),
//         ),
//       ),
//       child: child!,
//     );
//   }

//   // ---------------------------- actions ----------------------------
//   void _setDate(DateTime d) {
//     setState(() {
//       _date = d;
//       if (_time != null && _isPast(d, _time!)) {
//         _custom = false;
//         _time = _firstAvailable(d);
//       }
//     });
//   }

//   void _changeMonth(int delta) {
//     final next = _monthOffset + delta;
//     if (next < 0 || next > _maxMonthsAhead) return;
//     setState(() => _month = DateTime(_month.year, _month.month + delta, 1));
//   }

//   Future<void> _pickCustomTime() async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: _pickerStart(),
//       builder: _pickerTheme,
//     );
//     if (picked == null || !mounted) return;
//     if (_isPast(_date, picked)) {
//       _toast(
//         context,
//         'Please choose a time later than now for today.',
//         icon: Icons.schedule_rounded,
//         color: _warn,
//       );
//       return;
//     }
//     setState(() {
//       _time = picked;
//       _custom = true;
//     });
//   }

//   void _next() {
//     final t = _time;
//     if (t == null) return;
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => ChooseCategoryPage(
//           serviceTitle: widget.title,
//           date: _date,
//           time: t,
//         ),
//       ),
//     );
//   }

//   // ------------------------------ UI ------------------------------
//   @override
//   Widget build(BuildContext context) {
//     final hasTime = _time != null;

//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light,
//       child: Scaffold(
//         backgroundColor: _bg,
//         body: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [_top, _bg],
//             ),
//           ),
//           child: SafeArea(
//             bottom: false,
//             child: Column(
//               children: [
//                 // ---- top bar: back + title ----
//                 SizedBox(
//                   height: 60,
//                   child: Row(
//                     children: [
//                       IconButton(
//                         onPressed: () => Navigator.of(context).maybePop(),
//                         icon: const Icon(Icons.arrow_back_rounded,
//                             color: Colors.white, size: 26),
//                       ),
//                       Expanded(
//                         child: Text(
//                           widget.title,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 19,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // ---- dark rounded sheet ----
//                 Expanded(
//                   child: Container(
//                     width: double.infinity,
//                     decoration: const BoxDecoration(
//                       color: _bg,
//                       borderRadius:
//                           BorderRadius.vertical(top: Radius.circular(28)),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: const BorderRadius.vertical(
//                           top: Radius.circular(28)),
//                       child: Column(
//                         children: [
//                           Expanded(
//                             child: SingleChildScrollView(
//                               padding:
//                                   const EdgeInsets.fromLTRB(18, 22, 18, 12),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const _Label('Select Date'),
//                                   const SizedBox(height: 14),
//                                   _calendar(),
//                                   const SizedBox(height: 26),
//                                   const _Label('Select Time'),
//                                   const SizedBox(height: 14),
//                                   _timeGrid(),
//                                   if (kShowCustomTime) _customTimeRow(),
//                                 ],
//                               ),
//                             ),
//                           ),

//                           // ---- Next button ----
//                           SafeArea(
//                             top: false,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.fromLTRB(18, 8, 18, 14),
//                               child: SizedBox(
//                                 width: double.infinity,
//                                 height: 56,
//                                 child: ElevatedButton(
//                                   onPressed: hasTime ? _next : null,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: _primary,
//                                     foregroundColor: Colors.white,
//                                     disabledBackgroundColor:
//                                         _primary.withAlpha(90),
//                                     disabledForegroundColor: Colors.white70,
//                                     elevation: 6,
//                                     shadowColor: _primary.withAlpha(100),
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(16)),
//                                   ),
//                                   child: const Text('Next',
//                                       style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.w700)),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ----------------------- inline calendar -----------------------
//   Widget _calendar() {
//     final first = DateTime(_month.year, _month.month, 1);
//     final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
//     final lead = first.weekday % 7; // Sunday = 0
//     final rows = ((lead + daysInMonth) / 7).ceil();
//     final canPrev = _monthOffset > 0;
//     final canNext = _monthOffset < _maxMonthsAhead;

//     return Container(
//       padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
//       decoration: BoxDecoration(
//         color: _card,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(color: _line),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(90),
//             blurRadius: 14,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               _NavButton(
//                 icon: Icons.chevron_left_rounded,
//                 enabled: canPrev,
//                 onTap: () => _changeMonth(-1),
//               ),
//               Expanded(
//                 child: Text(
//                   '${_months[_month.month - 1]} ${_month.year}',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w800,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               _NavButton(
//                 icon: Icons.chevron_right_rounded,
//                 enabled: canNext,
//                 onTap: () => _changeMonth(1),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               for (final w in _weekHeader)
//                 Expanded(
//                   child: Center(
//                     child: Text(
//                       w,
//                       style: const TextStyle(
//                         fontSize: 11.5,
//                         fontWeight: FontWeight.w600,
//                         color: _sub,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           for (var r = 0; r < rows; r++)
//             Row(
//               children: [
//                 for (var c = 0; c < 7; c++)
//                   Expanded(
//                     child: _dayCell(DateTime(
//                         _month.year, _month.month, 1 - lead + r * 7 + c)),
//                   ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _dayCell(DateTime d) {
//     final inMonth = d.month == _month.month;
//     final today = _today;
//     final past = d.isBefore(today);
//     final selected = inMonth && _sameDay(d, _date);
//     final isToday = _sameDay(d, today);
//     final tappable = inMonth && !past; // guzri hui date select nahi hogi

//     Color textColor;
//     if (selected) {
//       textColor = Colors.white;
//     } else if (!inMonth) {
//       textColor = Colors.white.withAlpha(35); // dusre mahine ke halke din
//     } else if (past) {
//       textColor = Colors.white.withAlpha(75);
//     } else {
//       textColor = Colors.white;
//     }

//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: tappable ? () => _setDate(d) : null,
//       child: SizedBox(
//         height: 44,
//         child: Center(
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 180),
//             width: 36,
//             height: 36,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: selected ? _primary : null,
//               border: (isToday && !selected && inMonth)
//                   ? Border.all(color: _accent, width: 1.3)
//                   : null,
//               boxShadow: selected
//                   ? [
//                       BoxShadow(
//                         color: _primary.withAlpha(120),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ]
//                   : null,
//             ),
//             child: Text(
//               '${d.day}',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
//                 color: textColor,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ------------------------- time slots -------------------------
//   Widget _timeGrid() {
//     return LayoutBuilder(
//       builder: (context, box) {
//         const gap = 12.0;
//         final w = (box.maxWidth - gap * 2) / 3;
//         return Wrap(
//           spacing: gap,
//           runSpacing: gap,
//           children: [
//             for (final t in _slots)
//               SizedBox(
//                 width: w,
//                 child: _TimeChip(
//                   label: _fmtTime(t),
//                   selected: !_custom && _time == t,
//                   enabled: !_isPast(_date, t),
//                   onTap: () => setState(() {
//                     _time = t;
//                     _custom = false;
//                   }),
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }

//   // Apna time chunne ka button (chips ke neeche, poori width)
//   Widget _customTimeRow() {
//     final selected = _custom && _time != null;
//     return GestureDetector(
//       onTap: _pickCustomTime,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         height: 48,
//         width: double.infinity,
//         margin: const EdgeInsets.only(top: 12),
//         decoration: BoxDecoration(
//           color: selected ? _primary : _card,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//               color: selected ? _primary : _accent.withAlpha(110)),
//           boxShadow: selected
//               ? [
//                   BoxShadow(
//                     color: _primary.withAlpha(100),
//                     blurRadius: 12,
//                     offset: const Offset(0, 5),
//                   ),
//                 ]
//               : null,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.access_time_rounded,
//                 size: 20, color: selected ? Colors.white : _accent),
//             const SizedBox(width: 8),
//             Text(
//               selected
//                   ? 'Custom time: ${_fmtTime(_time!)}'
//                   : 'Choose your own time',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 color: selected ? Colors.white : _accent,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ---------------------------------------------------------------------------
// class _Label extends StatelessWidget {
//   const _Label(this.text);
//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: const TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.w800,
//         color: Colors.white,
//       ),
//     );
//   }
// }

// /// Calendar ke mahine badalne wale < > buttons
// class _NavButton extends StatelessWidget {
//   const _NavButton({
//     required this.icon,
//     required this.enabled,
//     required this.onTap,
//   });

//   final IconData icon;
//   final bool enabled;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       onPressed: enabled ? onTap : null,
//       icon: Icon(icon, size: 26),
//       color: Colors.white,
//       disabledColor: Colors.white24,
//     );
//   }
// }

// class _TimeChip extends StatelessWidget {
//   const _TimeChip({
//     required this.label,
//     required this.selected,
//     required this.enabled,
//     required this.onTap,
//   });

//   final String label;
//   final bool selected;
//   final bool enabled;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     final Color bg = selected
//         ? _primary
//         : (enabled ? _card : const Color(0xFF120F2E));
//     final Color fg = selected
//         ? Colors.white
//         : (enabled ? Colors.white : Colors.white30);

//     return GestureDetector(
//       onTap: enabled ? onTap : null,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         height: 46,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: bg,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: selected ? _primary : _line),
//           boxShadow: selected
//               ? [
//                   BoxShadow(
//                     color: _primary.withAlpha(100),
//                     blurRadius: 12,
//                     offset: const Offset(0, 5),
//                   ),
//                 ]
//               : null,
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 13.5,
//             fontWeight: FontWeight.w700,
//             color: fg,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cleaning/Choose%20category%20page.dart';
import 'package:cleaning/app_data.dart'; // BookingPhone
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
const Color _warn = Color(0xFFFFB84D);
const Color _err = Color(0xFFFF6B6B);

// Phone number kitne digit ka ho
const int kPhoneLength = 11;

// true  -> user apna time bhi chun sakta hai (chips ke neeche button)
// false -> sirf 6 chips
const bool kShowCustomTime = true;

// ---------------------------------------------------------------------------
//  ALERT (nice toast)
// ---------------------------------------------------------------------------
void _toast(
  BuildContext context,
  String message, {
  IconData icon = Icons.info_rounded,
  Color color = _warn,
}) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: const Duration(seconds: 3),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(140)),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(50),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(35),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Booking Details: calendar + time slots
class BookingDetailsPage extends StatefulWidget {
  const BookingDetailsPage({
    super.key,
    required this.title,
    required this.image,
    this.desc,
    this.price,
  });

  final String title;
  final String? desc;
  final int? price;
  final String image;

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  // ---------------------------- slots ----------------------------
  static const List<TimeOfDay> _slots = [
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 15, minute: 0),
    TimeOfDay(hour: 17, minute: 0),
    TimeOfDay(hour: 19, minute: 0),
  ];

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const _weekHeader = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  static const int _maxMonthsAhead = 11;

  late DateTime _date;
  late DateTime _month;
  TimeOfDay? _time;
  bool _custom = false;

  // phone input
  final TextEditingController _phoneCtrl = TextEditingController();
  String? _phoneError;

  // ---------------------------- lifecycle ----------------------------
  @override
  void initState() {
    super.initState();
    _phoneCtrl.text = BookingPhone.value; // wapas aane par pehle wala number
    final now = DateTime.now();
    var d = DateTime(now.year, now.month, now.day);
    var t = _firstAvailable(d);
    if (t == null) {
      d = DateTime(d.year, d.month, d.day + 1);
      t = _firstAvailable(d);
    }
    _date = d;
    _month = DateTime(d.year, d.month, 1);
    _time = t;
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ---------------------------- helpers ----------------------------
  // 11 digit check (sirf numbers)
  String? _phoneProblem() {
    final p = _phoneCtrl.text.trim();
    if (p.isEmpty) return 'Please enter your phone number';
    if (!RegExp(r'^[0-9]+$').hasMatch(p)) return 'Only numbers are allowed';
    if (p.length != kPhoneLength) {
      return 'Phone number must be exactly $kPhoneLength digits';
    }
    return null;
  }

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int get _monthOffset {
    final t = _today;
    return (_month.year - t.year) * 12 + (_month.month - t.month);
  }

  String _fmtTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:$m $p';
  }

  // Aaj ki date ho to guzra hua waqt select nahi hoga
  bool _isPast(DateTime d, TimeOfDay t) {
    final n = DateTime.now();
    if (!_sameDay(d, n)) return false;
    return t.hour * 60 + t.minute <= n.hour * 60 + n.minute;
  }

  TimeOfDay? _firstAvailable(DateTime d) {
    for (final t in _slots) {
      if (!_isPast(d, t)) return t;
    }
    return null;
  }

  // Custom time picker ke liye shuru ka waqt
  TimeOfDay _pickerStart() {
    if (_custom && _time != null) return _time!;
    final n = DateTime.now();
    if (_sameDay(_date, n)) {
      final h = (n.hour + 1).clamp(0, 23);
      return TimeOfDay(hour: h, minute: 0);
    }
    return const TimeOfDay(hour: 10, minute: 0);
  }

  // Custom time wale clock popup ka dark theme
  Widget _pickerTheme(BuildContext context, Widget? child) {
    final base = Theme.of(context);
    const dial = Color(0xFF241E55);
    const selectedBox = Color(0xFF3B2F8A);

    Color pick(Set<WidgetState> st, {required Color on, required Color off}) =>
        st.contains(WidgetState.selected) ? on : off;

    return Theme(
      data: base.copyWith(
        colorScheme: const ColorScheme.dark(
          primary: _primary,
          onPrimary: Colors.white,
          surface: _card,
          onSurface: Colors.white,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _accent,
            textStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: _card,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          hourMinuteShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          hourMinuteColor: WidgetStateColor.resolveWith(
              (st) => pick(st, on: selectedBox, off: dial)),
          hourMinuteTextColor: WidgetStateColor.resolveWith(
              (st) => pick(st, on: Colors.white, off: Colors.white70)),
          hourMinuteTextStyle:
              const TextStyle(fontSize: 44, fontWeight: FontWeight.w700),
          dayPeriodShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          dayPeriodBorderSide: const BorderSide(color: _line),
          dayPeriodColor: WidgetStateColor.resolveWith(
              (st) => pick(st, on: _primary, off: _card)),
          dayPeriodTextColor: WidgetStateColor.resolveWith(
              (st) => pick(st, on: Colors.white, off: Colors.white70)),
          dayPeriodTextStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          dialBackgroundColor: dial,
          dialHandColor: _primary,
          dialTextColor: WidgetStateColor.resolveWith(
              (st) => pick(st, on: Colors.white, off: Colors.white)),
          entryModeIconColor: _accent,
          helpTextStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _sub,
          ),
        ),
      ),
      child: child!,
    );
  }

  // ---------------------------- actions ----------------------------
  void _setDate(DateTime d) {
    setState(() {
      _date = d;
      if (_time != null && _isPast(d, _time!)) {
        _custom = false;
        _time = _firstAvailable(d);
      }
    });
  }

  void _changeMonth(int delta) {
    final next = _monthOffset + delta;
    if (next < 0 || next > _maxMonthsAhead) return;
    setState(() => _month = DateTime(_month.year, _month.month + delta, 1));
  }

  Future<void> _pickCustomTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _pickerStart(),
      builder: _pickerTheme,
    );
    if (picked == null || !mounted) return;
    if (_isPast(_date, picked)) {
      _toast(
        context,
        'Please choose a time later than now for today.',
        icon: Icons.schedule_rounded,
        color: _warn,
      );
      return;
    }
    setState(() {
      _time = picked;
      _custom = true;
    });
  }

  void _next() {
    final t = _time;
    if (t == null) return;

    // phone number validation
    final problem = _phoneProblem();
    if (problem != null) {
      setState(() => _phoneError = problem);
      _toast(
        context,
        problem,
        icon: Icons.phone_rounded,
        color: _err,
      );
      return;
    }
    BookingPhone.value = _phoneCtrl.text.trim();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChooseCategoryPage(
          serviceTitle: widget.title,
          date: _date,
          time: t,
        ),
      ),
    );
  }

  // ------------------------------ UI ------------------------------
  @override
  Widget build(BuildContext context) {
    final hasTime = _time != null;

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
                // ---- top bar: back + title ----
                SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 26),
                      ),
                      Expanded(
                        child: Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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
                                  const EdgeInsets.fromLTRB(18, 22, 18, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _Label('Select Date'),
                                  const SizedBox(height: 14),
                                  _calendar(),
                                  const SizedBox(height: 26),
                                  const _Label('Select Time'),
                                  const SizedBox(height: 14),
                                  _timeGrid(),
                                  if (kShowCustomTime) _customTimeRow(),
                                ],
                              ),
                            ),
                          ),

                          // ---- Phone number + Next button ----
                          SafeArea(
                            top: false,
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(18, 8, 18, 14),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _phoneField(),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: hasTime ? _next : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        _primary.withAlpha(90),
                                    disabledForegroundColor: Colors.white70,
                                    elevation: 6,
                                    shadowColor: _primary.withAlpha(100),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  child: const Text('Next',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ),
                                ],
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

  // ----------------------- phone input -----------------------
  Widget _phoneField() {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );

    return TextField(
      controller: _phoneCtrl,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(kPhoneLength),
      ],
      onChanged: (_) {
        if (_phoneError != null) setState(() => _phoneError = null);
      },
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
      cursorColor: _accent,
      decoration: InputDecoration(
        isDense: true,
        counterText: '',
        hintText: 'Phone number (11 digits)',
        hintStyle: const TextStyle(
            color: Colors.white38, fontSize: 14, letterSpacing: 0),
        errorText: _phoneError,
        errorStyle: const TextStyle(color: _err, fontSize: 12),
        prefixIcon:
            const Icon(Icons.phone_outlined, color: _accent, size: 22),
        filled: true,
        fillColor: _card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        enabledBorder: border(_line),
        focusedBorder: border(_primary, 1.5),
        errorBorder: border(_err),
        focusedErrorBorder: border(_err, 1.5),
      ),
    );
  }

  // ----------------------- inline calendar -----------------------
  Widget _calendar() {
    final first = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final lead = first.weekday % 7; // Sunday = 0
    final rows = ((lead + daysInMonth) / 7).ceil();
    final canPrev = _monthOffset > 0;
    final canNext = _monthOffset < _maxMonthsAhead;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
      decoration: BoxDecoration(
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
      ),
      child: Column(
        children: [
          Row(
            children: [
              _NavButton(
                icon: Icons.chevron_left_rounded,
                enabled: canPrev,
                onTap: () => _changeMonth(-1),
              ),
              Expanded(
                child: Text(
                  '${_months[_month.month - 1]} ${_month.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              _NavButton(
                icon: Icons.chevron_right_rounded,
                enabled: canNext,
                onTap: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final w in _weekHeader)
                Expanded(
                  child: Center(
                    child: Text(
                      w,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _sub,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          for (var r = 0; r < rows; r++)
            Row(
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(
                    child: _dayCell(DateTime(
                        _month.year, _month.month, 1 - lead + r * 7 + c)),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _dayCell(DateTime d) {
    final inMonth = d.month == _month.month;
    final today = _today;
    final past = d.isBefore(today);
    final selected = inMonth && _sameDay(d, _date);
    final isToday = _sameDay(d, today);
    final tappable = inMonth && !past; // guzri hui date select nahi hogi

    Color textColor;
    if (selected) {
      textColor = Colors.white;
    } else if (!inMonth) {
      textColor = Colors.white.withAlpha(35); // dusre mahine ke halke din
    } else if (past) {
      textColor = Colors.white.withAlpha(75);
    } else {
      textColor = Colors.white;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: tappable ? () => _setDate(d) : null,
      child: SizedBox(
        height: 44,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? _primary : null,
              border: (isToday && !selected && inMonth)
                  ? Border.all(color: _accent, width: 1.3)
                  : null,
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: _primary.withAlpha(120),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              '${d.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------- time slots -------------------------
  Widget _timeGrid() {
    return LayoutBuilder(
      builder: (context, box) {
        const gap = 12.0;
        final w = (box.maxWidth - gap * 2) / 3;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final t in _slots)
              SizedBox(
                width: w,
                child: _TimeChip(
                  label: _fmtTime(t),
                  selected: !_custom && _time == t,
                  enabled: !_isPast(_date, t),
                  onTap: () => setState(() {
                    _time = t;
                    _custom = false;
                  }),
                ),
              ),
          ],
        );
      },
    );
  }

  // Apna time chunne ka button (chips ke neeche, poori width)
  Widget _customTimeRow() {
    final selected = _custom && _time != null;
    return GestureDetector(
      onTap: _pickCustomTime,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 48,
        width: double.infinity,
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: selected ? _primary : _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? _primary : _accent.withAlpha(110)),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _primary.withAlpha(100),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time_rounded,
                size: 20, color: selected ? Colors.white : _accent),
            const SizedBox(width: 8),
            Text(
              selected
                  ? 'Custom time: ${_fmtTime(_time!)}'
                  : 'Choose your own time',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : _accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    );
  }
}

/// Calendar ke mahine badalne wale < > buttons
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 26),
      color: Colors.white,
      disabledColor: Colors.white24,
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg = selected
        ? _primary
        : (enabled ? _card : const Color(0xFF120F2E));
    final Color fg = selected
        ? Colors.white
        : (enabled ? Colors.white : Colors.white30);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? _primary : _line),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _primary.withAlpha(100),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }
}
