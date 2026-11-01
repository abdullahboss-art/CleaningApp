import 'package:flutter/material.dart';
import '../common.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _dark = true;

  @override
  Widget build(BuildContext context) {
    void soon() => snack(context, 'Jald aayega.');

    return PurpleScaffold(
      title: 'Settings',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WhiteCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                MenuTile(
                    icon: Icons.person_rounded,
                    title: 'Account Settings',
                    onTap: soon),
                const Divider(height: 1),
                MenuTile(
                    icon: Icons.lock_rounded,
                    title: 'Privacy & Security',
                    onTap: soon),
                const Divider(height: 1),
                MenuTile(
                    icon: Icons.notifications_rounded,
                    title: 'Notifications',
                    onTap: soon),
                const Divider(height: 1),
                MenuTile(
                    icon: Icons.language_rounded,
                    title: 'Language',
                    trailingText: 'English',
                    onTap: soon),
                const Divider(height: 1),
                MenuTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: _dark,
                    activeColor: AC.primary,
                    onChanged: (v) => setState(() => _dark = v),
                  ),
                ),
                const Divider(height: 1),
                MenuTile(
                    icon: Icons.info_rounded,
                    title: 'About App',
                    onTap: soon),
                const Divider(height: 1),
                MenuTile(
                    icon: Icons.description_rounded,
                    title: 'Terms & Conditions',
                    onTap: soon),
                const Divider(height: 1),
                MenuTile(
                    icon: Icons.mail_rounded,
                    title: 'Contact Us',
                    onTap: soon),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
