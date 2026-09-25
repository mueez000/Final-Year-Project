import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';

class OfficerDashboardTab extends StatelessWidget {
  const OfficerDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.navy950, AppTheme.blue800],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppTheme.blue600, AppTheme.green700],
                              ),
                              border: Border.all(color: AppTheme.gold, width: 2),
                            ),
                            child: const Center(
                              child: Text("O", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Officer", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w500)),
                              const Text("John Smith", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.green500.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.green500.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.green400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text("ON DUTY", style: TextStyle(color: AppTheme.green400, fontSize: 11, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Stats Strip
                  Row(
                    children: [
                      Expanded(child: _buildStatBubble("124", "ACTIVE")),
                      const SizedBox(width: 8),
                      Expanded(child: _buildStatBubble("3", "INCIDENTS")),
                      const SizedBox(width: 8),
                      Expanded(child: _buildStatBubble("12", "ALERTS")),
                      const SizedBox(width: 8),
                      Expanded(child: _buildStatBubble("5", "TICKETS")),
                    ],
                  ),
                ],
              ),
            ),
            
            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text("LIVE ALERTS", style: TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.8)),
                  const SizedBox(height: 12),
                  
                  _buildIncidentCard(
                    icon: FontAwesomeIcons.carBurst,
                    title: "Collision Detected",
                    vehicle: "LHR-1234 (Honda Civic)",
                    location: "Main Boulevard, Gulberg",
                    time: "Just Now",
                    status: "UNRESOLVED",
                    isCritical: true,
                  ),
                  
                  _buildIncidentCard(
                    icon: FontAwesomeIcons.gaugeHigh,
                    title: "Over-speeding Alert",
                    vehicle: "LEA-8822 (Toyota Corolla)",
                    location: "Ring Road, Phase 5",
                    time: "5 mins ago",
                    status: "PENDING",
                    isCritical: false,
                    isWarning: true,
                  ),

                  _buildIncidentCard(
                    icon: FontAwesomeIcons.triangleExclamation,
                    title: "Harsh Braking",
                    vehicle: "XYZ-9999 (Suzuki Cultus)",
                    location: "Ferozepur Road",
                    time: "12 mins ago",
                    status: "LOGGED",
                    isCritical: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBubble(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildIncidentCard({
    required dynamic icon,
    required String title,
    required String vehicle,
    required String location,
    required String time,
    required String status,
    bool isCritical = false,
    bool isWarning = false,
  }) {
    final Color color = isCritical ? AppTheme.danger : (isWarning ? AppTheme.warning : AppTheme.blue600);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: FaIcon(icon, color: color, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.car, color: AppTheme.muted, size: 10),
                          const SizedBox(width: 6),
                          Text(vehicle, style: const TextStyle(color: AppTheme.muted, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.locationDot, color: AppTheme.muted, size: 10),
                          const SizedBox(width: 6),
                          Text(location, style: const TextStyle(color: AppTheme.muted, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(status, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border(top: BorderSide(color: AppTheme.border.withOpacity(0.5))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    FaIcon(FontAwesomeIcons.clock, color: AppTheme.muted, size: 10),
                    const SizedBox(width: 6),
                    Text(time, style: const TextStyle(color: AppTheme.muted, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
                Row(
                  children: [
                    Text("View Details", style: TextStyle(color: AppTheme.blue600, fontSize: 11, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    FaIcon(FontAwesomeIcons.arrowRight, color: AppTheme.blue600, size: 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
