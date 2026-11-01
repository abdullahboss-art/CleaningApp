import 'package:flutter/material.dart';
import '../app_data.dart';
import '../common.dart';

class ServiceSearchPage extends StatefulWidget {
  const ServiceSearchPage({super.key});

  @override
  State<ServiceSearchPage> createState() => _ServiceSearchPageState();
}

class _ServiceSearchPageState extends State<ServiceSearchPage> {
  final _ctrl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = services
        .where((s) =>
            s.title.toLowerCase().contains(_q.toLowerCase()) ||
            s.subtitle.toLowerCase().contains(_q.toLowerCase()))
        .toList();

    return PurpleScaffold(
      title: 'Search Services',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _ctrl,
              onChanged: (v) => setState(() => _q = v),
              decoration: InputDecoration(
                hintText: 'Search services...',
                hintStyle: const TextStyle(color: AC.grey, fontSize: 14),
                prefixIcon:
                    const Icon(Icons.search_rounded, color: AC.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AC.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AC.border),
                ),
              ),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(
                    child: Text('Koi service nahi mili.',
                        style: TextStyle(color: AC.grey)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final s = list[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.pushNamed(
                            context, Routes.booking,
                            arguments: s),
                        child: WhiteCard(
                          child: Row(
                            children: [
                              AppImage(s.image,
                                  width: 56, height: 56, radius: 12),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.title,
                                        style: const TextStyle(
                                            color: AC.text,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 3),
                                    Text(s.subtitle,
                                        style: const TextStyle(
                                            color: AC.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  color: AC.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
