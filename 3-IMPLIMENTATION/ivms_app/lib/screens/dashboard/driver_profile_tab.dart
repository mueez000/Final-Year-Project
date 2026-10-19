import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/telemetry_provider.dart';
import '../../models/user_model.dart';
import '../role_selection_screen.dart';

class DriverProfileTab extends ConsumerWidget {
  const DriverProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final trackingState = ref.watch(telemetryTrackingControllerProvider);
    final user = userProfileAsync.value;

    final name = (user?.name != null && user!.name.isNotEmpty) ? user.name : "Tariq Mehmood";
    final license = (user?.licenseNo != null && user!.licenseNo!.isNotEmpty) ? user.licenseNo! : "DL-ICT-4920";
    final cnic = (user?.cnic != null && user!.cnic!.isNotEmpty) ? user.cnic! : "35202-1234567-1";
    final vehicleReg = (user?.associatedVehicleReg != null && user!.associatedVehicleReg!.isNotEmpty)
        ? user.associatedVehicleReg!
        : "ICT-TL-2940";
    final isConsentGranted = user?.consentGranted ?? false;

    String initials = "TM";
    final nameParts = name.trim().split(RegExp(r'\s+'));
    if (nameParts.length >= 2) {
      initials = "${nameParts[0][0]}${nameParts[1][0]}".toUpperCase();
    } else if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
      initials = nameParts[0].substring(0, nameParts[0].length >= 2 ? 2 : 1).toUpperCase();
    }

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
                                colors: [AppTheme.green500, AppTheme.green400],
                              ),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                              ),
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
                      Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(
                        "License: $license • CNIC: $cnic",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBadge(FontAwesomeIcons.medal, "Top 5%"),
                          const SizedBox(width: 8),
                          _buildBadge(FontAwesomeIcons.shield, "Safe Driver"),
                          const SizedBox(width: 8),
                          _buildBadge(FontAwesomeIcons.bus, vehicleReg),
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
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 14, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat("Trips", "1,248"),
                        Container(width: 1, height: 30, color: AppTheme.border),
                        _buildStat("Rating", "4.9"),
                        Container(width: 1, height: 30, color: AppTheme.border),
                        _buildStat("Score", "96/100"),
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
                  const Text(
                    "ACCOUNT & COMPLIANCE SETTINGS",
                    style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.muted, fontSize: 12, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        _buildSettingsTile(
                          FontAwesomeIcons.user,
                          "Personal Information",
                          subtitle: "CNIC: $cnic • Role: Commercial Driver",
                        ),
                        const Divider(height: 1, color: AppTheme.border),
                        _buildSettingsTile(
                          FontAwesomeIcons.idCard,
                          "License Details",
                          subtitle: "License: $license • Category: ${user?.vehicleType ?? 'Commercial Bus'}",
                        ),
                        const Divider(height: 1, color: AppTheme.border),
                        _buildSettingsTile(
                          FontAwesomeIcons.car,
                          "Vehicle Information (FR-D-06)",
                          subtitle: "Associated Plate: $vehicleReg (Tap to edit)",
                          onTap: () => _showEditVehicleDialog(context, ref, user, vehicleReg),
                        ),
                        const Divider(height: 1, color: AppTheme.border),
                        _buildSettingsTile(
                          FontAwesomeIcons.shieldHalved,
                          "Data Collection Consent (FR-D-07)",
                          subtitle: isConsentGranted
                              ? "Consent Active (GPS, Camera, Audio)"
                              : "Consent Revoked (Monitoring Paused)",
                          trailingWidget: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (isConsentGranted ? AppTheme.green600 : AppTheme.danger).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isConsentGranted ? "Granted" : "Revoked",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isConsentGranted ? AppTheme.green600 : AppTheme.danger,
                              ),
                            ),
                          ),
                          onTap: () => _showConsentManagementDialog(
                            context,
                            ref,
                            user,
                            isConsentGranted,
                            trackingState.isTracking,
                          ),
                        ),
                        const Divider(height: 1, color: AppTheme.border),
                        _buildSettingsTile(
                          FontAwesomeIcons.sliders,
                          "App Settings",
                          subtitle: "Speed tolerance buffer, local storage sync",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (trackingState.isTracking) {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Active Trip in Progress"),
                            content: const Text(
                              "Trip monitoring is currently active on M-2. Logging out will stop live telemetry collection. Are you sure you want to end your session?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text("Stop Trip & Log Out", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout != true) return;
                        await ref.read(telemetryTrackingControllerProvider.notifier).stopTrip(user?.uid ?? "");
                      }

                      await ref.read(authControllerProvider.notifier).signOut();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                        (route) => false,
                      );
                    },
                    icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket, size: 16),
                    label: const Text("Log Out"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.danger.withValues(alpha: 0.1),
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
        color: Colors.white.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(child: FaIcon(icon, color: Colors.white, size: 14)),
    );
  }

  Widget _buildBadge(dynamic icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, color: AppTheme.gold, size: 10),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 10, fontWeight: FontWeight.w700)),
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

  Widget _buildSettingsTile(
    dynamic icon,
    String title, {
    String? subtitle,
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
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
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.muted))
          : null,
      trailing: trailingWidget ?? const FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: AppTheme.muted),
      onTap: onTap,
    );
  }

  void _showEditVehicleDialog(BuildContext context, WidgetRef ref, UserModel? user, String currentReg) {
    final controller = TextEditingController(text: currentReg);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            FaIcon(FontAwesomeIcons.car, size: 18, color: AppTheme.blue800),
            SizedBox(width: 10),
            Text("Update Vehicle (FR-D-06)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Change your active bus or van registration number for the ongoing session:",
                style: TextStyle(fontSize: 12, color: AppTheme.muted),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: "Vehicle Registration",
                  hintText: "e.g. ICT-BUS-402, LES-9921",
                  prefixIcon: Icon(Icons.directions_bus),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return "Vehicle registration is required";
                  if (val.trim().length < 3) return "Enter a valid registration";
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.green600),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final newReg = controller.text.trim().toUpperCase();
              Navigator.pop(ctx);
              if (user != null) {
                try {
                  await ref.read(userServiceProvider).updateDriverVehicleAssociation(user.uid, newReg);
                } catch (e) {
                  debugPrint("Error updating vehicle: $e");
                }
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Associated vehicle updated to $newReg"),
                    backgroundColor: AppTheme.green600,
                  ),
                );
              }
            },
            child: const Text("Update Plate", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showConsentManagementDialog(
    BuildContext context,
    WidgetRef ref,
    UserModel? user,
    bool isCurrentlyGranted,
    bool isTracking,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            FaIcon(
              isCurrentlyGranted ? FontAwesomeIcons.shieldHalved : FontAwesomeIcons.shield,
              color: isCurrentlyGranted ? AppTheme.danger : AppTheme.green600,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              isCurrentlyGranted ? "Revoke Data Consent?" : "Grant Data Consent",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          isCurrentlyGranted
              ? "Revoking data collection consent will immediately stop continuous background telemetry and AI safety monitoring (FR-D-07). Are you sure?"
              : "Granting consent allows IVMS to capture real-time GPS telemetry, accelerometer crash signatures, and camera drowsiness indicators on M-2.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentlyGranted ? AppTheme.danger : AppTheme.green600,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final targetState = !isCurrentlyGranted;
              if (!targetState && isTracking) {
                await ref.read(telemetryTrackingControllerProvider.notifier).stopTrip(user?.uid ?? "");
              }

              if (user != null) {
                try {
                  await ref.read(userServiceProvider).updateDriverConsent(user.uid, targetState);
                } catch (e) {
                  debugPrint("Error updating consent: $e");
                }
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      targetState
                          ? "Data collection consent granted. Monitoring authorized."
                          : "Data collection consent revoked. Monitoring stopped.",
                    ),
                    backgroundColor: targetState ? AppTheme.green600 : AppTheme.danger,
                  ),
                );
              }
            },
            child: Text(
              isCurrentlyGranted ? "Revoke & Stop Monitoring" : "Grant Consent",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
