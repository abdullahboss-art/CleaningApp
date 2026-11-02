import 'package:cleaning/app_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const Color _bg = Color(0xFF0B0B18);
const Color _card = Color(0xFF121A38);
const Color _border = Color(0xFF273261);
const Color _accent = Color(0xFF8E7BFF);
const Color _hint = Color(0xFF8C93B5);
const Color _soft = Color(0xFF2A2360);

/// Currency yahan se badlo
const String _cur = 'AED';

// ---------------------------------------------------------------------------
//  Helpers
// ---------------------------------------------------------------------------
String _statusLabel(Booking b) {
  if (b.status == 'Cancelled') return 'Cancelled';
  if (b.status == 'Completed') return 'Completed';
  return b.confirmed ? 'Confirmed' : 'Pending';
}

Color _statusColor(String s) {
  switch (s) {
    case 'Cancelled':
      return const Color(0xFFFF6B6B);
    case 'Completed':
      return const Color(0xFF2EC27E);
    case 'Confirmed':
      return const Color(0xFF4DA3FF);
    default:
      return const Color(0xFFFFA63D);
  }
}

/// Photo URL ko saaf karta hai. Khali / ghalat ho to '' return karta hai.
/// Google ki chhoti photo (=s96-c) ko bari (=s256-c) bana deta hai.
String _cleanPhoto(String raw) {
  final p = raw.trim();
  if (p.isEmpty) return '';
  if (!p.startsWith('http')) return '';
  return p.replaceAll(RegExp(r'=s\d+-c'), '=s256-c');
}

class _Customer {
  _Customer(this.key);

  final String key;
  String name = '';
  String email = '';
  String phone = '';
  String photo = '';
  String address = '';
  final List<Booking> bookings = [];

  String get displayName => name.isEmpty ? 'Guest Customer' : name;

  String get contact {
    if (phone.isNotEmpty) return phone;
    if (email.isNotEmpty) return email;
    return 'No contact info';
  }

  String get initial => displayName.trim().isEmpty
      ? '?'
      : displayName.trim().substring(0, 1).toUpperCase();

  int countWhere(String label) =>
      bookings.where((b) => _statusLabel(b) == label).length;

  int get totalSpent => bookings
      .where((b) => b.status != 'Cancelled')
      .fold<int>(0, (sum, b) => sum + b.price);

  bool matches(String q) =>
      displayName.toLowerCase().contains(q) ||
      email.toLowerCase().contains(q) ||
      phone.toLowerCase().contains(q) ||
      address.toLowerCase().contains(q);
}

/// Saari bookings ko customer ke hisab se group karta hai.
/// Ek hi user (same customerId) ki saari bookings ek hi customer me aati hain.
List<_Customer> _groupCustomers(List<Booking> all) {
  final map = <String, _Customer>{};
  for (final b in all) {
    // purani seed bookings (customer info nahi) skip
    if (b.customerId.isEmpty &&
        b.customerEmail.isEmpty &&
        b.customerName.isEmpty) {
      continue;
    }

    final String key;
    if (b.customerId.isNotEmpty) {
      key = b.customerId;
    } else if (b.customerEmail.isNotEmpty) {
      key = b.customerEmail.toLowerCase();
    } else {
      key = b.customerName.toLowerCase();
    }

    final c = map.putIfAbsent(key, () => _Customer(key));
    c.bookings.add(b);
    if (c.name.isEmpty) c.name = b.customerName;
    if (c.email.isEmpty) c.email = b.customerEmail;
    if (c.phone.isEmpty) c.phone = b.customerPhone;
    // sab bookings me se pehli non-empty photo uthao
    if (_cleanPhoto(c.photo).isEmpty) c.photo = b.customerPhoto;
    if (c.address.isEmpty) c.address = b.address;
  }
  return map.values.toList();
}

// ---------------------------------------------------------------------------
//  Page (customers list)
// ---------------------------------------------------------------------------
class AdminCustomersPage extends StatefulWidget {
  const AdminCustomersPage({super.key});

  @override
  State<AdminCustomersPage> createState() => _AdminCustomersPageState();
}

class _AdminCustomersPageState extends State<AdminCustomersPage> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openDetails(_Customer c) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _CustomerDetailPage(customer: c)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),

              // ---- search ----
              TextField(
                controller: _search,
                onChanged: (v) => setState(() => _query = v),
                cursorColor: _accent,
                style: const TextStyle(color: Colors.white, fontSize: 14.5),
                decoration: InputDecoration(
                  hintText: 'Search customers...',
                  hintStyle: const TextStyle(color: _hint, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: _accent),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, color: _hint),
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                        ),
                  filled: true,
                  fillColor: _card,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _border, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _accent, width: 1.6),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ---- list (Firestore se live, sab users ki bookings) ----
              Expanded(
                child: StreamBuilder<List<Booking>>(
                  stream: BookingStore.allStream(),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Data load nahi hua:\n${snap.error}',
                            textAlign: TextAlign.center,
                            style:
                                const TextStyle(color: _hint, fontSize: 13),
                          ),
                        ),
                      );
                    }
                    if (!snap.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: _accent),
                      );
                    }

                    final all = snap.data!;
                    final customers = _groupCustomers(all);
                    final q = _query.trim().toLowerCase();
                    final list = q.isEmpty
                        ? customers
                        : customers.where((c) => c.matches(q)).toList();

                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people_outline,
                                color: _hint, size: 46),
                            const SizedBox(height: 10),
                            Text(
                              customers.isEmpty
                                  ? 'No customers yet'
                                  : 'No customer found',
                              style: const TextStyle(
                                  color: _hint, fontSize: 14.5),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final c = list[i];
                        return _CustomerTile(
                          customer: c,
                          onTap: () => _openDetails(c),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Avatar
//  Neeche hamesha naam ka harf hota hai, uske upar photo aati hai.
//  Photo load na ho (ya fail ho) to harf dikhta rehta hai.
// ---------------------------------------------------------------------------
class _Avatar extends StatelessWidget {
  const _Avatar({required this.customer, this.radius = 26});

  final _Customer customer;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final inner = radius * 2 - 4; // 2px ring dono taraf
    final photo = _cleanPhoto(customer.photo);

    if (kDebugMode) {
      debugPrint(
          'AVATAR => ${customer.displayName} | raw="${customer.photo}" | used="$photo"');
    }

    final letter = Container(
      width: inner,
      height: inner,
      alignment: Alignment.center,
      color: _soft,
      child: Text(
        customer.initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(color: _accent, shape: BoxShape.circle),
      child: ClipOval(
        child: SizedBox(
          width: inner,
          height: inner,
          child: Stack(
            fit: StackFit.expand,
            children: [
              letter,
              if (photo.isNotEmpty)
                Image.network(
                  photo,
                  key: ValueKey(photo),
                  fit: BoxFit.cover,
                  // Flutter web par Google photo CORS ki wajah se fail hoti
                  // hai; yeh <img> tag se load karta hai (Flutter 3.22+).
                  webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                  frameBuilder: (context, child, frame, sync) {
                    if (sync || frame != null) return child;
                    return const SizedBox.shrink();
                  },
                  errorBuilder: (context, error, stackTrace) {
                    if (kDebugMode) {
                      debugPrint('AVATAR ERROR => $photo | $error');
                    }
                    return const SizedBox.shrink();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Customer tile
// ---------------------------------------------------------------------------
class _CustomerTile extends StatelessWidget {
  const _CustomerTile({required this.customer, required this.onTap});

  final _Customer customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = customer.bookings.length;
    return Material(
      color: _card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border, width: 1.2),
          ),
          child: Row(
            children: [
              _Avatar(customer: customer),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      customer.contact,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _hint, fontSize: 12.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customer.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _accent, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _accent.withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      n == 1 ? '1 booking' : '$n bookings',
                      style: const TextStyle(
                        color: _accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.chevron_right, color: _hint, size: 22),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  CUSTOMER DETAIL PAGE (tile par click karne par khulta hai)
// ---------------------------------------------------------------------------
class _CustomerDetailPage extends StatelessWidget {
  const _CustomerDetailPage({required this.customer});

  final _Customer customer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: StreamBuilder<List<Booking>>(
          stream: BookingStore.allStream(),
          builder: (context, snap) {
            final all = snap.data ?? const <Booking>[];

            // live data: isi customer ko dobara dhundo
            _Customer c = customer;
            for (final g in _groupCustomers(all)) {
              if (g.key == customer.key) {
                c = g;
                break;
              }
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                // ---- top bar ----
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Customer Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ---- profile card ----
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border, width: 1.2),
                  ),
                  child: Column(
                    children: [
                      _Avatar(customer: c, radius: 40),
                      const SizedBox(height: 12),
                      Text(
                        c.displayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: _border, height: 1),
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: c.phone,
                      ),
                      _InfoRow(
                        icon: Icons.mail_outline,
                        label: 'Email',
                        value: c.email,
                      ),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: c.address,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ---- stats ----
                Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        label: 'Total',
                        value: '${c.bookings.length}',
                        color: _accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatBox(
                        label: 'Pending',
                        value: '${c.countWhere('Pending')}',
                        color: _statusColor('Pending'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatBox(
                        label: 'Confirmed',
                        value: '${c.countWhere('Confirmed')}',
                        color: _statusColor('Confirmed'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        label: 'Completed',
                        value: '${c.countWhere('Completed')}',
                        color: _statusColor('Completed'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatBox(
                        label: 'Cancelled',
                        value: '${c.countWhere('Cancelled')}',
                        color: _statusColor('Cancelled'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatBox(
                        label: 'Total Spent',
                        value: '$_cur ${c.totalSpent}',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ---- bookings ----
                const Text(
                  'Bookings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                if (c.bookings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No bookings',
                        style: TextStyle(color: _hint, fontSize: 14),
                      ),
                    ),
                  )
                else
                  for (final b in c.bookings) ...[
                    _BookingTile(booking: b),
                    const SizedBox(height: 10),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Detail page widgets
// ---------------------------------------------------------------------------
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final has = value.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _accent.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _accent, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: _hint, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  has ? value : 'Not provided',
                  style: TextStyle(
                    color: has ? Colors.white : _hint,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 1.2),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: _hint, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final label = _statusLabel(b);
    final color = _statusColor(label);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _accent.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cleaning_services_rounded,
              color: _accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  b.package,
                  style: const TextStyle(color: _accent, fontSize: 12.5),
                ),
                const SizedBox(height: 2),
                Text(
                  b.date,
                  style: const TextStyle(color: _hint, fontSize: 12),
                ),
                if (b.customerPhone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 12.5, color: _hint),
                      const SizedBox(width: 4),
                      Text(
                        b.customerPhone,
                        style: const TextStyle(color: _hint, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withAlpha(36),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withAlpha(150)),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$_cur ${b.price}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
