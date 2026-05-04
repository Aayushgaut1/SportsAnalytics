import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_state.dart';
import 'dart:ui';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const SettingsScreen({super.key, required this.onLogout});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String notifications = 'Enabled';

  @override
  void initState() {
    super.initState();
    appState.addListener(_update);
  }

  void _update() => setState(() {});

  @override
  void dispose() {
    appState.removeListener(_update);
    super.dispose();
  }

  void _showOptions(BuildContext context, String title, List<String> options, String current, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title.toUpperCase(), style: GoogleFonts.outfit(color: appState.primaryColor, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 20),
              ...options.map((opt) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(opt, style: GoogleFonts.outfit(color: opt == current ? Colors.white : Colors.white38, fontWeight: opt == current ? FontWeight.bold : FontWeight.normal)),
                trailing: opt == current ? Icon(Icons.check_circle, color: appState.primaryColor) : null,
                onTap: () {
                  onSelect(opt);
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.black.withOpacity(0.8),
            title: Text(appState.translate('settings'), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 2)),
            actions: [
              IconButton(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout, color: Colors.redAccent),
              ),
              const SizedBox(width: 10),
            ],
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildProfileCard(context),
                  const SizedBox(height: 30),
                  _buildSection('APPLICATION'),
                  _buildSettingItem(context, Icons.notifications_none, 'Notifications', notifications, () {
                    _showOptions(context, 'Notifications', ['Enabled', 'Disabled', 'Priority Only'], notifications, (v) => setState(() => notifications = v));
                  }),
                  _buildSettingItem(context, Icons.language, 'Language', appState.language, () {
                    _showOptions(context, 'Language', ['English', 'Spanish', 'French', 'Hindi'], appState.language, (v) => appState.setLanguage(v));
                  }),
                  _buildSettingItem(context, Icons.dark_mode, 'Theme', appState.theme, () {
                    _showOptions(context, 'Theme', ['Ultra Dark', 'BoxBox Neon', 'Cyberpunk', 'Classic Dark'], appState.theme, (v) => appState.setTheme(v));
                  }),
                  const SizedBox(height: 30),
                  _buildSection('ACCOUNT'),
                  _buildSettingItem(context, Icons.security, 'Security', 'Strong', () => _showOptions(context, 'Security', ['Standard', 'Strong', 'Enterprise'], 'Strong', (v) {})),
                  _buildSettingItem(context, Icons.help_outline, 'Help & Support', 'v2.4.0', () => _showOptions(context, 'Support', ['Documentation', 'Live Chat', 'Report Bug'], '', (v) {})),
                  const SizedBox(height: 40),
                  _buildLogoutButton(context),
                  const SizedBox(height: 30),
                  Text('Version 2.4.0 (BoxBox Edition)', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 120), // Extra space for nav bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: appState.primaryColor,
            child: const Icon(Icons.person, color: Colors.black, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aayush Gautam', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                Text('aayushgautam801@gmail.com', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit_outlined, color: appState.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: GoogleFonts.outfit(color: appState.primaryColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, String trailing, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.02)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 22),
            const SizedBox(width: 15),
            Expanded(child: Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold))),
            Text(trailing, style: GoogleFonts.outfit(color: appState.primaryColor.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w900)),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right, color: Colors.white10),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.redAccent.withOpacity(0.1), blurRadius: 20, spreadRadius: 0)
        ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.1),
              foregroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.redAccent, width: 2)),
              elevation: 0,
            ),
            onPressed: widget.onLogout,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, size: 20),
                const SizedBox(width: 12),
                Text('LOGOUT SESSION', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
