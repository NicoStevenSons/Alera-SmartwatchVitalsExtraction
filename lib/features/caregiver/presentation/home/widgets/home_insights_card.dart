import 'package:flutter/material.dart';

import '../../../../../design_system/alera_colors.dart';
import '../../../../../design_system/alera_typography.dart';
import '../../../../../design_system/widgets/alera_section_card.dart';
import '../../../../../design_system/widgets/alera_svg_icon.dart';
import '../../../domain/models/health_snapshot.dart';

class HomeInsightsCard extends StatelessWidget {
  final HealthSnapshot snapshot;

  const HomeInsightsCard({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final String sleep =
        '${snapshot.sleepDuration.inHours}h ${snapshot.sleepDuration.inMinutes.remainder(60)}m';
    return AleraSectionCard(
      title: "Today's Insights",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Insight(
            assetPath: 'alera-figma-assets/assets/icons/mini_status/spo2.svg',
            color: const Color(0xFF8A78F0),
            title: snapshot.spo2Percent == null
                ? 'No overnight SpO2 reading'
                : 'SpO2 stayed stable overnight',
            subtitle: snapshot.spo2Percent == null
                ? 'Waiting for mock data'
                : '${(snapshot.spo2Percent! - 1).toStringAsFixed(0)} - ${snapshot.spo2Percent!.toStringAsFixed(0)}% while sleeping',
          ),
          const SizedBox(height: 10),
          _Insight(
            assetPath:
                'alera-figma-assets/assets/icons/mini_status/activity.svg',
            color: const Color(0xFF79CF2E),
            title: snapshot.steps == null
                ? 'No activity data today'
                : 'Low activity today',
            subtitle: snapshot.steps == null
                ? 'Waiting for mock data'
                : '${snapshot.steps} steps recorded',
          ),
          const SizedBox(height: 10),
          _Insight(
            assetPath: 'alera-figma-assets/assets/icons/mini_status/sleep.svg',
            color: const Color(0xFF9A72F0),
            title: 'Slept $sleep',
            subtitle: 'Mock sleep summary',
          ),
        ],
      ),
    );
  }
}

class _Insight extends StatelessWidget {
  final String assetPath;
  final Color color;
  final String title;
  final String subtitle;

  const _Insight({
    required this.assetPath,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AleraSvgIcon(
          assetPath: assetPath,
          width: 20,
          height: 20,
          semanticLabel: title,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AleraTypography.label.copyWith(
                  color: AleraColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AleraTypography.body.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
