import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User ki chhoti settings (phone, address, notification switches, default
/// payment). Har user ke liye alag save hoti hain (uid ke saath).
class UserPrefs {
  UserPrefs._();
  static final UserPrefs instance = UserPrefs._();

  final ValueNotifier<String> phone = ValueNotifier('');
  final ValueNotifier<String> tower = ValueNotifier('');
  final ValueNotifier<String> flat = ValueNotifier('');
  // "Flat 1203, Tower A" jaisa bana hua address (Home par dikhane ke liye)
  final ValueNotifier<String> address = ValueNotifier('');
  final ValueNotifier<bool> notifBooking = ValueNotifier(true);
  final ValueNotifier<bool> notifOffers = ValueNotifier(true);
  // 'cash' ya 'card'
  final ValueNotifier<String> defaultPayment = ValueNotifier('cash');

  String? _loadedFor;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? 'guest';
  String _k(String key) => '${_uid}_$key';

  Future<void> load() async {
    final uid = _uid;
    if (_loadedFor == uid) return;
    final sp = await SharedPreferences.getInstance();
    String k(String key) => '${uid}_$key';
    phone.value = sp.getString(k('phone')) ?? '';
    tower.value = sp.getString(k('tower')) ?? '';
    flat.value = sp.getString(k('flat')) ?? '';
    notifBooking.value = sp.getBool(k('notif_booking')) ?? true;
    notifOffers.value = sp.getBool(k('notif_offers')) ?? true;
    defaultPayment.value = sp.getString(k('default_payment')) ?? 'cash';
    _loadedFor = uid;
    _refreshAddress();
  }

  void _refreshAddress() {
    final parts = <String>[];
    if (flat.value.trim().isNotEmpty) parts.add('Flat ${flat.value.trim()}');
    if (tower.value.trim().isNotEmpty) parts.add(tower.value.trim());
    address.value = parts.join(', ');
  }

  Future<void> setDetails({
    required String phone,
    required String tower,
    required String flat,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_k('phone'), phone);
    await sp.setString(_k('tower'), tower);
    await sp.setString(_k('flat'), flat);
    this.phone.value = phone;
    this.tower.value = tower;
    this.flat.value = flat;
    _refreshAddress();
  }

  Future<void> setNotifBooking(bool v) async {
    notifBooking.value = v;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_k('notif_booking'), v);
  }

  Future<void> setNotifOffers(bool v) async {
    notifOffers.value = v;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_k('notif_offers'), v);
  }

  Future<void> setDefaultPayment(String v) async {
    defaultPayment.value = v;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_k('default_payment'), v);
  }

  /// Account delete hone par saara saved data saaf.
  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    for (final key in [
      'phone',
      'tower',
      'flat',
      'notif_booking',
      'notif_offers',
      'default_payment',
    ]) {
      await sp.remove(_k(key));
    }
    phone.value = '';
    tower.value = '';
    flat.value = '';
    notifBooking.value = true;
    notifOffers.value = true;
    defaultPayment.value = 'cash';
    _loadedFor = null;
    _refreshAddress();
  }
}
