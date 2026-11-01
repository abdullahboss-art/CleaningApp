import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

const adminEmails = [
  'abdullahmusharraf576@gmail.com',
  'admin@gmail.com',
];
// admin@gmail.com + ye password dalne par seedha admin panel
const adminLoginEmail = 'admin@gmail.com';
const adminLoginPassword = '123456';
// -------------------------------------------------

// Gmail ke dots / +tag hata kar compare karta hai
String _norm(String? e) {
  if (e == null) return '';
  final s = e.trim().toLowerCase();
  final at = s.indexOf('@');
  if (at < 0) return s;
  var local = s.substring(0, at);
  final domain = s.substring(at + 1);
  if (domain == 'gmail.com' || domain == 'googlemail.com') {
    local = local.split('+').first.replaceAll('.', '');
    return '$local@gmail.com';
  }
  return s;
}

bool isAdminEmail(String? email) =>
    email != null && adminEmails.map(_norm).contains(_norm(email));

/// User ki email har jagah se nikalta hai
List<String> emailsOf(User? u) {
  if (u == null) return [];
  return [
    if (u.email != null) u.email!,
    for (final p in u.providerData)
      if (p.email != null) p.email!,
  ];
}

bool isAdminUser(User? u) => emailsOf(u).any(isAdminEmail);

// ---------- admin@gmail.com / 123456 login ko yaad rakhna ----------
const _kAdminKey = 'admin_password_login';

Future<void> setAdminSession(bool value) async {
  final p = await SharedPreferences.getInstance();
  await p.setBool(_kAdminKey, value);
}

Future<bool> hasAdminSession() async {
  final p = await SharedPreferences.getInstance();
  return p.getBool(_kAdminKey) ?? false;
}

/// Admin panel ke Logout button par yehi call karo
Future<void> adminLogout() async {
  await setAdminSession(false);
  await FirebaseAuth.instance.signOut();
}