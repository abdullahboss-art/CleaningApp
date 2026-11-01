// import 'package:cleaning/Admin_Penel/admin_toast.dart';
// import 'package:cleaning/app_data.dart';
// import 'package:flutter/material.dart';

// class AdminBookingDetailsPage extends StatelessWidget {
//   final Booking booking;
//   const AdminBookingDetailsPage({super.key, required this.booking});

//   static const _bg = Color(0xFF0B0B18);
//   static const _card = Color(0xFF121C30);
//   static const _border = Color(0xFF1F2B45);
//   static const _iconBg = Color(0xFF1B2742);
//   static const _purple = Color(0xFF8B5CF6);
//   static const _muted = Color(0xFF8A94A8);
//   static const _green = Color(0xFF2EC27E);
//   static const _orange = Color(0xFFFFA726);
//   static const _red = Color(0xFFFF4D4F);

//   bool get _isPending => booking.status == 'Upcoming' && !booking.confirmed;

//   String get _statusText {
//     if (booking.status == 'Cancelled') return 'Cancelled';
//     if (booking.status == 'Completed') return 'Completed';
//     return booking.confirmed ? 'Confirmed' : 'Pending';
//   }

//   Color get _statusColor {
//     switch (_statusText) {
//       case 'Cancelled':
//         return _red;
//       case 'Pending':
//         return _orange;
//       default:
//         return _green;
//     }
//   }

//   // update() Firestore me save karta hai aur customer ko notification bhejta hai
//   Future<void> _confirm(BuildContext context) async {
//     booking.confirmed = true;
//     booking.status = 'Upcoming';
//     await _save(
//       context,
//       type: AdminToastType.confirmed,
//       title: 'Booking Confirmed',
//     );
//   }

//   Future<void> _reject(BuildContext context) async {
//     booking.confirmed = false;
//     booking.status = 'Cancelled';
//     await _save(
//       context,
//       type: AdminToastType.cancelled,
//       title: 'Booking Rejected',
//     );
//   }

//   Future<void> _save(
//     BuildContext context, {
//     required AdminToastType type,
//     required String title,
//   }) async {
//     final m = ScaffoldMessenger.of(context);
//     final nav = Navigator.of(context);

//     final ok = await BookingStore.update(booking);
//     nav.pop();

//     if (!ok) {
//       // Firestore ne write reject kiya: pehle jhoota "confirmed" dikhata tha
//       m.showSnackBar(SnackBar(
//         backgroundColor: _red,
//         duration: const Duration(seconds: 8),
//         content: Text('Save nahi hua! Firestore Rules check karo.\n'
//             '${BookingStore.lastWriteError}'),
//       ));
//       return;
//     }
//     showAdminToast(
//       m,
//       type: type,
//       title: title,
//       message: '${booking.title} • ${booking.date}',
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final b = booking;
//     final parts = b.date.split('•');
//     final dateOnly = parts.first.trim();
//     final timeOnly = parts.length > 1 ? parts.last.trim() : '-';

//     return Scaffold(
//       backgroundColor: _bg,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
//               child: Row(
//                 children: [
//                   IconButton(
//                     onPressed: () => Navigator.of(context).maybePop(),
//                     icon: const Icon(Icons.arrow_back_rounded,
//                         color: Colors.white),
//                   ),
//                   const Text('Booking Details',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w800)),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // top card: image + title + status
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: _box(),
//                       child: Row(
//                         children: [
//                           ClipOval(
//                             child: Image.asset(
//                               b.image,
//                               width: 48,
//                               height: 48,
//                               fit: BoxFit.cover,
//                               errorBuilder: (_, __, ___) => Container(
//                                 width: 48,
//                                 height: 48,
//                                 color: _iconBg,
//                                 child: const Icon(
//                                     Icons.cleaning_services_rounded,
//                                     color: _purple,
//                                     size: 22),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(b.title,
//                                     style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w800)),
//                                 const SizedBox(height: 2),
//                                 Text(b.address,
//                                     style: const TextStyle(
//                                         color: _muted, fontSize: 12)),
//                               ],
//                             ),
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 12, vertical: 5),
//                             decoration: BoxDecoration(
//                               color: _statusColor.withAlpha(30),
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(
//                                   color: _statusColor.withAlpha(140)),
//                             ),
//                             child: Text(_statusText,
//                                 style: TextStyle(
//                                     color: _statusColor,
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.w700)),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 18),

//                     const Text('Service Details',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 15,
//                             fontWeight: FontWeight.w800)),
//                     const SizedBox(height: 10),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 14, vertical: 6),
//                       decoration: _box(),
//                       child: Column(
//                         children: [
//                           if (b.customerName.isNotEmpty)
//                             _row(Icons.person_rounded, 'Customer',
//                                 b.customerName),
//                           _row(Icons.cleaning_services_rounded, 'Service',
//                               b.title),
//                           _row(Icons.card_giftcard_rounded, 'Package',
//                               b.package),
//                           _row(Icons.calendar_today_rounded, 'Date',
//                               dateOnly),
//                           _row(Icons.access_time_rounded, 'Time', timeOnly),
//                           _row(Icons.location_on_rounded, 'Address',
//                               b.address),
//                           _row(Icons.payments_rounded, 'Total Amount',
//                               '\$${b.price}',
//                               last: true),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Reject / Confirm (sirf pending par)
//             if (_isPending)
//               Container(
//                 padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//                 decoration: const BoxDecoration(
//                   color: _bg,
//                   border: Border(top: BorderSide(color: _border)),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () => _reject(context),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: _red,
//                           side: const BorderSide(color: _red, width: 1.4),
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14)),
//                         ),
//                         child: const Text('Reject',
//                             style: TextStyle(fontWeight: FontWeight.w700)),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () => _confirm(context),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _purple,
//                           foregroundColor: Colors.white,
//                           elevation: 0,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14)),
//                         ),
//                         child: const Text('Confirm',
//                             style: TextStyle(fontWeight: FontWeight.w700)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   BoxDecoration _box() => BoxDecoration(
//         color: _card,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: _border),
//       );

//   Widget _row(IconData icon, String label, String value,
//       {bool last = false}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 11),
//       decoration: BoxDecoration(
//         border: last
//             ? null
//             : const Border(bottom: BorderSide(color: _border, width: .6)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 28,
//             height: 28,
//             decoration: BoxDecoration(
//                 color: _iconBg, borderRadius: BorderRadius.circular(8)),
//             child: Icon(icon, color: _purple, size: 15),
//           ),
//           const SizedBox(width: 10),
//           Text(label, style: const TextStyle(color: _muted, fontSize: 13)),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(value,
//                 textAlign: TextAlign.right,
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w700)),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cleaning/Admin_Penel/admin_toast.dart';
import 'package:cleaning/app_data.dart';
import 'package:flutter/material.dart';

class AdminBookingDetailsPage extends StatelessWidget {
  final Booking booking;
  const AdminBookingDetailsPage({super.key, required this.booking});

  static const _bg = Color(0xFF0B0B18);
  static const _card = Color(0xFF121C30);
  static const _border = Color(0xFF1F2B45);
  static const _iconBg = Color(0xFF1B2742);
  static const _purple = Color(0xFF8B5CF6);
  static const _muted = Color(0xFF8A94A8);
  static const _green = Color(0xFF2EC27E);
  static const _orange = Color(0xFFFFA726);
  static const _red = Color(0xFFFF4D4F);

  bool get _isPending => booking.status == 'Upcoming' && !booking.confirmed;

  String get _statusText {
    if (booking.status == 'Cancelled') return 'Cancelled';
    if (booking.status == 'Completed') return 'Completed';
    return booking.confirmed ? 'Confirmed' : 'Pending';
  }

  Color get _statusColor {
    switch (_statusText) {
      case 'Cancelled':
        return _red;
      case 'Pending':
        return _orange;
      default:
        return _green;
    }
  }

  // update() Firestore me save karta hai aur customer ko notification bhejta hai
  Future<void> _confirm(BuildContext context) async {
    booking.confirmed = true;
    booking.status = 'Upcoming';
    await _save(
      context,
      type: AdminToastType.confirmed,
      title: 'Booking Confirmed',
    );
  }

  Future<void> _reject(BuildContext context) async {
    booking.confirmed = false;
    booking.status = 'Cancelled';
    await _save(
      context,
      type: AdminToastType.cancelled,
      title: 'Booking Rejected',
    );
  }

  Future<void> _save(
    BuildContext context, {
    required AdminToastType type,
    required String title,
  }) async {
    final m = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    final ok = await BookingStore.update(booking);
    nav.pop();

    if (!ok) {
      // Firestore ne write reject kiya: pehle jhoota "confirmed" dikhata tha
      m.showSnackBar(SnackBar(
        backgroundColor: _red,
        duration: const Duration(seconds: 8),
        content: Text('Save nahi hua! Firestore Rules check karo.\n'
            '${BookingStore.lastWriteError}'),
      ));
      return;
    }
    showAdminToast(
      m,
      type: type,
      title: title,
      message: '${booking.title} • ${booking.date}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final parts = b.date.split('•');
    final dateOnly = parts.first.trim();
    final timeOnly = parts.length > 1 ? parts.last.trim() : '-';

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                  ),
                  const Text('Booking Details',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // top card: image + title + status
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: _box(),
                      child: Row(
                        children: [
                          ClipOval(
                            child: Image.asset(
                              b.image,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 48,
                                height: 48,
                                color: _iconBg,
                                child: const Icon(
                                    Icons.cleaning_services_rounded,
                                    color: _purple,
                                    size: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b.title,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text(b.address,
                                    style: const TextStyle(
                                        color: _muted, fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: _statusColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: _statusColor.withAlpha(140)),
                            ),
                            child: Text(_statusText,
                                style: TextStyle(
                                    color: _statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    const Text('Service Details',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: _box(),
                      child: Column(
                        children: [
                          if (b.customerName.isNotEmpty)
                            _row(Icons.person_rounded, 'Customer',
                                b.customerName),
                          _row(Icons.cleaning_services_rounded, 'Service',
                              b.title),
                          _row(Icons.card_giftcard_rounded, 'Package',
                              b.package),
                          _row(Icons.calendar_today_rounded, 'Date',
                              dateOnly),
                          _row(Icons.access_time_rounded, 'Time', timeOnly),
                          _row(Icons.location_on_rounded, 'Address',
                              b.address),
                          _row(Icons.payments_rounded, 'Total Amount',
                              '\$${b.price}',
                              last: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Reject / Confirm (sirf pending par)
            if (_isPending)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: _bg,
                  border: Border(top: BorderSide(color: _border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _reject(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _red,
                          side: const BorderSide(color: _red, width: 1.4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Reject',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _confirm(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _purple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Confirm',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _box() => BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      );

  Widget _row(IconData icon, String label, String value,
      {bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: _border, width: .6)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                color: _iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: _purple, size: 15),
          ),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: _muted, fontSize: 13)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
