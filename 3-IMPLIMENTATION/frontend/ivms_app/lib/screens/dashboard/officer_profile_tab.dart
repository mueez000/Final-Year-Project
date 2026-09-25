import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../role_selection_screen.dart';

class OfficerProfileTab extends StatelessWidget {
  const OfficerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 24, bottom: 40, left: 24, right: 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.blue950, AppTheme.blue800],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildNavIcon(FontAwesomeIcons.qrcode),
                          _buildNavIcon(FontAwesomeIcons.penToSquare),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppTheme.blue600, AppTheme.blue500],
                              ),
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                            ),
                            child: const Center(
                              child: Text("OS", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                            ),
                          ),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppTheme.gold,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.blue950, width: 2),
                            ),
                            child: const Center(child: FaIcon(FontAwesomeIcons.camera, size: 8, color: AppTheme.blue950)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text("Officer Smith", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text("Badge: BDG-99234", style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBadge(FontAwesomeIcons.star, "Senior Officer"),
                          const SizedBox(width: 8),
                          _buildBadge(FontAwesomeIcons.shield, "Zone Commander"),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -35,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 14, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat("Reports", "342"),
                        Container(width: 1, height: 30, color: AppTheme.border),
                        _buildStat("Citations", "1,029"),
                        Container(width: 1, height: 30, color: AppTheme.border),
                        _buildStat("Exp", "5 Yrs"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 45),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text("ACCOUNT SETTINGS", style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.muted, fontSize: 12, letterSpacing: 0.8)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        _buildSettingsTile(FontAwesomeIcons.user, "Personal Information"),
                        const Divider(height: 1, color: AppTheme.border),
                        _buildSettingsTile(FontAwesomeIcons.mapLocationDot, "Zone Assignment"),
                        const Divider(height: 1, color: AppTheme.border),
                        _buildSettingsTile(FontAwesomeIcons.clockRotateLeft, "Patrol History"),
                        const Divider(height: 1, color: AppTheme.border),
                        _buildSettingsTile(FontAwesomeIcons.sliders, "App Settings"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                        (route) => false,
                      );
                    },
                    icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket, size: 16),
                    label: const Text("Log Out"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.danger.withOpacity(0.1),
                      foregroundColor: AppTheme.danger,
                      elevation: 0,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(dynamic icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Center(child: FaIcon(icon, color: Colors.white, size: 14)),
    );
  }

  Widget _buildBadge(dynamic icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          FaIcon(icon, color: AppTheme.gold, size: 10),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: AppTheme.textDark, fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildSettingsTile(dynamic icon, String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: FaIcon(icon, color: AppTheme.muted, size: 16)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textDark)),
      trailing: const FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: AppTheme.muted),
      onTap: () {},
    );
  }
}
