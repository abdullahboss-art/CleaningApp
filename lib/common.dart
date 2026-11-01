import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// COLORS
// -----------------------------------------------------------------------------
class AC {
  static const primary = Color(0xFF3A1FD6);
  static const dark = Color(0xFF1B0F5E);
  static const bg = Color(0xFFF4F1FF);
  static const text = Color(0xFF1B1448);
  static const grey = Color(0xFF7C7A92);
  static const border = Color(0xFFE0DBF7);
  static const green = Color(0xFF2EC27E);
  static const red = Color(0xFFE5484D);
  static const gradient = LinearGradient(
    colors: [Color(0xFF1B0F5E), Color(0xFF4B2BE8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// -----------------------------------------------------------------------------
// ROUTES
// -----------------------------------------------------------------------------
class Routes {
  static const login = '/login_page';
  static const signup = '/signup';
  static const main = '/main'; // arguments: int (tab index) - optional
  static const search = '/search';
  static const booking = '/booking'; // arguments: Service
  static const confirmed = '/confirmed'; // arguments: BookingInfo
  static const dashboard = '/dashboard';
  static const settings = '/settings';
  static const payment = '/payment';
}

// -----------------------------------------------------------------------------
// IMAGE PATHS  (inko assets/images/ mein rakhna hai)
// -----------------------------------------------------------------------------
class Img {
  static const logo = 'assets/images/sparkclean_logo.png';
  static const google = 'assets/images/google.png';
  static const homeBanner = 'assets/images/home_banner.png';
  static const homeCleaning = 'assets/images/home_cleaning.png';
  static const deepCleaning = 'assets/images/deep_cleaning.png';
  static const kitchenCleaning = 'assets/images/kitchen_cleaning.png';
  static const bathroomCleaning = 'assets/images/bathroom_cleaning.png';
  static const moveCleaning = 'assets/images/move_cleaning.png';
  static const officeCleaning = 'assets/images/office_cleaning.png';
  static const user = 'assets/images/user_avatar.png';
}

class AppImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;
  final IconData fallback;

  const AppImage(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.fallback = Icons.cleaning_services_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: AC.primary.withAlpha(40),
          child: Icon(fallback, color: AC.primary),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPERS
// -----------------------------------------------------------------------------
String fmtDate(DateTime d) {
  const m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${m[d.month - 1]} ${d.day}, ${d.year}';
}

void snack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));
}

// -----------------------------------------------------------------------------
// WIDGETS
// -----------------------------------------------------------------------------
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool outlined;
  final Color? color;

  const PrimaryButton(
    this.label, {
    super.key,
    this.onTap,
    this.outlined = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AC.primary;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: outlined
          ? OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: c),
                shape: shape,
              ),
              child: Text(label,
                  style: TextStyle(color: c, fontWeight: FontWeight.w700)),
            )
          : ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: c,
                elevation: 0,
                shape: shape,
              ),
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
    );
  }
}

class AppField extends StatefulWidget {
  final String hint;
  final IconData icon;
  final bool password;
  final bool readOnly;
  final TextInputType? keyboard;
  final TextEditingController? controller;
  final VoidCallback? onTap;

  const AppField({
    super.key,
    required this.hint,
    required this.icon,
    this.password = false,
    this.readOnly = false,
    this.keyboard,
    this.controller,
    this.onTap,
  });

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  bool _hide = true;

  OutlineInputBorder _b(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c),
      );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.password && _hide,
      keyboardType: widget.keyboard,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      style: const TextStyle(color: AC.text),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(color: AC.grey, fontSize: 14),
        prefixIcon: Icon(widget.icon, color: AC.primary, size: 20),
        suffixIcon: widget.password
            ? IconButton(
                icon: Icon(
                  _hide
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AC.grey,
                  size: 20,
                ),
                onPressed: () => setState(() => _hide = !_hide),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: _b(AC.border),
        enabledBorder: _b(AC.border),
        focusedBorder: _b(AC.primary),
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback? onTap;

  const SocialButton({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AC.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: AC.text, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Login / Sign Up ka common background: purple upar logo, neeche white card.
class AuthShell extends StatelessWidget {
  final Widget card;
  const AuthShell({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AC.gradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                AppImage(Img.logo,
                    height: 80, width: 80, fit: BoxFit.contain, radius: 16),
                const SizedBox(height: 8),
                const Text('SparkClean',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800)),
                const Text('Clean Homes. Brighter Living.',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: h * 0.62),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  decoration: const BoxDecoration(
                    color: AC.bg,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: card,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Andar ke pages ka common layout: purple app bar + rounded light body.
class PurpleScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showBack;
  final List<Widget>? actions;
  final Widget? bottom;

  const PurpleScaffold({
    super.key,
    required this.title,
    required this.child,
    this.showBack = true,
    this.actions,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.dark,
      appBar: AppBar(
        backgroundColor: AC.dark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: showBack,
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        actions: actions,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AC.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
      bottomNavigationBar: bottom,
    );
  }
}

class WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const WhiteCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AC.border),
      ),
      child: child,
    );
  }
}

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final Widget? trailing;
  final VoidCallback? onTap;

  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailingText,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AC.primary),
      title: Text(title,
          style: const TextStyle(
              color: AC.text, fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: trailing ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingText != null)
                Text(trailingText!,
                    style: const TextStyle(color: AC.grey, fontSize: 12)),
              const Icon(Icons.chevron_right_rounded, color: AC.grey),
            ],
          ),
    );
  }
}
