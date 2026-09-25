import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/map_placeholder.dart';

class DriverDashboardTab extends StatelessWidget {
  const DriverDashboardTab({super.key});

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
                  colors: [AppTheme.blue950, AppTheme.blue800],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Good Morning,", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
                          const Text("John Doe", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                        ],
                      ),
                      Row(
                        children: [
                          _buildIconPill(FontAwesomeIcons.bell, hasDot: true),
                          const SizedBox(width: 12),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppTheme.green700, AppTheme.green500],
                              ),
                              border: Border.all(color: AppTheme.gold, width: 2),
                            ),
                            child: const Center(
                              child: Text("JD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Active Journey Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppTheme.green400,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.green400.withOpacity(0.4),
                                blurRadius: 6,
                                spreadRadius: 3,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Route 42 - Downtown", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                              Text("ETA: 45 mins • 12km left", style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("45", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1)),
                            const Text("km/h", style: TextStyle(color: AppTheme.green400, fontSize: 11, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text("QUICK ACTIONS", style: TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.8)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildActionBtn(FontAwesomeIcons.triangleExclamation, "Report\nIncident", AppTheme.warning)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildActionBtn(FontAwesomeIcons.shieldHeart, "SOS\nEmergency", AppTheme.danger)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildActionBtn(FontAwesomeIcons.headset, "Driver\nSupport", AppTheme.blue600)),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Text("AI STATUS", style: TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.8)),
                  const SizedBox(height: 12),
                  _buildAiStatusCard(),

                  const SizedBox(height: 24),
                  const Text("LIVE MAP", style: TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.8)),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        )
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: const MapPlaceholderWidget(),
                  ),

                  const SizedBox(height: 24),
                  const Text("TODAY'S METRICS", style: TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.8)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard("Safety Score", "98", "/100", FontAwesomeIcons.shieldHalved, AppTheme.green500)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard("Distance", "124", "km", FontAwesomeIcons.route, AppTheme.blue600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard("Violations", "0", "today", FontAwesomeIcons.triangleExclamation, AppTheme.danger)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard("Drive Time", "4.5", "hrs", FontAwesomeIcons.clock, AppTheme.gold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconPill(dynamic icon, {bool hasDot = false}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          FaIcon(icon, color: Colors.white, size: 16),
          if (hasDot)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.danger,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.blue950, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(dynamic icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          FaIcon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.robot, color: AppTheme.blue600, size: 16),
                  const SizedBox(width: 8),
                  const Text("AI Monitoring", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.green500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.green600,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text("LIVE", style: TextStyle(color: AppTheme.green600, fontSize: 10, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAiIndicator(FontAwesomeIcons.eye, "Drowsiness", true),
              _buildAiIndicator(FontAwesomeIcons.userShield, "Seatbelt", true),
              _buildAiIndicator(FontAwesomeIcons.mobileScreen, "Phone", true),
              _buildAiIndicator(FontAwesomeIcons.gaugeHigh, "Speed", false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiIndicator(dynamic icon, String label, bool isOk) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isOk ? AppTheme.green500.withOpacity(0.1) : AppTheme.warning.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: FaIcon(icon, color: isOk ? AppTheme.green600 : AppTheme.warning, size: 18),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.muted),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String unit, dynamic icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: FaIcon(icon, color: color, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: AppTheme.muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(fontSize: 11, color: AppTheme.muted, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

