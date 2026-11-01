import 'package:flutter/material.dart';

enum AdminToastType { confirmed, completed, cancelled, pending }

const Color _toastCard = Color(0xFF121C30);

/// Admin ke status change par acha sa alert dikhata hai.
/// ScaffoldMessengerState isliye liya hai taake page pop hone ke baad bhi chale.
void showAdminToast(
  ScaffoldMessengerState messenger, {
  required AdminToastType type,
  required String title,
  required String message,
}) {
  final Color color;
  final IconData icon;
  switch (type) {
    case AdminToastType.confirmed:
      color = const Color(0xFF2EC27E);
      icon = Icons.check_circle_rounded;
      break;
    case AdminToastType.completed:
      color = const Color(0xFF2EC27E);
      icon = Icons.verified_rounded;
      break;
    case AdminToastType.cancelled:
      color = const Color(0xFFFF4D4F);
      icon = Icons.cancel_rounded;
      break;
    case AdminToastType.pending:
      color = const Color(0xFFFFA726);
      icon = Icons.schedule_rounded;
      break;
  }

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
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
          color: _toastCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(150)),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(60),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(40),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      height: 1.3,
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