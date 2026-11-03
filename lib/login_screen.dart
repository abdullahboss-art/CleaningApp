import 'package:cleaning/Admin_Penel/Buttom.dart';
import 'package:cleaning/Admin_Penel/admin_config.dart';
import 'package:cleaning/app_colors.dart';
import 'package:cleaning/main_shell.dart';
import 'package:cleaning/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_service.dart';

// ---------------------------------------------------------------------------
//  DARK THEME COLORS (sirf is file ke liye; Sign Up page par asar nahi)
// ---------------------------------------------------------------------------
const Color _bgTop = Color(0xFF171049);
const Color _bgBottom = Color(0xFF090714);
const Color _field = Color(0xFF121A38);
const Color _fieldBorder = Color(0xFF273261);
const Color _accent = Color(0xFF8E7BFF);
const Color _link = Color(0xFFA78BFF);
const Color _hint = Color(0xFF8C93B5);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _hidePass = true;
  bool _loading = false;

  @override
  void dispose() {
    _idCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // admin ho to AdminShell (bottom nav ke sath), warna user ka MainShell
  void _goNext({required bool admin}) =>
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) => admin ? const HomeShell() : const MainShell()),
        (_) => false,
      );

  void _showError(Object e) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(AuthService.message(e))));

  // Google / email login ke baad: admin hai ya user
  Future<void> _routeAfterLogin(User? user) async {
    final u = user ?? FirebaseAuth.instance.currentUser;
    final admin = isAdminUser(u);
    debugPrint('LOGIN EMAILS: ${emailsOf(u)}  -> admin=$admin');
    await setAdminSession(false); // purana password-admin flag hatao
    if (!mounted) return;
    _goNext(admin: admin);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // admin@gmail.com + 123456 -> seedha admin
    if (_idCtrl.text.trim().toLowerCase() == adminLoginEmail &&
        _passCtrl.text == adminLoginPassword) {
      await FirebaseAuth.instance.signOut(); // purana user session hatao
      await setAdminSession(true); // restart par bhi admin rahe
      if (!mounted) return;
      _goNext(admin: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final user = await AuthService.instance
          .signInWithEmail(_idCtrl.text, _passCtrl.text);
      if (user != null && mounted) await _routeAfterLogin(user);
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleLogin() async {
    setState(() => _loading = true);
    try {
      final user = await AuthService.instance.signInWithGoogle();
      if (user != null && mounted) await _routeAfterLogin(user);
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _idCtrl.text.trim();
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter your email above first.')));
      return;
    }
    try {
      await AuthService.instance.sendPasswordReset(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset email sent.')));
      }
    } catch (e) {
      if (mounted) _showError(e);
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
                  final compact = h < 680; // chhote phones
                  final gap = compact ? 12.0 : 18.0;
                  final logo = (h * 0.12).clamp(60.0, 96.0).toDouble();

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
                                  // ---- logo ----
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
                                    'Welcome Back',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Sign in to your account',
                                    style:
                                        TextStyle(color: _hint, fontSize: 13.5),
                                  ),
                                  SizedBox(height: gap + 8),

                                  // ---- fields ----
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
                                  const SizedBox(height: 14),
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
                                    validator: (v) => (v == null ||
                                            v.length < 6)
                                        ? 'Password must be at least 6 characters'
                                        : null,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _forgotPassword,
                                      child: const Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: _link,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // ---- login ----
                                  _LoginButton(
                                    loading: _loading,
                                    onTap: _login,
                                  ),
                                  SizedBox(height: gap + 6),

                                  // ---- social (sirf Google) ----
                                  const Text(
                                    'or continue with',
                                    style:
                                        TextStyle(color: _hint, fontSize: 12.5),
                                  ),
                                  const SizedBox(height: 14),
                                  _SocialButton(
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
                                    onTap: _googleLogin,
                                  ),

                                  // ---- Sign Up (Google ke bilkul neeche) ----
                                  SizedBox(height: gap + 6),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      const Text(
                                        "Don't have an account? ",
                                        style: TextStyle(
                                            color: _hint, fontSize: 13.5),
                                      ),
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const SignUpScreen()),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Text(
                                            'Sign Up',
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
//  Purple gradient Login button
// ---------------------------------------------------------------------------
class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.loading, required this.onTap});
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
                  : const Text(
                      'Login',
                      style: TextStyle(
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
//  Dark Google button (full width)
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
      child: SizedBox(
        width: double.infinity,
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
                  const SizedBox(width: 10),
                  Text(
                    'Continue with $label',
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
      ),
    );
  }
}
