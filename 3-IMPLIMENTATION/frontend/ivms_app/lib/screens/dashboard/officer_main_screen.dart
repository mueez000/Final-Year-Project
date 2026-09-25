import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'officer_dashboard_tab.dart';
import 'officer_field_report_tab.dart';
import 'officer_map_tab.dart';
import 'officer_profile_tab.dart';

class OfficerMainScreen extends StatefulWidget {
  const OfficerMainScreen({super.key});

  @override
  State<OfficerMainScreen> createState() => _OfficerMainScreenState();
}

class _OfficerMainScreenState extends State<OfficerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const OfficerDashboardTab(),
    const OfficerMapTab(),
    const OfficerFieldReportTab(),
    const OfficerProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.blue600,
            unselectedItemColor: AppTheme.muted,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map),
                label: 'Patrol Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.edit_document),
                activeIcon: Icon(Icons.edit_document),
                label: 'Field Report',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
