import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/utils/date_utils.dart';

class ModernDateRangeDisplay extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onTap;
  const ModernDateRangeDisplay({
    super.key,
    this.startDate,
    this.endDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Default to "Now" and "7 days later" if no dates provided for preview purposes
    final displayStart = startDate ?? DateTime.now();
    final displayEnd = endDate ?? DateTime.now().add(const Duration(days: 7));
    final bool hasSelection = startDate != null && endDate != null;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 450),
      padding: const EdgeInsets.all(2), // The gradient border thickness
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withAlpha(210),
            colorScheme.primary.withAlpha(30),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Icon and Label
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  "SELECTED SCHEDULE",
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface.withAlpha(128),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // The Date Range View
            if (!hasSelection && startDate == null)
              Text(
                "No Range Selected",
                style: TextStyle(
                  fontSize: 18,
                  color: colorScheme.onSurface.withAlpha(100),
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _DateColumn(
                      label: "START DATE",
                      date: displayStart,
                      color: colorScheme.primary,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: colorScheme.onSurface.withAlpha(30),
                  ),
                  Expanded(
                    child: _DateColumn(
                      label: "END DATE",
                      date: displayEnd,
                      color: colorScheme.primary,
                      crossAxisAlignment: CrossAxisAlignment.end,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ).onTap(onTap);
  }
}

class _DateColumn extends StatelessWidget {
  final String label;
  final DateTime date;
  final Color color;
  final CrossAxisAlignment crossAxisAlignment;

  const _DateColumn({
    required this.label,
    required this.date,
    required this.color,
    required this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: color.withAlpha(210),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          GenesisDate.getInformalShortDate(date),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          GenesisDate.getInformalShortDate(date),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
          ),
        ),
      ],
    );
  }
}
