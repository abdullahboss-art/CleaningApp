import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Admin alert ke types. (Purane code me jo 4 types the wahi hain,
/// upar se 3 extra diye hain taake aage kaam aayein.)
enum AdminToastType {
  pending,
  confirmed,
  completed,
  cancelled,
  rescheduled,
  info,
  error,
}

const Color _kCard = Color(0xFF121C30);
const Color _kGreen = Color(0xFF2EC27E);
const Color _kOrange = Color(0xFFFFA726);
const Color _kRed = Color(0xFFFF4D4F);
const Color _kBlue = Color(0xFF4DA3FF);
const Color _kPurple = Color(0xFF8B5CF6);

Color _colorOf(AdminToastType t) {
  switch (t) {
    case AdminToastType.confirmed:
    case AdminToastType.completed:
      return _kGreen;
    case AdminToastType.pending:
      return _kOrange;
    case AdminToastType.cancelled:
    case AdminToastType.error:
      return _kRed;
    case AdminToastType.rescheduled:
      return _kPurple;
    case AdminToastType.info:
      return _kBlue;
  }
}

IconData _iconOf(AdminToastType t) {
  switch (t) {
    case AdminToastType.confirmed:
      return Icons.check_circle_rounded;
    case AdminToastType.completed:
      return Icons.verified_rounded;
    case AdminToastType.pending:
      return Icons.hourglass_top_rounded;
    case AdminToastType.cancelled:
      return Icons.cancel_rounded;
    case AdminToastType.rescheduled:
      return Icons.event_repeat_rounded;
    case AdminToastType.error:
      return Icons.error_rounded;
    case AdminToastType.info:
      return Icons.info_rounded;
  }
}

/// Neeche se upar slide hone wala khoobsurat alert.
/// Pehle jaisa hi call hota hai:
///   showAdminToast(messenger, type: ..., title: ..., message: ...);
void showAdminToast(
  ScaffoldMessengerState messenger, {
  required AdminToastType type,
  required String title,
  required String message,
  Duration duration = const Duration(milliseconds: 3200),
}) {
  HapticFeedback.mediumImpact();
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 18),
      duration: duration,
      content: _ToastCard(
        type: type,
        title: title,
        message: message,
        duration: duration,
      ),
    ),
  );
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({
    required this.type,
    required this.title,
    required this.message,
    required this.duration,
  });

  final AdminToastType type;
  final String title;
  final String message;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final c = _colorOf(type);

    // 1) poora card neeche se upar uthta hai (halka bounce ke sath) + fade in
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Transform.translate(
        offset: Offset(0, 60 * (1 - v)),
        child: Opacity(opacity: v.clamp(0.0, 1.0), child: child),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.withAlpha(140), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: c.withAlpha(70),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Row(
                  children: [
                    // 2) icon pop (elastic) hota hai
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, s, child) =>
                          Transform.scale(scale: s, child: child),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.withAlpha(38),
                          border: Border.all(color: c.withAlpha(130)),
                        ),
                        child: Icon(_iconOf(type), color: c, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
              // 3) neeche patli line jo dheere dheere khatam hoti hai
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 1, end: 0),
                duration: duration,
                curve: Curves.linear,
                builder: (context, v, _) => Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: v,
                    child: Container(height: 3, color: c),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}