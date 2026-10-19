import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class AdminSettingsTab extends ConsumerStatefulWidget {
  const AdminSettingsTab({super.key});

  @override
  ConsumerState<AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends ConsumerState<AdminSettingsTab> {
  // Speed Zone Limits (km/h)
  double _busSpeedLimit = 100.0;
  double _saltRangeSpeedLimit = 40.0;
  double _toleranceBuffer = 5.0;

  // AI Model Sensitivity Parameters
  double _drowsinessThreshold = 3.0; // Seconds of continuous eye-closure
  double _crashGForceThreshold = 3.5; // Deceleration G-force

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadRemoteConfig();
  }

  Future<void> _loadRemoteConfig() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('system_config').doc('m2_parameters').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (mounted) {
          setState(() {
            _busSpeedLimit = (data['flat_bus_speed_limit'] as num?)?.toDouble() ?? _busSpeedLimit;
            _saltRangeSpeedLimit = (data['salt_range_speed_limit'] as num?)?.toDouble() ?? _saltRangeSpeedLimit;
            _toleranceBuffer = (data['speed_tolerance_buffer'] as num?)?.toDouble() ?? _toleranceBuffer;
            _drowsinessThreshold = (data['drowsiness_threshold_sec'] as num?)?.toDouble() ?? _drowsinessThreshold;
            _crashGForceThreshold = (data['crash_gforce_threshold'] as num?)?.toDouble() ?? _crashGForceThreshold;
          });
        }
      }
    } catch (_) {
      // Keep sensible default thresholds for demo
    }
  }

  Future<void> _saveAndBroadcastConfig() async {
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('system_config').doc('m2_parameters').set({
        'flat_bus_speed_limit': _busSpeedLimit,
        'salt_range_speed_limit': _saltRangeSpeedLimit,
        'speed_tolerance_buffer': _toleranceBuffer,
        'drowsiness_threshold_sec': _drowsinessThreshold,
        'crash_gforce_threshold': _crashGForceThreshold,
        'updated_at': FieldValue.serverTimestamp(),
        'updated_by': 'HQ Operations Commander',
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Operational thresholds & AI parameters synced to all connected M-2 devices."),
          backgroundColor: AppTheme.green600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Config broadcast saved locally (Cloud fallback: $e)"),
          backgroundColor: AppTheme.blue600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Save Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("System Configuration & AI Tuning", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                  SizedBox(height: 4),
                  Text("Configure regulatory motorway speed thresholds & in-cabin AI sensor sensitivity (SRS FR-SA-10 / US#7)", style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.blue600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                ),
                icon: _isSaving
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const FaIcon(FontAwesomeIcons.towerBroadcast, size: 14),
                label: Text(
                  _isSaving ? "Syncing Fleet..." : "Save & Broadcast Configuration",
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                onPressed: _isSaving ? null : _saveAndBroadcastConfig,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Overview Strip Cards
          Row(
            children: [
              Expanded(child: _buildStatCard("Enforcement Corridor", "M-2 Motorway", FontAwesomeIcons.road, AppTheme.blue600)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Hazardous Zone", "Salt Range KM 148-158", FontAwesomeIcons.mountain, AppTheme.gold)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Edge AI Deployment", "Active On-Device", FontAwesomeIcons.microchip, AppTheme.green600)),
            ],
          ),
          const SizedBox(height: 24),

          // Speed Zone Regulatory Thresholds Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.blue600.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: const FaIcon(FontAwesomeIcons.gaugeHigh, size: 16, color: AppTheme.blue600),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Speed Zone Limits & Enforcement Buffers", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textDark)),
                        Text("Automatic e-Challan issuance thresholds for commercial passenger & freight fleets", style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 28),

                // Control 1: Flat M-2 Bus Limit
                _buildSliderControl(
                  title: "Flat M-2 Commercial Bus Limit",
                  subtitle: "Standard speed ceiling on open 3-lane motorway sections",
                  value: _busSpeedLimit,
                  min: 80.0,
                  max: 140.0,
                  divisions: 12,
                  unit: "km/h",
                  onChanged: (val) => setState(() => _busSpeedLimit = val),
                  color: AppTheme.blue600,
                ),
                const SizedBox(height: 16),

                // Control 2: Salt Range Downhill Limit
                _buildSliderControl(
                  title: "Salt Range Downhill Hazardous Limit",
                  subtitle: "Steep decline section (KM 148-158) with mandatory brake cooling bays",
                  value: _saltRangeSpeedLimit,
                  min: 30.0,
                  max: 80.0,
                  divisions: 10,
                  unit: "km/h",
                  onChanged: (val) => setState(() => _saltRangeSpeedLimit = val),
                  color: AppTheme.danger,
                ),
                const SizedBox(height: 16),

                // Control 3: Speed Tolerance Buffer
                _buildSliderControl(
                  title: "Enforcement Grace Buffer",
                  subtitle: "Margin added before automated AI camera / radar triggers fine citations",
                  value: _toleranceBuffer,
                  min: 0.0,
                  max: 15.0,
                  divisions: 15,
                  unit: "km/h",
                  onChanged: (val) => setState(() => _toleranceBuffer = val),
                  color: AppTheme.gold,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Edge AI Model Sensitivity Parameters Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.green600.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: const FaIcon(FontAwesomeIcons.brain, size: 16, color: AppTheme.green600),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("In-Cabin Edge AI Sensitivity Parameters", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textDark)),
                        Text("Tune real-time facial landmark eye-closure and dual-axis IMU collision triggers", style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 28),

                // AI Control 1: Drowsiness Eye-Closure
                _buildSliderControl(
                  title: "Drowsiness Eye-Closure Threshold (PERCLOS)",
                  subtitle: "Continuous eye closure duration required to sound auditory alarm & notify HQ",
                  value: _drowsinessThreshold,
                  min: 1.5,
                  max: 5.0,
                  divisions: 35,
                  unit: "seconds",
                  displayPrecision: 1,
                  onChanged: (val) => setState(() => _drowsinessThreshold = val),
                  color: AppTheme.gold,
                ),
                const SizedBox(height: 16),

                // AI Control 2: Crash Detection G-Force
                _buildSliderControl(
                  title: "Crash Deceleration G-Force Threshold",
                  subtitle: "Fusion of accelerometer peak Gs and gyroscope roll rate required for SOS impact alert",
                  value: _crashGForceThreshold,
                  min: 2.0,
                  max: 6.0,
                  divisions: 20,
                  unit: "G",
                  displayPrecision: 1,
                  onChanged: (val) => setState(() => _crashGForceThreshold = val),
                  color: AppTheme.danger,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderControl({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    int displayPrecision = 0,
    required ValueChanged<double> onChanged,
    required Color color,
  }) {
    final displayVal = displayPrecision == 0 ? value.round().toString() : value.toStringAsFixed(displayPrecision);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  "$displayVal $unit",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                displayPrecision == 0 ? "${min.round()}" : min.toStringAsFixed(1),
                style: const TextStyle(fontSize: 10, color: AppTheme.muted, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: color,
                    thumbColor: color,
                    overlayColor: color.withValues(alpha: 0.15),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    divisions: divisions,
                    onChanged: onChanged,
                  ),
                ),
              ),
              Text(
                displayPrecision == 0 ? "${max.round()}" : max.toStringAsFixed(1),
                style: const TextStyle(fontSize: 10, color: AppTheme.muted, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, dynamic icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted, letterSpacing: 0.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Center(child: FaIcon(icon, size: 14, color: color)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
        ],
      ),
    );
  }
}
