import 'package:flutter/material.dart';

import '../../../../design_system/alera_colors.dart';
import '../../../../design_system/alera_typography.dart';
import '../../../../design_system/widgets/alera_card.dart';
import '../../../../design_system/widgets/alera_svg_icon.dart';
import '../../domain/models/care_recipient.dart';
import '../../domain/models/caregiver_alert.dart';
import '../patient_detail/widgets/monitoring_devices_card.dart';

class CaregiverAlertDetailPage extends StatefulWidget {
  final CaregiverAlert alert;
  final CareRecipient? careRecipient;

  const CaregiverAlertDetailPage({
    super.key,
    required this.alert,
    required this.careRecipient,
  });

  @override
  State<CaregiverAlertDetailPage> createState() =>
      _CaregiverAlertDetailPageState();
}

class _CaregiverAlertDetailPageState extends State<CaregiverAlertDetailPage> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _mock(String action) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$action is mock-only for now.')));
  }

  @override
  Widget build(BuildContext context) {
    final CaregiverAlert alert = widget.alert;
    final bool heartRate = alert.metric == CaregiverAlertMetric.heartRate;
    final bool spo2 = alert.metric == CaregiverAlertMetric.spo2;
    final bool critical = alert.severity == CaregiverAlertSeverity.critical;
    final Color severityColor = critical
        ? AleraColors.critical
        : AleraColors.warning;
    final String iconPath = heartRate
        ? 'alera-figma-assets/assets/icons/mini_status/heart_rate.svg'
        : spo2
        ? 'alera-figma-assets/assets/icons/mini_status/spo2.svg'
        : 'alera-figma-assets/assets/icons/mini_status/info.svg';
    final String patientName =
        alert.patientDisplayName ??
        widget.careRecipient?.name ??
        'Unknown patient';
    final bool hasAdditionalContext = alert.description.trim().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('Alert', style: AleraTypography.pageTitle),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Menu',
                    onPressed: () => _mock('Menu'),
                    icon: const Icon(Icons.menu),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                children: [
                  _SummaryCard(
                    alert: alert,
                    patientName: patientName,
                    iconPath: iconPath,
                    severityColor: severityColor,
                    onStatusTap: () => _mock('Status update'),
                  ),
                  const SizedBox(height: 12),
                  _DetailsCard(alert: alert),
                  if (hasAdditionalContext) ...[
                    const SizedBox(height: 12),
                    _ContextCard(alert: alert),
                  ],
                  if (widget.careRecipient != null) ...[
                    const SizedBox(height: 12),
                    PatientMonitoringDevicesCard(
                      devices: widget.careRecipient!.healthSnapshot.devices,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _TimelineCard(alert: alert),
                  const SizedBox(height: 12),
                  _NotesCard(
                    controller: _noteController,
                    onEdit: () => _mock('Notes'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _PrimaryAction(
                          icon: Icons.phone,
                          label: 'Call',
                          onTap: () => _mock('Call'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PrimaryAction(
                          icon: Icons.message,
                          label: 'Message',
                          onTap: () => _mock('Message'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SecondaryAction(
                          icon: Icons.check,
                          label: 'Acknowledge',
                          onTap: () => _mock('Acknowledge'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SecondaryAction(
                          icon: Icons.check_circle_outline,
                          label: 'Resolve',
                          onTap: () => _mock('Resolve'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final CaregiverAlert alert;
  final String patientName;
  final String iconPath;
  final Color severityColor;
  final VoidCallback onStatusTap;

  const _SummaryCard({
    required this.alert,
    required this.patientName,
    required this.iconPath,
    required this.severityColor,
    required this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool critical = alert.severity == CaregiverAlertSeverity.critical;
    return AleraCard(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: severityColor, width: 7)),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AleraSvgIcon(assetPath: iconPath, width: 70, height: 70),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AleraSvgIcon(
                        assetPath: critical
                            ? 'alera-figma-assets/assets/icons/status/critical.svg'
                            : 'alera-figma-assets/assets/icons/status/warning.svg',
                        width: 22,
                        height: 22,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        critical ? 'CRITICAL' : 'WARNING',
                        style: TextStyle(
                          color: severityColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onStatusTap,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AleraColors.critical.withValues(alpha: .14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            child: Text(
                              _statusLabel(alert.status),
                              style: const TextStyle(
                                color: AleraColors.critical,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    alert.title,
                    style: AleraTypography.pageTitle.copyWith(fontSize: 22),
                  ),
                  Text(
                    '$patientName • Triggered ${_relative(alert.detectedAt)}',
                    style: AleraTypography.body.copyWith(fontSize: 13),
                  ),
                  Text(
                    _dateTime(alert.detectedAt),
                    style: AleraTypography.body.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final CaregiverAlert alert;

  const _DetailsCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final bool heartRate = alert.metric == CaregiverAlertMetric.heartRate;
    final bool spo2 = alert.metric == CaregiverAlertMetric.spo2;
    return _SectionCard(
      title: 'Alert Details',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Reading',
                  value: _number(alert.reading),
                  unit: alert.unit,
                  color: AleraColors.critical,
                  assetPath: heartRate
                      ? 'alera-figma-assets/assets/icons/mini_status/heart_rate.svg'
                      : spo2
                      ? 'alera-figma-assets/assets/icons/mini_status/spo2.svg'
                      : 'alera-figma-assets/assets/icons/mini_status/info.svg',
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'Threshold',
                  value: alert.threshold == null
                      ? '--'
                      : _number(alert.threshold!),
                  unit: alert.unit,
                  color: AleraColors.warning,
                  assetPath:
                      'alera-figma-assets/assets/icons/status/warning.svg',
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'Duration',
                  value: alert.triggerDuration == null
                      ? '--'
                      : '${alert.triggerDuration!.inMinutes}',
                  unit: alert.triggerDuration == null ? '' : 'minutes',
                  color: const Color(0xFFA684FF),
                  assetPath:
                      'alera-figma-assets/assets/icons/mini_status/info.svg',
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'Detected at',
                  value: _time(alert.detectedAt),
                  unit: _period(alert.detectedAt),
                  color: AleraColors.textSecondary,
                  icon: Icons.calendar_today,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  final CaregiverAlert alert;

  const _ContextCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Current Context',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AleraSvgIcon(
            assetPath: 'alera-figma-assets/assets/icons/mini_status/info.svg',
            width: 22,
            height: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evaluation reason',
                  style: AleraTypography.label.copyWith(
                    color: AleraColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  alert.description,
                  style: AleraTypography.body.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final CaregiverAlert alert;

  const _TimelineCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final entries = alert.timeline.isEmpty
        ? [
            AlertTimelineEntry(
              occurredAt: alert.detectedAt,
              title: 'Alert triggered',
              description: '${alert.title} detected',
            ),
          ]
        : alert.timeline;
    return _SectionCard(
      title: 'Timeline',
      child: Column(
        children: [
          for (int index = 0; index < entries.length; index++)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Icon(
                      Icons.circle,
                      color: Color(0xFFA684FF),
                      size: 16,
                    ),
                    if (index != entries.length - 1)
                      Container(
                        width: 2,
                        height: 32,
                        color: AleraColors.primarySoft,
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 70,
                  child: Text(
                    _time(entries[index].occurredAt),
                    style: AleraTypography.body,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entries[index].title,
                        style: AleraTypography.label.copyWith(
                          color: AleraColors.textPrimary,
                        ),
                      ),
                      Text(
                        entries[index].description,
                        style: AleraTypography.body.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onEdit;

  const _NotesCard({required this.controller, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Notes',
      child: TextField(
        controller: controller,
        maxLines: 1,
        onTap: onEdit,
        decoration: InputDecoration(
          hintText: 'Add a note about this alert...',
          hintStyle: const TextStyle(color: Color(0xFFB5A6DB)),
          filled: true,
          fillColor: const Color(0xFFF7F3FF),
          suffixIcon: const Icon(Icons.edit, color: Color(0xFFB5A6DB)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return AleraCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AleraTypography.sectionTitle),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final String? assetPath;
  final IconData? icon;

  const _Metric({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.assetPath,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (assetPath != null)
              AleraSvgIcon(assetPath: assetPath!, width: 17, height: 17)
            else if (icon != null)
              Icon(icon, color: color, size: 17),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            height: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PrimaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17),
        label: Text(label),
        style: FilledButton.styleFrom(backgroundColor: AleraColors.primary),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AleraColors.textSecondary,
          side: BorderSide.none,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}

String _statusLabel(CaregiverAlertStatus status) {
  switch (status) {
    case CaregiverAlertStatus.active:
      return 'Active';
    case CaregiverAlertStatus.acknowledged:
      return 'Acknowledged';
    case CaregiverAlertStatus.resolved:
      return 'Resolved';
  }
}

String _number(double value) =>
    value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

String _time(DateTime value) {
  final int hour = value.hour > 12
      ? value.hour - 12
      : value.hour == 0
      ? 12
      : value.hour;
  return '$hour:${value.minute.toString().padLeft(2, '0')}';
}

String _period(DateTime value) => value.hour >= 12 ? 'PM' : 'AM';

String _dateTime(DateTime value) {
  final DateTime local = value.toLocal();
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime date = DateTime(local.year, local.month, local.day);
  final int dayDifference = today.difference(date).inDays;
  final String time = '${_time(local)} ${_period(local)}';
  if (dayDifference == 0) return 'Today, $time';
  if (dayDifference == 1) return 'Yesterday, $time';
  const List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[local.month - 1]} ${local.day}, ${local.year}, $time';
}

String _relative(DateTime value) {
  final Duration elapsed = DateTime.now().difference(value);
  if (elapsed.isNegative) return 'just now';
  final int minutes = elapsed.inMinutes;
  if (minutes <= 1) return 'just now';
  if (minutes < 60) return '$minutes minute${minutes == 1 ? '' : 's'} ago';
  final int hours = elapsed.inHours;
  if (hours < 24) return '$hours hour${hours == 1 ? '' : 's'} ago';
  final int days = elapsed.inDays;
  if (days < 7) return '$days day${days == 1 ? '' : 's'} ago';
  if (days < 30) {
    final int weeks = days ~/ 7;
    return '$weeks week${weeks == 1 ? '' : 's'} ago';
  }
  if (days < 365) {
    final int months = days ~/ 30;
    return '$months month${months == 1 ? '' : 's'} ago';
  }
  final int years = days ~/ 365;
  return '$years year${years == 1 ? '' : 's'} ago';
}
