import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
//  DARK THEME COLORS (baaki app jaise hi)
// ---------------------------------------------------------------------------
const Color _bg = Color(0xFF0D0A22);
const Color _top = Color(0xFF1A1250);
const Color _card = Color(0xFF1A1640);
const Color _border = Color(0xFF2E2763);
const Color _iconBg = Color(0xFF2A2360);
const Color _accent = Color(0xFF9B7DFF);
const Color _primary = Color(0xFF6F4FF2);
const Color _sub = Colors.white60;

// ---- Apni asli contact details yahan daalo ----
const String kSupportPhone = '+971 50 123 4567';
const String kSupportWhatsapp = '+971 50 123 4567';
const String kSupportEmail = 'support@sparkclean.com';

class _Faq {
  const _Faq({required this.q, required this.a});
  final String q;
  final String a;
}

const List<_Faq> _faqs = [
  _Faq(
    q: 'Booking kaise karun?',
    a: 'Home par se service chuno, date aur time select karo, phir package '
        'choose karke Confirm Booking dabao. Booking confirm hote hi aapko '
        'notification mil jayegi.',
  ),
  _Faq(
    q: 'Booking cancel ya reschedule kaise karun?',
    a: 'Profile me My Bookings kholo, Upcoming tab se apni booking select '
        'karo aur cancel ya reschedule ka option use karo. Behtar hai ke '
        'service se kam az kam 4 ghante pehle change karo.',
  ),
  _Faq(
    q: 'Payment kaise hoti hai?',
    a: 'Aap Cash on Service ya Card Payment chun sakte ho. Cash on Service '
        'me cleaning ke baad cleaner ko payment karni hoti hai.',
  ),
  _Faq(
    q: 'Cleaner late ho jaye to?',
    a: 'Aap booking details se ya support team se rabta kar sakte ho. Hum '
        'cleaner ko track karke aapko jald update denge.',
  ),
  _Faq(
    q: 'Cleaning se khush na hon to?',
    a: 'Hamari 100% satisfaction policy hai. Service ke 24 ghante ke andar '
        'support ko batao, hum masla dobara theek karwa denge.',
  ),
  _Faq(
    q: 'Kya mera data mehfooz hai?',
    a: 'Ji haan. Aapki personal information sirf booking aur support ke '
        'liye use hoti hai aur kisi third party ke saath share nahi ki jati.',
  ),
];

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  void _copy(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    final m = ScaffoldMessenger.of(context);
    m.hideCurrentSnackBar();
    m.showSnackBar(SnackBar(
      content: Text('$label copied: $value'),
      backgroundColor: _card,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_top, _bg],
              stops: [0.0, 0.4],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 20, 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const Text(
                        'Help & Support',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // hero banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF3B2A9A), Color(0xFF7A5CF0)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B2A9A).withAlpha(60),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.support_agent_rounded,
                                    color: Colors.white, size: 30),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hum madad ke liye hazir hain',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      '24/7 support, hamesha aapke saath',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 12.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26),

                        const _SectionTitle('Contact Us'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ContactTile(
                                icon: Icons.call_rounded,
                                label: 'Call',
                                onTap: () =>
                                    _copy(context, 'Number', kSupportPhone),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ContactTile(
                                icon: Icons.chat_rounded,
                                label: 'WhatsApp',
                                onTap: () => _copy(
                                    context, 'WhatsApp', kSupportWhatsapp),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ContactTile(
                                icon: Icons.email_rounded,
                                label: 'Email',
                                onTap: () =>
                                    _copy(context, 'Email', kSupportEmail),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),

                        const _SectionTitle('Frequently Asked Questions'),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _border),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                              ),
                              child: Column(
                                children: [
                                  for (int i = 0; i < _faqs.length; i++) ...[
                                    ExpansionTile(
                                      tilePadding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 2),
                                      childrenPadding: const EdgeInsets.fromLTRB(
                                          16, 0, 16, 16),
                                      expandedCrossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      iconColor: _accent,
                                      collapsedIconColor: _sub,
                                      title: Text(
                                        _faqs[i].q,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      children: [
                                        Text(
                                          _faqs[i].a,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13.5,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (i != _faqs.length - 1)
                                      Divider(
                                          height: 1,
                                          color: _border.withAlpha(180)),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),

                        // still need help
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _border),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Abhi bhi madad chahiye?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Hamari team se seedha rabta karo',
                                style: TextStyle(color: _sub, fontSize: 13),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _copy(context, 'Email', kSupportEmail),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                  ),
                                  icon: const Icon(Icons.send_rounded, size: 18),
                                  label: const Text(
                                    'Contact Support',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 19,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 104,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _accent, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
