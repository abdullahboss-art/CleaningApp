import 'package:flutter/material.dart';
import '../common.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  static const _methods = [
    ('Credit / Debit Card', Icons.credit_card_rounded),
    ('PayPal', Icons.paypal_rounded),
    ('Apple Pay', Icons.apple_rounded),
    ('Google Pay', Icons.g_mobiledata_rounded),
  ];
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return PurpleScaffold(
      title: 'Payment Method',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 170,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AC.gradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: const Text('VISA',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w900)),
                  ),
                  const Spacer(),
                  const Text('••••  ••••  4242',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            WhiteCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: List.generate(_methods.length, (i) {
                  final m = _methods[i];
                  return Column(
                    children: [
                      RadioListTile<int>(
                        value: i,
                        groupValue: _selected,
                        activeColor: AC.primary,
                        onChanged: (v) => setState(() => _selected = v ?? 0),
                        title: Text(m.$1,
                            style: const TextStyle(
                                color: AC.text,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        secondary: Icon(m.$2, color: AC.primary),
                      ),
                      if (i != _methods.length - 1) const Divider(height: 1),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 22),
            PrimaryButton('Add New Card',
                onTap: () => snack(context, 'Add card jald aayega.')),
          ],
        ),
      ),
    );
  }
}
