import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Purple gradient header with logo, app name and tagline.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, this.height = 285});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryDark, AppColors.primaryLight],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/Logo.png', height: 84),
            const SizedBox(height: 10),
            const Text(
              'SparkClean',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Clean Homes, Brighter Living.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// White sheet with rounded top corners that overlaps the header.
class AuthSheet extends StatelessWidget {
  const AuthSheet({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // ColoredBox = header ke gradient ke aakhri rang (primaryLight) ka background,
    // taaki sheet ke rounded corners ke peeche dark patti na dikhe.
    return ColoredBox(
      color: AppColors.primaryLight,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: child,
      ),
    );
  }
}

/// Rounded text field with a leading icon (matches the design).
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: 1.2),
        );

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.hint),
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: border(AppColors.fieldBorder),
        focusedBorder: border(AppColors.primary),
        errorBorder: border(Colors.redAccent),
        focusedErrorBorder: border(Colors.redAccent),
      ),
    );
  }
}

/// Big purple gradient button.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: AppColors.primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.4, color: Colors.white),
              )
            : Text(label,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

/// "or continue with" + Google / Apple buttons.
class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key, this.onGoogle, this.onApple});
  final VoidCallback? onGoogle;
  final VoidCallback? onApple;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('or continue with',
            style: TextStyle(color: AppColors.hint, fontSize: 13)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                label: 'Google',
                icon: Image.asset('assets/images/Google_image.png', height: 22),
                onTap: onGoogle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _SocialButton(
                label: 'Apple',
                icon: const Icon(Icons.apple, size: 26, color: Colors.black),
                onTap: onApple,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon, this.onTap});
  final String label;
  final Widget icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: AppColors.fieldBorder, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}