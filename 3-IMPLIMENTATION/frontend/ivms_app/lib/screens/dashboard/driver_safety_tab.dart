import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ai_placeholder.dart';

class DriverSafetyTab extends StatelessWidget {
  const DriverSafetyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Your Performance", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                          Text("Safety Profile", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
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
                            FaIcon(FontAwesomeIcons.trophy, color: AppTheme.gold, size: 10),
                            const SizedBox(width: 6),
                            const Text("TOP 5%", style: TextStyle(color: AppTheme.gold, fontSize: 11, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Huge Safety Score Circle
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CircularProgressIndicator(
                          value: 0.98,
                          strokeWidth: 12,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          color: AppTheme.green400,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("98", style: TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w900, height: 1)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.green500.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text("EXCELLENT", style: TextStyle(color: AppTheme.green400, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMiniStat("TOTAL TRIPS", "142"),
                      Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
                      _buildMiniStat("VIOLATIONS", "0"),
                      Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
                      _buildMiniStat("ECO SCORE", "A+"),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text("AI BEHAVIOR ANALYSIS", style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.muted, fontSize: 12, letterSpacing: 0.8)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: const AIPlaceholderWidget(title: "Behavior Analysis Model"),
                  ),
                  const SizedBox(height: 24),
                  const Text("RECENT EVENTS", style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.muted, fontSize: 12, letterSpacing: 0.8)),
                  const SizedBox(height: 12),
                  _buildEventItem("Harsh Braking Avoided", "Excellent defensive driving.", "Today, 10:42 AM", FontAwesomeIcons.shieldHeart, AppTheme.green500),
                  _buildEventItem("Speed Limit Exceeded", "Exceeded limit by 5 km/h.", "Yesterday, 2:15 PM", FontAwesomeIcons.gaugeHigh, AppTheme.warning),
                  _buildEventItem("Perfect Trip Logged", "0 violations across 45km.", "May 12, 2026", FontAwesomeIcons.star, AppTheme.gold),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildEventItem(String title, String desc, String time, dynamic icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Center(child: FaIcon(icon, color: color, size: 18)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
            const SizedBox(height: 4),
            Row(
              children: [
                FaIcon(FontAwesomeIcons.clock, size: 10, color: AppTheme.muted),
                const SizedBox(width: 4),
                Text(time, style: const TextStyle(fontSize: 10, color: AppTheme.muted, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
