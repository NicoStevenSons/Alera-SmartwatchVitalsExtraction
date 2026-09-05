import 'package:flutter/material.dart';

import '../../../../../design_system/alera_typography.dart';
import '../../../../../design_system/widgets/alera_card.dart';
import '../../../domain/models/health_snapshot.dart';

class PatientVitalSummarySection extends StatelessWidget {
  final HealthSnapshot snapshot;
  final ValueChanged<String> onVitalTap;

  const PatientVitalSummarySection({
    super.key,
    required this.snapshot,
    required this.onVitalTap,
  });

  @override
  Widget build(BuildContext context) {
    return AleraCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vitals', style: AleraTypography.sectionTitle),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: _VitalTile(
                  label: 'Heart Rate',
                  value: snapshot.heartRateBpm?.toString() ?? '--',
                  unit: 'bpm',
                  icon: Icons.monitor_heart,
                  foreground: const Color(0xFFC51B50),
                  background: const Color(0xFFFFD9DF),
                  onTap: () => onVitalTap('Heart Rate'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VitalTile(
                  label: 'SpO2',
                  value: snapshot.spo2Percent?.toStringAsFixed(0) ?? '--',
                  unit: '%',
                  icon: Icons.water_drop,
                  foreground: const Color(0xFF493BC5),
                  background: const Color(0xFFDDE4FF),
                  onTap: () => onVitalTap('SpO2'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ActivityTile(
            steps: snapshot.steps,
            onTap: () => onVitalTap('Activity'),
          ),
        ],
      ),
    );
  }
}

class _VitalTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color foreground;
  final Color background;
  final VoidCallback onTap;

  const _VitalTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: foreground, size: 17),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 30,
                      height: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(unit, style: TextStyle(color: foreground, fontSize: 16)),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: foreground, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final int? steps;
  final VoidCallback onTap;

  const _ActivityTile({required this.steps, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE2FFB2),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.directions_walk,
                    color: Color(0xFF5B8D1B),
                    size: 18,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Activity',
                    style: TextStyle(
                      color: Color(0xFF4B7615),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Low activity today',
                style: TextStyle(color: Color(0xFF7CA445), fontSize: 16),
              ),
              Row(
                children: [
                  Text(
                    steps == null ? '--' : _formatSteps(steps!),
                    style: const TextStyle(
                      color: Color(0xFF4B7615),
                      fontSize: 29,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Text(
                    'steps',
                    style: TextStyle(color: Color(0xFF7CA445), fontSize: 16),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Color(0xFF7CA445)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSteps(int value) {
    final String digits = value.toString();
    return digits.length <= 3
        ? digits
        : '${digits.substring(0, digits.length - 3)},${digits.substring(digits.length - 3)}';
  }
}
