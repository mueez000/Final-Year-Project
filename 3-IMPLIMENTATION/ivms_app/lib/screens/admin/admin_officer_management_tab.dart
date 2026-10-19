import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class AdminOfficerManagementTab extends ConsumerStatefulWidget {
  const AdminOfficerManagementTab({super.key});

  @override
  ConsumerState<AdminOfficerManagementTab> createState() => _AdminOfficerManagementTabState();
}

class _AdminOfficerManagementTabState extends ConsumerState<AdminOfficerManagementTab> {
  String _selectedSector = 'All Sectors';
  String _selectedRank = 'All Ranks';
  String _selectedStatus = 'All Statuses';
  final _searchController = TextEditingController();

  final List<String> _sectors = [
    'All Sectors',
    'M-2 Salt Range KM 148',
    'M-2 Balkassar Exit',
    'M-2 Bhera Sector',
    'M-2 Chakri Interchange',
    'M-2 Kot Momin',
  ];

  final List<String> _ranks = [
    'All Ranks',
    'Inspector',
    'Senior Patrol Officer',
    'Patrol Officer',
    'Sub-Inspector',
  ];

  final List<String> _statuses = [
    'All Statuses',
    'On Patrol',
    'Responding to Incident',
    'On Leave',
    'Offline',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fallback sample officers to ensure rich display even if Firestore collection is fresh/empty
  List<UserModel> _getFallbackOfficers() {
    return [
      UserModel(
        uid: "off_demo_1",
        name: "Tariq Mehmood",
        email: "tariq.mehmood@nhmp.gov.pk",
        role: "officer",
        badgeNo: "NHMP-M2-401",
        rank: "Inspector",
        station: "M-2 Salt Range KM 148",
        phone: "+92 300 1234567",
        cnic: "37405-1234567-1",
        dutyStatus: "On Patrol",
        shiftTiming: "08:00 AM - 08:00 PM",
        dutyType: "Patrol",
        incidentsHandled: 42,
        avgResponseMinutes: 4.2,
        status: "active",
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      UserModel(
        uid: "off_demo_2",
        name: "Asadullah Khan",
        email: "asadullah.khan@nhmp.gov.pk",
        role: "officer",
        badgeNo: "NHMP-M2-402",
        rank: "Senior Patrol Officer",
        station: "M-2 Balkassar Exit",
        phone: "+92 301 2345678",
        cnic: "37405-2345678-3",
        dutyStatus: "Responding to Incident",
        shiftTiming: "08:00 AM - 08:00 PM",
        dutyType: "Incident Response",
        incidentsHandled: 38,
        avgResponseMinutes: 3.8,
        status: "active",
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      UserModel(
        uid: "off_demo_3",
        name: "Bilal Ahmed",
        email: "bilal.ahmed@nhmp.gov.pk",
        role: "officer",
        badgeNo: "NHMP-M2-403",
        rank: "Patrol Officer",
        station: "M-2 Bhera Sector",
        phone: "+92 302 3456789",
        cnic: "37405-3456789-5",
        dutyStatus: "Offline",
        shiftTiming: "08:00 PM - 08:00 AM",
        dutyType: "Patrol",
        incidentsHandled: 29,
        avgResponseMinutes: 5.1,
        status: "active",
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      UserModel(
        uid: "off_demo_4",
        name: "Hamza Ali",
        email: "hamza.ali@nhmp.gov.pk",
        role: "officer",
        badgeNo: "NHMP-M2-404",
        rank: "Sub-Inspector",
        station: "M-2 Chakri Interchange",
        phone: "+92 303 4567890",
        cnic: "37405-4567890-7",
        dutyStatus: "On Leave",
        shiftTiming: "Shift Off",
        dutyType: "Checkpoint",
        incidentsHandled: 19,
        avgResponseMinutes: 4.8,
        status: "suspended",
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
    ];
  }

  void _showAddOfficerModal() {
    final nameCtrl = TextEditingController();
    final badgeCtrl = TextEditingController(text: "NHMP-M2-");
    final cnicCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: "+92 3");
    final passwordCtrl = TextEditingController();
    String selectedRank = "Inspector";
    String selectedSector = "M-2 Salt Range KM 148";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              FaIcon(FontAwesomeIcons.userShield, color: AppTheme.blue800, size: 20),
              SizedBox(width: 10),
              Text("Register New Patrol Officer", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModalField("Full Name", nameCtrl, "e.g. Asadullah Khan"),
                const SizedBox(height: 12),
                _buildModalField("Badge ID", badgeCtrl, "NHMP-M2-405"),
                const SizedBox(height: 12),
                _buildModalField("CNIC (13 Digits)", cnicCtrl, "37405-1234567-1"),
                const SizedBox(height: 12),
                const Text("Rank", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedRank,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _ranks.where((r) => r != 'All Ranks').map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedRank = val);
                  },
                ),
                const SizedBox(height: 12),
                _buildModalField("Phone", phoneCtrl, "+92 300 1234567"),
                const SizedBox(height: 12),
                const Text("Assigned Patrol Sector", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedSector,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _sectors.where((s) => s != 'All Sectors').map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedSector = val);
                  },
                ),
                const SizedBox(height: 12),
                _buildModalField("Password (min 6 characters)", passwordCtrl, "******", obscureText: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.blue800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final badge = badgeCtrl.text.trim();
                final cnic = cnicCtrl.text.trim();
                final phone = phoneCtrl.text.trim();
                final pass = passwordCtrl.text.trim();

                if (name.isEmpty || badge.isEmpty || pass.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill all required fields (password min 6 chars)")),
                  );
                  return;
                }

                Navigator.pop(ctx);
                final email = "${badge.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}@nhmp.gov.pk";

                try {
                  await ref.read(authControllerProvider.notifier).signUpOfficer(
                    email: email,
                    password: pass,
                    name: name,
                    badgeNo: badge,
                    rank: selectedRank,
                    station: selectedSector,
                    phone: phone,
                    cnic: cnic,
                  );

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Officer $name ($badge) successfully registered!"),
                      backgroundColor: AppTheme.green600,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error registering officer: $e"), backgroundColor: AppTheme.danger),
                  );
                }
              },
              child: const Text("Register Officer", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDutyModal(UserModel officer) {
    String selectedSector = (officer.station != null && _sectors.contains(officer.station))
        ? officer.station!
        : 'M-2 Salt Range KM 148';
    String selectedTiming = officer.shiftTiming ?? '08:00 AM - 08:00 PM';
    String selectedDutyType = officer.dutyType ?? 'Patrol';
    String selectedDutyStatus = officer.dutyStatus ?? 'On Patrol';

    final shiftOptions = [
      '08:00 AM - 08:00 PM',
      '08:00 PM - 08:00 AM',
      '06:00 AM - 02:00 PM',
      '02:00 PM - 10:00 PM',
      'Shift Off',
    ];

    final dutyTypes = ['Patrol', 'Incident Response', 'Checkpoint', 'Station Command'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const FaIcon(FontAwesomeIcons.calendarCheck, color: AppTheme.blue800, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Assign Duty Schedule", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text("${officer.name} • ${officer.badgeNo ?? 'Badge N/A'}", style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Assigned Sector", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedSector,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _sectors.where((s) => s != 'All Sectors').map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedSector = val);
                  },
                ),
                const SizedBox(height: 12),
                const Text("Shift Timing", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: shiftOptions.contains(selectedTiming) ? selectedTiming : shiftOptions.first,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: shiftOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedTiming = val);
                  },
                ),
                const SizedBox(height: 12),
                const Text("Duty Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: dutyTypes.contains(selectedDutyType) ? selectedDutyType : dutyTypes.first,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: dutyTypes.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedDutyType = val);
                  },
                ),
                const SizedBox(height: 12),
                const Text("Duty Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _statuses.contains(selectedDutyStatus) && selectedDutyStatus != 'All Statuses'
                      ? selectedDutyStatus
                      : 'On Patrol',
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _statuses.where((s) => s != 'All Statuses').map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedDutyStatus = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.blue800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await ref.read(userServiceProvider).assignOfficerDuty(
                    uid: officer.uid,
                    station: selectedSector,
                    shiftTiming: selectedTiming,
                    dutyType: selectedDutyType,
                    dutyStatus: selectedDutyStatus,
                  );

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Duty schedule updated for Officer ${officer.name}!"),
                      backgroundColor: AppTheme.green600,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error updating duty schedule: $e"), backgroundColor: AppTheme.danger),
                  );
                }
              },
              child: const Text("Save Duty Assignment", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showToggleStatusDialog(UserModel officer) {
    final isCurrentlyActive = officer.status == 'active';
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
            Text(isCurrentlyActive ? "Suspend Officer" : "Activate Officer",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          "Are you sure you want to ${isCurrentlyActive ? 'SUSPEND' : 'REACTIVATE'} ${officer.name} (${officer.badgeNo ?? 'Badge N/A'})?\n\n${isCurrentlyActive ? 'Suspended officers cannot log into mobile patrol terminals.' : 'Reactivated officers will regain active patrol privileges.'}",
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
                await ref.read(userServiceProvider).updateUserStatus(officer.uid, targetStatus);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Officer ${officer.name} marked as ${targetStatus.toUpperCase()}"),
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

  Widget _buildModalField(String label, TextEditingController controller, String hint, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final officersAsync = ref.watch(officersStreamProvider);
    final rawList = officersAsync.value ?? [];
    final allOfficers = rawList.isNotEmpty ? rawList : _getFallbackOfficers();

    // Local filtering
    final filteredOfficers = allOfficers.where((officer) {
      if (_selectedSector != 'All Sectors' && officer.station != _selectedSector) return false;
      if (_selectedRank != 'All Ranks' && officer.rank != _selectedRank) return false;
      if (_selectedStatus != 'All Statuses' && officer.dutyStatus != _selectedStatus) return false;
      if (_searchController.text.trim().isNotEmpty) {
        final q = _searchController.text.trim().toLowerCase();
        final nameMatch = officer.name.toLowerCase().contains(q);
        final badgeMatch = (officer.badgeNo ?? '').toLowerCase().contains(q);
        if (!nameMatch && !badgeMatch) return false;
      }
      return true;
    }).toList();

    final totalOfficers = allOfficers.length;
    final onDutyOfficers = allOfficers.where((o) => o.dutyStatus == 'On Patrol' || o.dutyStatus == 'Responding to Incident').length;
    final activePersonnel = allOfficers.where((o) => o.status == 'active').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Officer Management", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                  SizedBox(height: 4),
                  Text("Manage traffic enforcement personnel & duty schedules", style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.blue600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                ),
                icon: const FaIcon(FontAwesomeIcons.plus, size: 14),
                label: const Text("Add New Officer", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                onPressed: () => _showAddOfficerModal(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Cards Strip
          Row(
            children: [
              Expanded(child: _buildStatCard("Total Officers", "$totalOfficers", FontAwesomeIcons.userShield, AppTheme.blue600)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("On Duty / Patrol", "$onDutyOfficers", FontAwesomeIcons.chartSimple, AppTheme.green600)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Active Personnel", "$activePersonnel", FontAwesomeIcons.shieldHalved, AppTheme.navy950)),
            ],
          ),
          const SizedBox(height: 24),

          // Filter Strip Bar (Sector, Rank, Duty Status, Search)
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
                  width: 220,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Search name or badge...",
                      prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.muted),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedSector,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w600),
                  items: _sectors.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSector = val);
                  },
                ),
                DropdownButton<String>(
                  value: _selectedRank,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w600),
                  items: _ranks.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRank = val);
                  },
                ),
                DropdownButton<String>(
                  value: _selectedStatus,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w600),
                  items: _statuses.map((st) => DropdownMenuItem(value: st, child: Text(st))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStatus = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Officer DataTable
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
                      const FaIcon(FontAwesomeIcons.userShield, size: 16, color: AppTheme.blue600),
                      const SizedBox(width: 8),
                      Text("Registered NH&MP Officers (${filteredOfficers.length})",
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                    columns: const [
                      DataColumn(label: Text("BADGE ID", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("OFFICER NAME & RANK", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("ASSIGNED SECTOR", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("DUTY STATUS & SHIFT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("ACTIONS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                    ],
                    rows: filteredOfficers.map((officer) {
                      Color statusColor;
                      final dStatus = officer.dutyStatus ?? 'Offline';
                      if (dStatus == 'On Patrol') {
                        statusColor = AppTheme.green600;
                      } else if (dStatus == 'Responding to Incident') {
                        statusColor = AppTheme.danger;
                      } else if (dStatus == 'On Leave') {
                        statusColor = AppTheme.gold;
                      } else {
                        statusColor = Colors.grey;
                      }

                      final isSuspended = officer.status == 'suspended';

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(officer.badgeNo ?? 'BDG-PENDING',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark)),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(officer.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isSuspended ? AppTheme.muted : AppTheme.textDark,
                                    )),
                                Text("${officer.rank ?? 'Patrol Officer'} • ${officer.phone ?? 'No Phone'}",
                                    style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(officer.station ?? 'M-2 Salt Range Sector',
                                style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(dStatus,
                                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800)),
                                ),
                                const SizedBox(width: 6),
                                Text(officer.shiftTiming ?? '08:00 AM - 08:00 PM',
                                    style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                              ],
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.calendarCheck, size: 14, color: AppTheme.blue600),
                                  tooltip: "Assign Duty (US#14)",
                                  onPressed: () => _showAssignDutyModal(officer),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isSuspended ? Icons.check_circle_outline : Icons.block,
                                    size: 18,
                                    color: isSuspended ? AppTheme.green600 : AppTheme.danger,
                                  ),
                                  tooltip: isSuspended ? "Reactivate Officer (US#16)" : "Suspend Officer (US#16)",
                                  onPressed: () => _showToggleStatusDialog(officer),
                                ),
                              ],
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
