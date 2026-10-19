import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import 'admin_dashboard_tab.dart';
import 'admin_fleet_database_tab.dart';
import 'admin_driver_management_tab.dart';
import 'admin_officer_management_tab.dart';
import 'admin_echallan_management_tab.dart';
import 'admin_incident_review_tab.dart';
import 'admin_analytics_tab.dart';
import 'admin_broadcasts_tab.dart';
import 'admin_settings_tab.dart';
import '../auth/admin_login_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardTab(),
    const AdminFleetDatabaseTab(),
    const AdminDriverManagementTab(),
    const AdminOfficerManagementTab(),
    const AdminEchallanManagementTab(),
    const AdminIncidentReviewTab(),
    const AdminAnalyticsTab(),
    const AdminBroadcastsTab(),
    const AdminSettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            color: AppTheme.blue950, // Matches HQ Dashboard theme
            child: Column(
              children: [
                _buildBrand(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      _buildNavSectionTitle("MAIN"),
                      _buildNavItem(0, "Dashboard", FontAwesomeIcons.chartPie),
                      _buildNavItem(1, "Fleet Database", FontAwesomeIcons.truck),
                      _buildNavItem(2, "Drivers", FontAwesomeIcons.idCard),
                      _buildNavItem(3, "Officers", FontAwesomeIcons.userShield),
                      const SizedBox(height: 12),
                      _buildNavSectionTitle("OPERATIONS"),
                      _buildNavItem(4, "e-Challans", FontAwesomeIcons.fileInvoice),
                      _buildNavItem(5, "Incident Review", FontAwesomeIcons.triangleExclamation, badge: "3"),
                      _buildNavItem(6, "Analytics", FontAwesomeIcons.chartLine),
                      const SizedBox(height: 12),
                      _buildNavSectionTitle("ADMIN"),
                      _buildNavItem(7, "Broadcasts", FontAwesomeIcons.bullhorn),
                      _buildNavItem(8, "Settings", FontAwesomeIcons.gear),
                    ],
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildTopbar(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: constraints.maxWidth > 1100 ? constraints.maxWidth : 1100,
                          child: _screens[_selectedIndex],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Center(child: FaIcon(FontAwesomeIcons.shieldHalved, color: AppTheme.gold, size: 16)),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("IVMS HQ", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
              Text("OPERATIONS CENTER", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildNavSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.3),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String title, dynamic icon, {String? badge}) {
    bool isActive = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: Center(child: FaIcon(icon, size: 14, color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6))),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            if (badge != null) const Spacer(),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.danger, borderRadius: BorderRadius.circular(12)),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [AppTheme.blue600, AppTheme.green700]),
            ),
            child: const Center(child: Text("AD", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Admin User", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              Text("admin@hq.ivms", style: TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTopbar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 250,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border, width: 1.5),
            ),
            child: const Row(
              children: [
                SizedBox(width: 12),
                FaIcon(FontAwesomeIcons.magnifyingGlass, size: 12, color: AppTheme.muted),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search anything...",
                      hintStyle: TextStyle(fontSize: 13, color: AppTheme.muted),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.bell, size: 16, color: Color(0xFF475569)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: "Logout HQ Session",
            icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket, size: 16, color: Color(0xFF475569)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
              );
            },
          )
        ],
      ),
    );
  }
}

