import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =====================================================
// NAYA ADMIN BANANA HO TO SIRF YAHAN EMAIL ADD KARO
// (lowercase me likho, aur har email ke baad comma lagao)
// =====================================================
const superAdminEmails = [
  'abdullahmusharraf576@gmail.com',
  'admin@gmail.com',
  'saadvmi612@gmail.com',
  "saadalrmanadvertising@gmail.com"
  // 'naya.banda@gmail.com',
];

const adminLoginEmail = 'admin@gmail.com';
const adminLoginPassword = '123456';

String _norm(String? e) => (e ?? '').trim().toLowerCase();

/// User ki email har jagah se nikalta hai
List<String> emailsOf(User? u) {
  if (u == null) return [];
  return [
    if (u.email != null) u.email!,
    for (final p in u.providerData)
      if (p.email != null) p.email!,
  ].map(_norm).toSet().toList();
}

bool isSuperAdminUser(User? u) =>
    emailsOf(u).any((e) => superAdminEmails.map(_norm).contains(e));

final _adminsRef = FirebaseFirestore.instance.collection('admins');

/// Admin check: pehle list me, phir Firestore `admins` collection me
/// NOTE: ye Future hai, isliye use karte waqt `await` lagana hai
Future<bool> isAdminUser(User? u) async {
  if (u == null) return false;
  if (isSuperAdminUser(u)) return true;
  for (final e in emailsOf(u)) {
    final doc = await _adminsRef.doc(e).get();
    if (doc.exists) return true;
  }
  return false;
}

/// App ke andar se naya admin banao
Future<void> addAdmin(String email) async {
  final e = _norm(email);
  if (e.isEmpty || !e.contains('@')) throw Exception('Invalid email');
  await _adminsRef.doc(e).set({
    'email': e,
    'addedBy': FirebaseAuth.instance.currentUser?.email,
    'addedAt': FieldValue.serverTimestamp(),
  });
}

/// Admin hatao (super admin ko nahi hata sakte)
Future<void> removeAdmin(String email) async {
  final e = _norm(email);
  if (superAdminEmails.map(_norm).contains(e)) {
    throw Exception('Super admin ko remove nahi kar sakte');
  }
  await _adminsRef.doc(e).delete();
}

/// Admins ki list (Manage Admins screen ke liye)
Stream<List<String>> adminsStream() =>
    _adminsRef.snapshots().map((s) => s.docs.map((d) => d.id).toList());

// ---------- admin@gmail.com / 123456 login yaad rakhna ----------
const _kAdminKey = 'admin_password_login';

Future<void> setAdminSession(bool v) async =>
    (await SharedPreferences.getInstance()).setBool(_kAdminKey, v);

Future<bool> hasAdminSession() async =>
    (await SharedPreferences.getInstance()).getBool(_kAdminKey) ?? false;

/// Admin panel ke Logout button par yehi call karo
Future<void> adminLogout() async {
  await setAdminSession(false);
  await FirebaseAuth.instance.signOut();
}
