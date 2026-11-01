import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dark theme colors (home page wali theme)
class DC {
  DC._();
  static const Color bg = Color(0xFF0D0A22);
  static const Color headerTop = Color(0xFF241A5E);
  static const Color card = Color(0xFF1A1640);
  static const Color border = Color(0xFF2E2763);
  static const Color iconBg = Color(0xFF2A2360);
  static const Color text = Colors.white;
  static const Color sub = Colors.white60;
  static const Color accent = Color(0xFF9B7DFF);
  static const Color primary = Color(0xFF7A5CF0);
  static const Color red = Color(0xFFFF6B6B);
  static const Color green = Color(0xFF3DDC84);
}

BoxDecoration darkCardDecoration({double radius = 20}) => BoxDecoration(
      color: DC.card,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: DC.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(90),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );

/// Purple header + dark rounded sheet (PurpleScaffold ki jagah)
class DarkScaffold extends StatelessWidget {
  const DarkScaffold({
    super.key,
    required this.title,
    required this.child,
    this.showBack = true,
    this.actions,
  });

  final String title;
  final Widget child;
  final bool showBack;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final acts = actions ?? const <Widget>[];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: DC.bg,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [DC.headerTop, DC.bg],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                IconTheme(
                  data: const IconThemeData(color: Colors.white),
                  child: IconButtonTheme(
                    data: IconButtonThemeData(
                      style: IconButton.styleFrom(
                          foregroundColor: Colors.white),
                    ),
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        children: [
                          if (showBack)
                            IconButton(
                              onPressed: () =>
                                  Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.arrow_back_rounded,
                                  size: 26),
                            )
                          else
                            const SizedBox(width: 48),
                          Expanded(
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (acts.isEmpty)
                            const SizedBox(width: 48)
                          else
                            ...acts,
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: DC.bg,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(28)),
                      child: child,
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
}

/// WhiteCard ki jagah dark card
class DarkCard extends StatelessWidget {
  const DarkCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: darkCardDecoration(),
      child: child,
    );
  }
}

/// MenuTile ki jagah
class DarkMenuTile extends StatelessWidget {
  const DarkMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DC.iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: DC.accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: DC.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailingText != null) ...[
                Text(trailingText!,
                    style: const TextStyle(color: DC.sub, fontSize: 13)),
                const SizedBox(width: 6),
              ],
              const Icon(Icons.chevron_right_rounded, color: DC.sub),
            ],
          ),
        ),
      ),
    );
  }
}

/// PrimaryButton ki jagah
class DarkButton extends StatelessWidget {
  const DarkButton(this.label, {super.key, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: DC.primary,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: DC.primary.withAlpha(100),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}