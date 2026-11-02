

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common.dart';

// ---------------------------------------------------------------------------
//  Firebase user helpers (Summary page aur Admin Customers dono yahi use karte hain)
// ---------------------------------------------------------------------------

/// Firebase user ki photo (Google login ho to providerData se bhi uthata hai)
String? userPhotoOf(User? user) {
  var url = user?.photoURL;
  if (url == null || url.isEmpty) {
    for (final p in user?.providerData ?? const <UserInfo>[]) {
      if (p.photoURL != null && p.photoURL!.isNotEmpty) {
        url = p.photoURL;
        break;
      }
    }
  }
  if (url == null || url.isEmpty) return null;
  return url.replaceAll(RegExp(r'=s\d+-c'), '=s200-c');
}

/// Firebase user ka naam (displayName, warna email ka pehla hissa, warna '')
String userNameOf(User? user) {
  final dn = (user?.displayName ?? '').trim();
  if (dn.isNotEmpty) return dn;
  final em = (user?.email ?? '').trim();
  if (em.contains('@')) return em.split('@').first;
  return '';
}

class Service {
  final String title;
  final String subtitle;
  final String shortName; // home screen icon ke neeche
  final String image;
  final int price;
  final IconData icon;
  final Color color;

  const Service({
    required this.title,
    required this.subtitle,
    required this.shortName,
    required this.image,
    required this.price,
    required this.icon,
    required this.color,
  });
}

const List<Service> services = [
  Service(
    title: 'Home Cleaning',
    subtitle: 'Keep your home spotless',
    shortName: 'Regular\nCleaning',
    image: Img.homeCleaning,
    price: 49,
    icon: Icons.home_rounded,
    color: Color(0xFFFF9F43),
  ),
  Service(
    title: 'Deep Cleaning',
    subtitle: 'A deeper clean for better living',
    shortName: 'Deep\nCleaning',
    image: Img.deepCleaning,
    price: 79,
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFF2EC27E),
  ),
  Service(
    title: 'Kitchen Cleaning',
    subtitle: 'Shine your kitchen',
    shortName: 'Kitchen\nCleaning',
    image: Img.kitchenCleaning,
    price: 59,
    icon: Icons.kitchen_rounded,
    color: Color(0xFFFF6B57),
  ),
  Service(
    title: 'Bathroom Cleaning',
    subtitle: 'Fresh & Hygienic',
    shortName: 'Bathroom\nCleaning',
    image: Img.bathroomCleaning,
    price: 39,
    icon: Icons.bathtub_rounded,
    color: Color(0xFF3A8DFF),
  ),
  Service(
    title: 'Move-In/Move-Out',
    subtitle: 'Cleaning Services',
    shortName: 'Move\nCleaning',
    image: Img.moveCleaning,
    price: 129,
    icon: Icons.local_shipping_rounded,
    color: Color(0xFF8E5CF7),
  ),
  Service(
    title: 'Office Cleaning',
    subtitle: 'Professional workspace',
    shortName: 'Office\nCleaning',
    image: Img.officeCleaning,
    price: 99,
    icon: Icons.business_rounded,
    color: Color(0xFF00B8A9),
  ),
];

/// Date & Time page se Confirmed page tak jane wala data.
class BookingInfo {
  final Service service;
  final DateTime date;
  final String time;
  final String package; // Platinum / Diamond / Silver / Premium
  final String address;

  const BookingInfo(
    this.service,
    this.date,
    this.time, {
    this.package = 'Regular',
    this.address = 'Tower A, Flat 1203',
  });
}

// ---------------------------------------------------------------------------
//  BOOKINGS
// ---------------------------------------------------------------------------
class Booking {
  final String title;
  final String image;
  final String package; // Platinum / Diamond / Silver / Premium
  final String address;
  String date; // "Apr 22, 2025 • 11:00 AM"
  final int price;
  String status; // Upcoming / Completed / Cancelled
  bool confirmed; // admin ne confirm kiya? (false = Pending)

  /// Admin ne kab confirm kiya (millisecondsSinceEpoch, 0 = abhi nahi).
  /// Confirm ke 2 minute baad booking khud Completed ho jati hai.
  int confirmedAt;

  /// Firestore document id (khali = sirf local booking, purani/seed)
  String id;

  // Customer info (booking karne wale user ki) - Admin > Customers ke liye
  String customerId;
  String customerName;
  String customerEmail;
  String customerPhone;
  String customerPhoto;

  Booking({
    required this.title,
    required this.image,
    required this.date,
    required this.price,
    required this.status,
    this.package = 'Regular',
    this.address = 'Tower A, Flat 1203',
    this.confirmed = false,
    this.confirmedAt = 0,
    this.id = '',
    this.customerId = '',
    this.customerName = '',
    this.customerEmail = '',
    this.customerPhone = '',
    this.customerPhoto = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
        'package': package,
        'address': address,
        'date': date,
        'price': price,
        'status': status,
        'confirmed': confirmed,
        'confirmedAt': confirmedAt,
        'customerId': customerId,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
        'customerPhoto': customerPhoto,
      };

  // Har field ke liye safe default: koi purani/adhuri booking poori list ko
  // kharab nahi karegi.
  factory Booking.fromJson(Map<String, dynamic> j) {
    String s(String k, [String d = '']) => (j[k] ?? d).toString();
    final status = s('status', 'Upcoming');
    final price = j['price'];

    return Booking(
      title: s('title'),
      image: s('image'),
      package: s('package', 'Regular'),
      address: s('address', 'Tower A, Flat 1203'),
      date: s('date'),
      price: price is num ? price.toInt() : (int.tryParse('$price') ?? 0),
      status: status,
      // purani saved bookings me ye key nahi hoti -> Pending maani jayengi
      confirmed:
          j['confirmed'] is bool ? j['confirmed'] as bool : status == 'Completed',
      confirmedAt: j['confirmedAt'] is num ? (j['confirmedAt'] as num).toInt() : 0,
      id: s('id'),
      customerId: s('customerId'),
      customerName: s('customerName'),
      customerEmail: s('customerEmail'),
      customerPhone: s('customerPhone'),
      customerPhoto: s('customerPhoto'),
    );
  }
}

class BookingStore {
  // Agar purani bookings rakhni hain to 'bookings_v1' hi rehne dein.
  static const _key = 'bookings_v1';

  /// Firestore collection (lazy, taake Firebase init se pehle crash na ho)
  static CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('bookings');

  static List<Booking> _seed() => [
        Booking(
            title: 'Home Cleaning',
            image: Img.homeCleaning,
            package: 'Platinum',
            address: 'Tower A, Flat 1203',
            date: 'Apr 22, 2025 • 11:00 AM',
            price: 49,
            status: 'Upcoming'),
        Booking(
            title: 'Deep Cleaning',
            image: Img.deepCleaning,
            package: 'Diamond',
            address: 'Tower A, Flat 1203',
            date: 'Apr 25, 2025 • 10:00 AM',
            price: 79,
            status: 'Upcoming'),
        Booking(
            title: 'Kitchen Cleaning',
            image: Img.kitchenCleaning,
            package: 'Silver',
            address: 'Tower A, Flat 1203',
            date: 'Apr 21, 2025 • 09:00 AM',
            price: 59,
            status: 'Completed',
            confirmed: true),
      ];

  /// Pehli baar chhute hi saved bookings apne aap load hone lagti hain,
  /// isliye main() me load() call na bhi ho to bhi chalta hai.
  static final ValueNotifier<List<Booking>> items = _create();

  static Future<void>? _loading;
  static bool _dirty = false; // load se pehle koi change hua?

  static ValueNotifier<List<Booking>> _create() {
    final n = ValueNotifier<List<Booking>>(_seed());
    _loading = _loadInto(n);
    return n;
  }

  /// main() mein runApp se pehle call kar sakte hain (zaroori nahi, harm bhi nahi)
  static Future<void> load() {
    final n = items;
    return _loading ?? _loadInto(n);
  }

  static Future<void> _loadInto(ValueNotifier<List<Booking>> n) async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_key);
      if (raw == null || raw.isEmpty) return;

      final loaded = <Booking>[];
      for (final e in (jsonDecode(raw) as List)) {
        try {
          loaded.add(Booking.fromJson(Map<String, dynamic>.from(e as Map)));
        } catch (err) {
          debugPrint('BookingStore: ek booking skip hui: $err');
        }
      }
      debugPrint('BookingStore: saved bookings = ${loaded.length}');
      if (loaded.isEmpty || _dirty) return; // pehle hi kuch badal chuka ho to na chhedo
      n.value = loaded;
      _remember(loaded);
    } catch (e) {
      debugPrint('BookingStore.load error: $e');
    }
  }

  static Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(
          _key, jsonEncode(items.value.map((b) => b.toJson()).toList()));
    } catch (e) {
      debugPrint('BookingStore.save error: $e');
    }
  }

  // -------------------------------------------------------------------------
  //  CUSTOMER KO NOTIFICATION (admin/customer booking badle to)
  //  Har booking ki pichli halat yaad rakhte hain; badle to us booking ke
  //  customer ke account me notification likh dete hain.
  // -------------------------------------------------------------------------
  static final Map<String, String> _lastState = {};

  static String _stateOf(Booking b) =>
      '${b.status}|${b.confirmed}|${b.confirmedAt}|${b.date}';

  /// Admin confirm kare to itne baad booking user ke paas Completed ho jati hai
  static const autoCompleteAfter = Duration(minutes: 2);

  static void _remember(Iterable<Booking> list) {
    for (final b in list) {
      if (b.id.isNotEmpty) _lastState[b.id] = _stateOf(b);
    }
  }

  static void _notifyIfChanged(Booking b) {
    if (b.id.isEmpty || b.customerId.isEmpty) return;
    final now = _stateOf(b);
    final before = _lastState[b.id];
    _lastState[b.id] = now;
    if (before == null || before == now) return;

    final parts = before.split('|');
    final oldStatus = parts[0];
    final oldConfirmed = parts.length > 1 && parts[1] == 'true';
    final oldDate = parts.length > 3 ? parts.sublist(3).join('|') : '';

    if (b.status == 'Cancelled' && oldStatus != 'Cancelled') {
      NotificationStore.add(
        type: 'cancel',
        title: 'Booking Cancelled',
        body: '${b.title} - ${b.date}',
        key: 'ev_${b.id}_cancelled',
        userId: b.customerId,
      );
    } else if (b.status == 'Completed' && oldStatus != 'Completed') {
      NotificationStore.add(
        type: 'tracking',
        title: 'Cleaning Completed',
        body: '${b.title} is now completed.',
        key: 'ev_${b.id}_completed',
        userId: b.customerId,
      );
    } else if (b.confirmed && !oldConfirmed) {
      NotificationStore.add(
        type: 'booking',
        title: 'Booking Confirmed',
        body: '${b.title} - ${b.date} is confirmed.',
        key: 'ev_${b.id}_confirmed',
        userId: b.customerId,
      );
    } else if (b.date != oldDate) {
      NotificationStore.add(
        type: 'reschedule',
        title: 'Booking Rescheduled',
        body: '${b.title} - ${b.date}',
        key: 'ev_${b.id}_date_${b.date}',
        userId: b.customerId,
      );
    }
  }

  // -------------------------------------------------------------------------
  //  FIRESTORE
  // -------------------------------------------------------------------------

  /// Ek booking ko Firestore me likhta hai (id ho to hi)
  static Future<void> _push(Booking b) async {
    if (b.id.isEmpty) return;
    try {
      await _col.doc(b.id).set(b.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore push error: $e');
    }
  }

  /// Admin ke liye: SAB users ki bookings live (id ke sath).
  /// Admin Customers page / Admin Bookings page isi ko StreamBuilder me use karein.
  static Stream<List<Booking>> allStream() {
    return _col.snapshots().map((snap) {
      final docs = snap.docs.toList()
        ..sort((a, b) {
          final ta = a.data()['createdAt'];
          final tb = b.data()['createdAt'];
          if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
          return 0;
        });
      final list = <Booking>[];
      for (final d in docs) {
        try {
          list.add(Booking.fromJson({...d.data(), 'id': d.id}));
        } catch (e) {
          debugPrint('Booking parse error (${d.id}): $e');
        }
      }
      _remember(list);
      return list;
    });
  }

  /// Admin ne kisi booking me change kiya (confirm/cancel/complete/date) to
  /// ye call karo. Customer ko notification bhi isi se jati hai.
  /// (Yahan refresh() nahi chalta, warna purani local copy admin ka change
  /// wapas mita sakti hai.)
  static Future<bool> update(Booking b) async {
    // Confirm hote hi time likh do (2 minute ka timer yahin se shuru hota hai)
    if (b.confirmed && b.status == 'Upcoming') {
      if (b.confirmedAt == 0) {
        b.confirmedAt = DateTime.now().millisecondsSinceEpoch;
      }
    } else if (!b.confirmed) {
      b.confirmedAt = 0;
    }
    _notifyIfChanged(b);
    return _pushChecked(b);
  }

  /// _push jaisa hi, magar nateeja batata hai (true = save ho gaya).
  /// False ka matlab: Firestore ne write reject kiya (aksar Rules / permission).
  static Future<bool> _pushChecked(Booking b) async {
    if (b.id.isEmpty) return false;
    try {
      await _col
          .doc(b.id)
          .set(b.toJson(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));
      return true;
    } on TimeoutException {
      // internet slow/band: write queue me hai, baad me chala jayega
      return true;
    } catch (e) {
      debugPrint('Firestore push error (${b.id}): $e');
      lastWriteError = e.toString();
      return false;
    }
  }

  /// Aakhri write error (admin ko dikhane ke liye)
  static String lastWriteError = '';

  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  /// OPTIONAL: login ke baad ek baar call karo (jaise Home page initState me).
  /// Isse user ki apni bookings Firestore se sync hoti hain, yani admin confirm
  /// kare to user ke phone par bhi status badal jata hai.
  /// Purani local bookings (bina id) wahin rehti hain.
  static void startUserSync() {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    _sub?.cancel();
    try {
      _sub = _col.where('customerId', isEqualTo: u.uid).snapshots().listen(
        (snap) {
          _dirty = true;
          final docs = snap.docs.toList()
            ..sort((a, b) {
              final ta = a.data()['createdAt'];
              final tb = b.data()['createdAt'];
              if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
              return 0;
            });
          final remote = <Booking>[];
          for (final d in docs) {
            try {
              remote.add(Booking.fromJson({...d.data(), 'id': d.id}));
            } catch (e) {
              debugPrint('Booking parse error (${d.id}): $e');
            }
          }
          _remember(remote);
          final localOnly = items.value.where((b) => b.id.isEmpty).toList();
          items.value = [...remote, ...localOnly];
          _save();
        },
        onError: (e) => debugPrint('User sync error: $e'),
      );
    } catch (e) {
      debugPrint('startUserSync error: $e');
    }
  }

  /// Logout par call karo
  static void stopUserSync() {
    _sub?.cancel();
    _sub = null;
  }

  // -------------------------------------------------------------------------
  //  ADD / REFRESH
  // -------------------------------------------------------------------------

  /// Nayi booking: Pending se shuru hoti hai, admin confirm karega
  static void add(Booking b) {
    _dirty = true;
    b.confirmed = false;

    // Login user ka data booking ke sath save karo (Admin > Customers ke liye).
    // Jo cheez already booking me bhari hai usay chhedta nahi.
    final u = FirebaseAuth.instance.currentUser;
    if (u != null) {
      if (b.customerId.isEmpty) b.customerId = u.uid;
      if (b.customerName.isEmpty) b.customerName = userNameOf(u);
      if (b.customerEmail.isEmpty) b.customerEmail = u.email ?? '';
      if (b.customerPhone.isEmpty) b.customerPhone = u.phoneNumber ?? '';
      if (b.customerPhoto.isEmpty) b.customerPhoto = userPhotoOf(u) ?? '';
    }

    // Firestore me bhi save (admin ko live dikhe). Fail ho to bhi booking chalti rahe.
    try {
      final doc = _col.doc();
      b.id = doc.id;
      doc
          .set({...b.toJson(), 'createdAt': FieldValue.serverTimestamp()})
          .catchError((e) => debugPrint('Firestore add error: $e'));
    } catch (e) {
      debugPrint('Firestore add error: $e');
    }

    _remember([b]);
    items.value = [b, ...items.value];
    _save();
    NotificationStore.add(
      type: 'booking',
      title: 'Booking Request Sent',
      body: '${b.title} - ${b.date} (waiting for admin confirmation)',
      key: 'booking_${b.title}_${b.date}',
    );
  }

  /// Status/date/confirmed change ke baad call karo, save bhi karta hai
  static void refresh() {
    _dirty = true;
    // Sirf wahi bookings push hongi jo sach me badli hain. Pehle har booking
    // push hoti thi, to user ki purani (Pending) copy admin ka Confirm
    // overwrite kar deti thi.
    final changed = items.value
        .where((b) => b.id.isNotEmpty && _lastState[b.id] != _stateOf(b))
        .toList();
    for (final b in items.value) {
      _notifyIfChanged(b);
    }
    items.value = [...items.value];
    _save();
    for (final b in changed) {
      _push(b);
    }
  }
}

// ---------------------------------------------------------------------------
//  NOTIFICATIONS
// ---------------------------------------------------------------------------
class AppNotification {
  final String id;
  final String? key; // same event dobara na aaye (dedupe)
  final String type; // booking / confirm / cancel / reschedule / tracking / offer / payment
  final String title;
  final String body;
  final DateTime time;
  bool read;

  AppNotification({
    required this.id,
    this.key,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.read = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'key': key,
        'type': type,
        'title': title,
        'body': body,
        'time': time.toIso8601String(),
        'read': read,
      };

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: (j['id'] ?? DateTime.now().microsecondsSinceEpoch).toString(),
        key: j['key']?.toString(),
        type: (j['type'] ?? 'info').toString(),
        title: (j['title'] ?? '').toString(),
        body: (j['body'] ?? '').toString(),
        time: DateTime.tryParse((j['time'] ?? '').toString()) ?? DateTime.now(),
        read: j['read'] is bool ? j['read'] as bool : false,
      );
}

/// Har user ki notifications uske ACCOUNT me (Firestore: users/{uid}/notifications)
/// save hoti hain. Isliye same user kisi bhi browser / phone / run me login kare,
/// uski notifications wapas aa jati hain. Browser me ek copy (cache) bhi rehti hai
/// taake page foran dikhe. Firestore na chale to bhi app chalti rehti hai.
class NotificationStore {
  static const _prefix = 'notifications_v2_'; // + uid (ya 'guest')

  /// Abhi login user ki notifications
  static final ValueNotifier<List<AppNotification>> items = _create();

  static String? _uid; // abhi ka user (null = login nahi)
  static bool _ready = false;
  static bool _starting = false;
  static Future<void>? _firstLoad;
  static StreamSubscription<User?>? _authSub;
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _remoteSub;
  static final Set<String> _pending = {}; // abhi add hui, Firestore me pahunchni baaki

  static ValueNotifier<List<AppNotification>> _create() {
    final n = ValueNotifier<List<AppNotification>>([]);
    _starting = true;
    _firstLoad = _start(n);
    return n;
  }

  static int get unread => items.value.where((n) => !n.read).length;

  /// main() me runApp se pehle call kar sakte hain (zaroori nahi, harm bhi nahi)
  static Future<void> load() async {
    _ensureStarted();
    await _firstLoad;
  }

  static void _ensureStarted() {
    final n = items;
    if (!_ready && !_starting) {
      _starting = true;
      _firstLoad = _start(n);
    }
  }

  static Future<void> _start(ValueNotifier<List<AppNotification>> n) async {
    try {
      _uid = FirebaseAuth.instance.currentUser?.uid;
      await _switchUser(n, _uid);
      _authSub?.cancel();
      _authSub = FirebaseAuth.instance.authStateChanges().listen((u) {
        if (u?.uid != _uid) {
          _uid = u?.uid;
          _switchUser(n, _uid);
        }
      });
      _ready = true;
    } catch (e) {
      debugPrint('NotificationStore start error: $e');
    } finally {
      _starting = false;
    }
  }

  // ---- user badalne par: us user ki cache dikhao + Firestore se live sync ----
  static String _cacheKey(String? uid) => '$_prefix${uid ?? 'guest'}';

  static Future<List<AppNotification>> _readCache(String? uid) async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_cacheKey(uid));
      if (raw == null || raw.isEmpty) return [];
      final out = <AppNotification>[];
      for (final e in (jsonDecode(raw) as List)) {
        try {
          out.add(AppNotification.fromJson(Map<String, dynamic>.from(e as Map)));
        } catch (_) {}
      }
      return out;
    } catch (e) {
      debugPrint('Notif cache read error: $e');
      return [];
    }
  }

  static Future<void> _saveCache() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_cacheKey(_uid),
          jsonEncode(items.value.map((n) => n.toJson()).toList()));
    } catch (e) {
      debugPrint('Notif save error: $e');
    }
  }

  static CollectionReference<Map<String, dynamic>> _colOf(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications');

  static Future<void> _switchUser(
      ValueNotifier<List<AppNotification>> n, String? uid) async {
    _remoteSub?.cancel();
    _remoteSub = null;
    _pending.clear();

    final cached = await _readCache(uid);
    if (_uid != uid) return; // is dauran user phir badal gaya
    n.value = cached;
    if (uid == null) return;

    try {
      _remoteSub = _colOf(uid).snapshots().listen(
        (snap) {
          if (_uid != uid) return;
          final remote = <AppNotification>[];
          for (final d in snap.docs) {
            try {
              remote.add(AppNotification.fromJson({...d.data(), 'id': d.id}));
            } catch (_) {}
          }
          remote.sort((a, b) => b.time.compareTo(a.time));

          // abhi-abhi add hui (Firestore me pahunchne wali) bhi rakho
          final ids = remote.map((e) => e.id).toSet();
          _pending.removeAll(ids);
          final pendingLocal = n.value
              .where((x) => _pending.contains(x.id) && !ids.contains(x.id))
              .toList();

          n.value = [...pendingLocal, ...remote];
          _saveCache();
        },
        onError: (e) => debugPrint('Notif sync error: $e'),
      );
    } catch (e) {
      debugPrint('Notif sync start error: $e');
    }
  }

  // ---- Firestore likhna (fail ho to sirf print) ----
  static void _push(String uid, AppNotification n) {
    try {
      _colOf(uid)
          .doc(n.id)
          .set(n.toJson(), SetOptions(merge: true))
          .catchError((e) => debugPrint('Notif push error: $e'));
    } catch (e) {
      debugPrint('Notif push error: $e');
    }
  }

  static String _safeId(String key) {
    final s = key.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return s.length > 120 ? s.substring(0, 120) : s;
  }

  /// Nayi notification.
  /// [userId] na do to abhi login user ko jati hai. Admin kisi customer ko
  /// bhejna chahe to uska uid [userId] me do.
  static void add({
    required String type,
    required String title,
    required String body,
    String? key,
    String? userId,
  }) {
    _ensureStarted();
    final target = userId ?? _uid;
    final mine = target == _uid;

    if (mine) {
      // same event dobara na aaye
      if (key != null && items.value.any((n) => n.key == key)) return;
      final now = DateTime.now();
      final dup = items.value.any((n) =>
          n.type == type &&
          n.title == title &&
          n.body == body &&
          now.difference(n.time).inSeconds < 10);
      if (dup) return;
    }

    final note = AppNotification(
      id: key != null
          ? _safeId(key)
          : DateTime.now().microsecondsSinceEpoch.toString(),
      key: key,
      type: type,
      title: title,
      body: body,
      time: DateTime.now(),
    );

    if (mine) {
      _pending.add(note.id);
      items.value = [note, ...items.value];
      _saveCache();
    }
    if (target != null) _push(target, note);
  }

  static void markRead(AppNotification n) {
    if (n.read) return;
    n.read = true;
    items.value = [...items.value];
    _saveCache();
    final uid = _uid;
    if (uid != null) _push(uid, n);
  }

  static void markAllRead() {
    final uid = _uid;
    for (final n in items.value) {
      if (!n.read) {
        n.read = true;
        if (uid != null) _push(uid, n);
      }
    }
    items.value = [...items.value];
    _saveCache();
  }

  static void remove(AppNotification n) {
    items.value = items.value.where((e) => e.id != n.id).toList();
    _saveCache();
    final uid = _uid;
    if (uid != null) {
      try {
        _colOf(uid)
            .doc(n.id)
            .delete()
            .catchError((e) => debugPrint('Notif delete error: $e'));
      } catch (e) {
        debugPrint('Notif delete error: $e');
      }
    }
  }

  static void clear() {
    final uid = _uid;
    final old = items.value;
    items.value = [];
    _saveCache();
    if (uid != null) {
      for (final n in old) {
        try {
          _colOf(uid)
              .doc(n.id)
              .delete()
              .catchError((e) => debugPrint('Notif delete error: $e'));
        } catch (e) {
          debugPrint('Notif delete error: $e');
        }
      }
    }
  }
}

/// Booking ke time user ka 11 digit phone number yahan rakha jata hai
/// (BookingDetailsPage me likha jata hai, BookingConfirmedPage me save hota hai).
class BookingPhone {
  static String value = '';
}
