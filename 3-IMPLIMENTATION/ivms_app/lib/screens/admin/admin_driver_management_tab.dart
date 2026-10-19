import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class AdminDriverManagementTab extends ConsumerStatefulWidget {
  const AdminDriverManagementTab({super.key});

  @override
  ConsumerState<AdminDriverManagementTab> createState() => _AdminDriverManagementTabState();
}

class _AdminDriverManagementTabState extends ConsumerState<AdminDriverManagementTab> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'All Statuses';

  final List<String> _statusFilters = ['All Statuses', 'active', 'pending_approval', 'suspended'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fallback sample drivers ensuring rich presentation if Firestore is freshly initialized
  List<UserModel> _getFallbackDrivers() {
    return [
      UserModel(
        uid: "drv_demo_1",
        name: "Muhammad Rizwan",
        email: "rizwan@freightlogistics.pk",
        role: "driver",
        cnic: "35202-9876543-1",
        phone: "+92 321 4567890",
        licenseNo: "DL-LHR-9921",
        associatedVehicleReg: "LES-2026",
        vehicleType: "Heavy Freight",
        status: "active",
        createdAt: DateTime.now().subtract(const Duration(days: 80)),
      ),
      UserModel(
        uid: "drv_demo_2",
        name: "Tariq Mehmood",
        email: "tariq.driver@ivms.gov.pk",
        role: "driver",
        cnic: "37405-5544332-1",
        phone: "+92 300 5551234",
        licenseNo: "DL-ICT-4920",
        associatedVehicleReg: "ICT-TL-2940",
        vehicleType: "Passenger Bus",
        status: "active",
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      UserModel(
        uid: "drv_demo_3",
        name: "Abdul Rehman",
        email: "rehman@oiltankers.pk",
        role: "driver",
        cnic: "33100-1122334-5",
        phone: "+92 333 7778899",
        licenseNo: "DL-FSD-3829",
        associatedVehicleReg: "FSD-8812",
        vehicleType: "Oil Tanker",
        status: "suspended",
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
      ),
      UserModel(
        uid: "drv_demo_4",
        name: "Shahid Afridi",
        email: "shahid@logistics.com",
        role: "driver",
        cnic: "17301-4433221-7",
        phone: "+92 345 8889900",
        licenseNo: "DL-PEW-1049",
        associatedVehicleReg: "PEW-4920",
        vehicleType: "Light Transport",
        status: "pending_approval",
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }

  void _showToggleStatusDialog(UserModel driver) {
    final isCurrentlyActive = driver.status == 'active';
    final targetStatus = isCurrentlyActive ? 'suspended' : 'active';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(isCurrentlyActive ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                color: isCurrentlyActive ? AppTheme.danger : AppTheme.green600, size: 24),
            const SizedBox(width: 8),
            Text(isCurrentlyActive ? "Suspend Driver Account" : "Activate Driver Account",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          "Are you sure you want to ${isCurrentlyActive ? 'SUSPEND' : 'REACTIVATE'} driver ${driver.name} (License: ${driver.licenseNo ?? 'N/A'})?\n\n${isCurrentlyActive ? 'Suspended drivers will immediately be blocked from initiating trip telemetry sessions.' : 'Active drivers can resume telemetry tracking on M-2 Motorway.'}",
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentlyActive ? AppTheme.danger : AppTheme.green600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(userServiceProvider).updateUserStatus(driver.uid, targetStatus);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Driver ${driver.name} marked as ${targetStatus.toUpperCase()}"),
                    backgroundColor: isCurrentlyActive ? AppTheme.danger : AppTheme.green600,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e"), backgroundColor: AppTheme.danger),
                );
              }
            },
            child: Text(isCurrentlyActive ? "Confirm Suspension" : "Confirm Activation",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(driversStreamProvider);
    final rawList = driversAsync.value ?? [];
    final allDrivers = rawList.isNotEmpty ? rawList : _getFallbackDrivers();

    final filteredDrivers = allDrivers.where((driver) {
      if (_selectedStatus != 'All Statuses' && driver.status != _selectedStatus) return false;
      if (_searchController.text.trim().isNotEmpty) {
        final q = _searchController.text.trim().toLowerCase();
        final nameMatch = driver.name.toLowerCase().contains(q);
        final licenseMatch = (driver.licenseNo ?? '').toLowerCase().contains(q);
        final cnicMatch = (driver.cnic ?? '').toLowerCase().contains(q);
        final regMatch = (driver.associatedVehicleReg ?? '').toLowerCase().contains(q);
        if (!nameMatch && !licenseMatch && !cnicMatch && !regMatch) return false;
      }
      return true;
    }).toList();

    final totalDrivers = allDrivers.length;
    final activeDrivers = allDrivers.where((d) => d.status == 'active').length;
    final suspendedDrivers = allDrivers.where((d) => d.status == 'suspended').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Driver Management", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                  SizedBox(height: 4),
                  Text("Approve, monitor, and regulate commercial drivers on M-2 Motorway", style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Cards
          Row(
            children: [
              Expanded(child: _buildStatCard("Total Drivers", "$totalDrivers", FontAwesomeIcons.idCard, AppTheme.blue600)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Active & Licensed", "$activeDrivers", FontAwesomeIcons.chartSimple, AppTheme.green600)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Suspended / Flagged", "$suspendedDrivers", FontAwesomeIcons.triangleExclamation, AppTheme.danger)),
            ],
          ),
          const SizedBox(height: 24),

          // Search and Filters Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Search name, CNIC, or license...",
                      prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.muted),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedStatus,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w600),
                  items: _statusFilters.map((st) => DropdownMenuItem(value: st, child: Text(st.toUpperCase()))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStatus = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Drivers DataTable
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.border)),
                    color: Color(0xFFFAFCFF),
                  ),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.idCard, size: 16, color: AppTheme.blue600),
                      const SizedBox(width: 8),
                      Text("Registered Commercial Drivers (${filteredDrivers.length})",
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                    columns: const [
                      DataColumn(label: Text("DRIVER NAME", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("CNIC", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("LICENSE NO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("ASSOCIATED VEHICLE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("STATUS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("ACTIONS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                    ],
                    rows: filteredDrivers.map((driver) {
                      Color statusColor;
                      if (driver.status == 'active') {
                        statusColor = AppTheme.green600;
                      } else if (driver.status == 'suspended') {
                        statusColor = AppTheme.danger;
                      } else {
                        statusColor = AppTheme.gold;
                      }

                      final isSuspended = driver.status == 'suspended';

                      return DataRow(
                        cells: [
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(driver.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isSuspended ? AppTheme.muted : AppTheme.textDark,
                                    )),
                                Text(driver.phone ?? driver.email, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(driver.cnic ?? '37405-XXXXXXX-X',
                                style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppTheme.textDark)),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(driver.licenseNo ?? 'DL-ICT-4920',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.directions_bus, size: 16, color: AppTheme.blue600),
                                const SizedBox(width: 6),
                                Text(driver.associatedVehicleReg ?? 'No Active Session',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: driver.associatedVehicleReg != null ? AppTheme.textDark : AppTheme.muted,
                                    )),
                              ],
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(driver.status.toUpperCase(),
                                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800)),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: Icon(
                                isSuspended ? Icons.check_circle_outline : Icons.block,
                                size: 18,
                                color: isSuspended ? AppTheme.green600 : AppTheme.danger,
                              ),
                              tooltip: isSuspended ? "Activate Driver" : "Suspend Driver",
                              onPressed: () => _showToggleStatusDialog(driver),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
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
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Center(child: FaIcon(icon, size: 14, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
        ],
      ),
    );
  }
}
