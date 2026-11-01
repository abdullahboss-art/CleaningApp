import 'package:cleaning/app_colors.dart';
import 'package:cleaning/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_service.dart';

// ---------------------------------------------------------------------------
//  DARK THEME COLORS (login page jaise; sirf is file ke liye)
// ---------------------------------------------------------------------------
const Color _bgTop = Color(0xFF171049);
const Color _bgBottom = Color(0xFF090714);
const Color _field = Color(0xFF121A38);
const Color _fieldBorder = Color(0xFF273261);
const Color _accent = Color(0xFF8E7BFF);
const Color _link = Color(0xFFA78BFF);
const Color _hint = Color(0xFF8C93B5);

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _hidePass = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _goHome() => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );

  void _showError(Object e) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(AuthService.message(e))));

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = await AuthService.instance
          .signUpWithEmail(_nameCtrl.text, _idCtrl.text, _passCtrl.text);
      if (user != null && mounted) _goHome();
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignUp() async {
    setState(() => _loading = true);
    try {
      final user = await AuthService.instance.signInWithGoogle();
      if (user != null && mounted) _goHome();
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ------------------------------- UI -------------------------------
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bgBottom,
        body: Stack(
          children: [
            // dark gradient + upar halki purple chamak
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_bgTop, _bgBottom],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.85),
                    radius: 0.9,
                    colors: [
                      AppColors.primary.withAlpha(70),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Har screen size ke liye: content beech me, chhoti screen / keyboard
            // par scroll hota hai, bari screen par max-width 420 rehti hai.
            SafeArea(
              child: LayoutBuilder(
                builder: (context, box) {
                  final h = box.maxHeight;
                  final compact = h < 760; // is page par fields zyada hain
                  final gap = compact ? 10.0 : 16.0;
                  final logo = (h * 0.09).clamp(52.0, 84.0).toDouble();

                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: h),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 22, vertical: compact ? 12 : 20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // ---- logo + title ----
                                  Image.asset(
                                    'assets/images/Logo.png',
                                    height: logo,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.cleaning_services_rounded,
                                      size: logo * 0.8,
                                      color: _accent,
                                    ),
                                  ),
                                  SizedBox(height: gap),
                                  const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Sign up to get started',
                                    style:
                                        TextStyle(color: _hint, fontSize: 13.5),
                                  ),
                                  SizedBox(height: gap + 6),

                                  // ---- fields ----
                                  _DarkField(
                                    controller: _nameCtrl,
                                    hint: 'Full Name',
                                    icon: Icons.person_outline,
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Enter your name'
                                            : null,
                                  ),
                                  const SizedBox(height: 12),
                                  _DarkField(
                                    controller: _idCtrl,
                                    hint: 'Email or Phone Number',
                                    icon: Icons.mail_outline,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Enter your email or phone'
                                            : null,
                                  ),
                                  const SizedBox(height: 12),
                                  _DarkField(
                                    controller: _passCtrl,
                                    hint: 'Password',
                                    icon: Icons.lock_outline,
                                    obscure: _hidePass,
                                    suffix: IconButton(
                                      icon: Icon(
                                        _hidePass
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: _accent,
                                      ),
                                      onPressed: () => setState(
                                          () => _hidePass = !_hidePass),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.length < 6)
                                            ? 'Password must be at least 6 characters'
                                            : null,
                                  ),
                                  const SizedBox(height: 12),
                                  _DarkField(
                                    controller: _confirmCtrl,
                                    hint: 'Confirm Password',
                                    icon: Icons.lock_outline,
                                    obscure: _hidePass,
                                    validator: (v) => v != _passCtrl.text
                                        ? 'Passwords do not match'
                                        : null,
                                  ),
                                  SizedBox(height: gap + 8),

                                  // ---- sign up ----
                                  _PrimaryButton(
                                    label: 'Sign Up',
                                    loading: _loading,
                                    onTap: _signUp,
                                  ),
                                  SizedBox(height: gap + 4),

                                  // ---- social ----
                                  const Text(
                                    'or continue with',
                                    style:
                                        TextStyle(color: _hint, fontSize: 12.5),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _SocialButton(
                                          label: 'Google',
                                          enabled: !_loading,
                                          icon: Image.asset(
                                            'assets/images/Google_image.png',
                                            height: 22,
                                            errorBuilder: (_, __, ___) =>
                                                const Text(
                                              'G',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          onTap: _googleSignUp,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _SocialButton(
                                          label: 'Apple',
                                          enabled: true,
                                          icon: const Icon(Icons.apple,
                                              size: 26, color: Colors.white),
                                          onTap: () {
                                            // TODO: Apple sign-in
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  // ---- Login link (Google ke bilkul neeche) ----
                                  SizedBox(height: gap + 4),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const Text(
                                        'Already have an account? ',
                                        style: TextStyle(
                                            color: _hint, fontSize: 13.5),
                                      ),
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => Navigator.pop(context),
                                        child: const Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 6),
                                          child: Text(
                                            'Login',
                                            style: TextStyle(
                                              color: _link,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Dark text field (purple icon, rounded)
// ---------------------------------------------------------------------------
class _DarkField extends StatelessWidget {
  const _DarkField({
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
    OutlineInputBorder border(Color c, [double w = 1.2]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      cursorColor: _accent,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _hint, fontSize: 14.5),
        prefixIcon: Icon(icon, color: _accent),
        suffixIcon: suffix,
        filled: true,
        fillColor: _field,
        contentPadding: const EdgeInsets.symmetric(vertical: 17),
        enabledBorder: border(_fieldBorder),
        focusedBorder: border(_accent, 1.6),
        errorBorder: border(const Color(0xFFFF6B6B)),
        focusedErrorBorder: border(const Color(0xFFFF6B6B), 1.6),
        errorStyle: const TextStyle(color: Color(0xFFFF8A8A)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Purple gradient main button
// ---------------------------------------------------------------------------
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: loading ? 0.75 : 1,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8B6CFF), Color(0xFF6F4FF2)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(110),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: loading ? null : onTap,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Dark Google / Apple button
// ---------------------------------------------------------------------------
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: _field,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? onTap : null,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _fieldBorder, width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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