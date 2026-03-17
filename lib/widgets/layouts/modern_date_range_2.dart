import 'package:flutter/material.dart';
import 'package:genesis/utils/date_utils.dart';

class ModernDateRange2 extends StatelessWidget {
  final DateTimeRange selectedDateRange;
  final VoidCallback onSelect;
  const ModernDateRange2({
    super.key,
    required this.selectedDateRange,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return buildModernDateRange(context);
  }

  // Assuming GenesisDate and selectedDateRange are accessible in your context
  Widget buildModernDateRange(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // Ultra-clean dark theme container
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(25), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Icon acts as the primary visual anchor
              Icon(
                Icons.event_note_rounded,
                color: Colors.white.withAlpha(100),
                size: 20,
              ),
              const SizedBox(width: 16),
              // Start Date Chip
              _buildDateChip(
                GenesisDate.getInformalDate(selectedDateRange.start),
              ),

              // Modern Arrow Separator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: Colors.white.withAlpha(60),
                ),
              ),

              // End Date Chip
              _buildDateChip(
                GenesisDate.getInformalDate(selectedDateRange.end),
              ),

              // Edit hint
              Text(
                "Edit",
                style: TextStyle(
                  color: Colors.blueAccent.shade100,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        date,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
