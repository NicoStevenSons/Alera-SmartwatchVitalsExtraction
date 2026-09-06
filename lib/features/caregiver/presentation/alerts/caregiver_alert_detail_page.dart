import 'package:flutter/material.dart';

import '../../../../design_system/alera_colors.dart';
import '../../../../design_system/alera_typography.dart';
import '../../../../design_system/widgets/alera_button.dart';
import '../../../../design_system/widgets/alera_card.dart';
import '../../../../design_system/widgets/alera_svg_icon.dart';
import '../../domain/models/care_recipient.dart';
import '../../domain/models/caregiver_alert.dart';

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
  void initState() {
    super.initState();
    _noteController.text = widget.alert.note ?? '';
  }

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
                  const SizedBox(height: 12),
                  _ContextCard(careRecipient: widget.careRecipient),
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
                        child: AleraButton(
                          icon: Icons.phone,
                          label: 'Call',
                          onPressed: () => _mock('Call'),
                          height: 48,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AleraButton(
                          icon: Icons.message,
                          label: 'Message',
                          onPressed: () => _mock('Message'),
                          height: 48,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AleraButton(
                          icon: Icons.check,
                          label: 'Acknowledge',
                          onPressed: () => _mock('Acknowledge'),
                          variant: AleraButtonVariant.white,
                          height: 48,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AleraButton(
                          icon: Icons.check_circle_outline,
                          label: 'Resolve',
                          onPressed: () => _mock('Resolve'),
                          variant: AleraButtonVariant.white,
                          height: 48,
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
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: ColoredBox(
              color: severityColor,
              child: const SizedBox(width: 7),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
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
                            color: AleraColors.critical.withOpacity(0.14),
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
        ],
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
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFFA684FF),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert.description.trim().isEmpty
                        ? 'No additional alert description is available.'
                        : alert.description,
                    style: AleraTypography.body.copyWith(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  final CareRecipient? careRecipient;

  const _ContextCard({required this.careRecipient});

  @override
  Widget build(BuildContext context) {
    final snapshot = careRecipient?.healthSnapshot;
    return _SectionCard(
      title: 'Current Context',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            snapshot == null
                ? 'Latest patient readings are unavailable.'
                : 'Latest available • ${_dateTime(snapshot.lastCheckIn)}',
            style: AleraTypography.body.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              _ContextMetric(
                icon: Icons.favorite_outline,
                label: 'Heart Rate',
                value: snapshot?.heartRateBpm?.toString() ?? '--',
                unit: snapshot?.heartRateBpm == null ? '' : 'BPM',
              ),
              _ContextMetric(
                icon: Icons.water_drop_outlined,
                label: 'SpO₂',
                value: snapshot?.spo2Percent == null
                    ? '--'
                    : _number(snapshot!.spo2Percent!),
                unit: snapshot?.spo2Percent == null ? '' : '%',
              ),
              _ContextMetric(
                icon: Icons.directions_walk,
                label: 'Steps',
                value: snapshot?.steps?.toString() ?? '--',
                unit: '',
              ),
              _ContextMetric(
                icon: Icons.psychology_outlined,
                label: 'Stress',
                value: snapshot?.stressLabel.trim().isEmpty ?? true
                    ? '--'
                    : snapshot!.stressLabel,
                unit: '',
              ),
            ],
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
    final entries = _timelineEntries(alert);
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
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => onEdit(),
        style: const TextStyle(fontSize: 13), // Slightly smaller text fit
        decoration: InputDecoration(
          isDense: true, // 1. Reduces vertical height constraints
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8, // 2. Controls vertical height (lower = slimmer)
          ),
          hintText: 'Add a note about this alert...',
          hintStyle: const TextStyle(color: Color(0xFFB5A6DB), fontSize: 13),
          filled: true,
          fillColor: const Color(0xFFF7F3FF),
          
          // 3. Constrains the suffix container size
          suffixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Container(
              width: 28, // 4. Direct control over pen circle size
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFE9DFFF),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Save note',
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF9A79E8),
                  size: 15,
                ),
              ),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20), // Reduced border radius to match smaller height
            borderSide: const BorderSide(color: Color(0xFFE0D6F5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: AleraColors.primary,
              width: 1.5,
            ),
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

class _ContextMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  const _ContextMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final double width = (MediaQuery.sizeOf(context).width - 72) / 2;
    return SizedBox(
      width: width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: AleraColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AleraTypography.body.copyWith(fontSize: 11),
                ),
                Text(
                  value,
                  style: AleraTypography.sectionTitle.copyWith(fontSize: 18),
                ),
                if (unit.isNotEmpty)
                  Text(
                    unit,
                    style: AleraTypography.body.copyWith(fontSize: 10),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<AlertTimelineEntry> _timelineEntries(CaregiverAlert alert) {
  final entries = <AlertTimelineEntry>[...alert.timeline];
  final bool hasInitialTrigger = entries.any(
    (entry) =>
        entry.occurredAt == alert.detectedAt &&
        entry.title.toLowerCase() == 'alert triggered',
  );
  if (!hasInitialTrigger) {
    entries.add(
      AlertTimelineEntry(
        occurredAt: alert.detectedAt,
        title: 'Alert triggered',
        description: '${alert.title} detected at ${_number(alert.reading)} ${alert.unit}',
      ),
    );
  }

  final DateTime? resolvedAt = alert.resolvedAt;
  if (resolvedAt != null &&
      !entries.any((entry) => entry.title.toLowerCase() == 'alert resolved')) {
    entries.add(
      AlertTimelineEntry(
        occurredAt: resolvedAt,
        title: 'Alert resolved',
        description: 'The alert was marked as resolved.',
      ),
    );
  }

  entries.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
  return entries;
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
  final DateTime local = value.toLocal();
  final int hour = local.hour > 12
      ? local.hour - 12
      : local.hour == 0
      ? 12
      : local.hour;
  return '$hour:${local.minute.toString().padLeft(2, '0')}';
}

String _period(DateTime value) => value.toLocal().hour >= 12 ? 'PM' : 'AM';

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
