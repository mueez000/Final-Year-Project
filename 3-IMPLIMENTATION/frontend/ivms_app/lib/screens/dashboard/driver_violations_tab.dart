import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';

class DriverViolationsTab extends StatelessWidget {
  const DriverViolationsTab({super.key});

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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "e-Challans",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text("2026", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildSummaryCard("Pending", "2", AppTheme.danger)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildSummaryCard("Paid", "5", AppTheme.green400)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildSummaryCard("Total", "7", Colors.white)),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Pending Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7F1D1D), AppTheme.danger],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppTheme.danger.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(child: FaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.white, size: 18)),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Action Required", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                              SizedBox(height: 2),
                              Text("2 pending challans", style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text("PAY ALL", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Filter Pills
                  Row(
                    children: [
                      _buildFilterPill("All", false),
                      const SizedBox(width: 8),
                      _buildFilterPill("Pending", true),
                      const SizedBox(width: 8),
                      _buildFilterPill("Paid", false),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTicketCard(
                    id: "CHL-2026-8901",
                    title: "Over-speeding Zone 4",
                    date: "Today, 10:45 AM",
                    location: "Main Boulevard, DHA Phase 6",
                    status: "UNPAID",
                    amount: "\$120",
                    isPaid: false,
                  ),
                  _buildTicketCard(
                    id: "CHL-2026-8899",
                    title: "Illegal Parking",
                    date: "May 10, 2026",
                    location: "Liberty Market Parking",
                    status: "UNPAID",
                    amount: "\$50",
                    isPaid: false,
                  ),
                  _buildTicketCard(
                    id: "CHL-2026-7512",
                    title: "Signal Violation",
                    date: "Apr 22, 2026",
                    location: "Ferozepur Road Intersection",
                    status: "PAID",
                    amount: "\$200",
                    isPaid: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.blue800 : Colors.white,
        border: Border.all(color: isActive ? AppTheme.blue800 : AppTheme.border, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : AppTheme.muted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTicketCard({
    required String id,
    required String title,
    required String date,
    required String location,
    required String status,
    required String amount,
    required bool isPaid,
  }) {
    final statusColor = isPaid ? AppTheme.green500 : AppTheme.danger;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(id, style: const TextStyle(color: AppTheme.muted, fontSize: 11, fontWeight: FontWeight.w800)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Row(
            children: [
              const FaIcon(FontAwesomeIcons.clock, size: 10, color: AppTheme.muted),
              const SizedBox(width: 6),
              Text(date, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const FaIcon(FontAwesomeIcons.locationDot, size: 10, color: AppTheme.muted),
              const SizedBox(width: 6),
              Text(location, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(amount, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
              if (!isPaid)
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.blue800,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("PAY NOW", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text("RECEIPT", style: TextStyle(color: AppTheme.muted, fontSize: 11, fontWeight: FontWeight.w800)),
                )
            ],
          ),
        ],
      ),
    );
  }
}
