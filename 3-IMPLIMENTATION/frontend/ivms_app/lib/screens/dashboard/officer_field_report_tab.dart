import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';

class OfficerFieldReportTab extends StatelessWidget {
  const OfficerFieldReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 16, bottom: 20, left: 20, right: 20),
              color: AppTheme.blue800,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Field Report", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                          Text("Issue e-Challan / Record Incident", style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(child: FaIcon(FontAwesomeIcons.clockRotateLeft, color: Colors.white, size: 14)),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7F1D1D), AppTheme.danger],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(child: FaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.white, size: 16)),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Linked to Active Alert", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                            Text("INC-88902 • Over-speeding", style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildFormSection(
                    title: "Vehicle & Driver Info",
                    icon: FontAwesomeIcons.car,
                    children: [
                      _buildTextField(label: "Registration Number", hint: "e.g., ABC-123", icon: FontAwesomeIcons.idCard),
                      _buildTextField(label: "Driver Name (Optional)", hint: "Enter name", icon: FontAwesomeIcons.user),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFormSection(
                    title: "Violation Details",
                    icon: FontAwesomeIcons.gavel,
                    children: [
                      _buildDropdownField(label: "Violation Type", hint: "Select Violation", icon: FontAwesomeIcons.list),
                      _buildTextField(label: "Fine Amount", hint: "0.00", icon: FontAwesomeIcons.dollarSign, isNumber: true),
                      _buildTextField(label: "Location", hint: "Current GPS Location", icon: FontAwesomeIcons.locationDot),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFormSection(
                    title: "Additional Notes",
                    icon: FontAwesomeIcons.noteSticky,
                    children: [
                      _buildTextField(label: "Comments", hint: "Add context or observations...", icon: FontAwesomeIcons.pen, maxLines: 3),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report Submitted')));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.blue800,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      shadowColor: AppTheme.blue800.withOpacity(0.4),
                    ),
                    child: const Text("SUBMIT FIELD REPORT", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection({required String title, required dynamic icon, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                FaIcon(icon, color: AppTheme.blue600, size: 14),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children.expand((widget) => [widget, const SizedBox(height: 12)]).toList()..removeLast(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint, required dynamic icon, bool isNumber = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.textDark)),
        const SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.muted, fontSize: 13),
            prefixIcon: maxLines == 1 ? Padding(padding: const EdgeInsets.all(12), child: FaIcon(icon, size: 14, color: AppTheme.muted)) : null,
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 12 : 0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border, width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.blue600, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required String hint, required dynamic icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.textDark)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border, width: 1.5),
          ),
          child: Row(
            children: [
              FaIcon(icon, size: 14, color: AppTheme.muted),
              const SizedBox(width: 12),
              Expanded(child: Text(hint, style: const TextStyle(color: AppTheme.muted, fontSize: 13))),
              const FaIcon(FontAwesomeIcons.chevronDown, size: 12, color: AppTheme.muted),
            ],
          ),
        ),
      ],
    );
  }
}
