import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/alera_spacing.dart';
import '../../design_system/alera_theme.dart';

import '../../design_system/alera_typography.dart';
import 'domain/repositories/caregiver_repository.dart';
import 'domain/models/care_recipient.dart';
import 'domain/models/caregiver_alert.dart';
import 'presentation/home/caregiver_home_page.dart';
import 'presentation/alerts/caregiver_alerts_page.dart';
import 'presentation/alerts/caregiver_alert_detail_page.dart';
import 'presentation/patient_detail/caregiver_patient_detail_page.dart';
import 'presentation/people/caregiver_people_page.dart';

class CaregiverShell extends StatefulWidget {
  final CaregiverRepository repository;

  const CaregiverShell({super.key, required this.repository});

  @override
  State<CaregiverShell> createState() => _CaregiverShellState();
}

class _CaregiverShellState extends State<CaregiverShell> {
  int _selectedIndex = 0;
  late final CareRecipient _homeCareRecipient;

  @override
  void initState() {
    super.initState();
    _homeCareRecipient = widget.repository.getCareRecipients().first;
  }

  void _openCareRecipient(BuildContext context, CareRecipient careRecipient) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => CaregiverPatientDetailPage(
          careRecipient: careRecipient,
          alerts: widget.repository
              .getAlerts()
              .where((alert) => alert.careRecipientId == careRecipient.id)
              .toList(),
          reminders: widget.repository
              .getReminders()
              .where((reminder) => reminder.careRecipientId == careRecipient.id)
              .toList(),
          onViewAllAlerts: () {
            Navigator.pop(context);
            setState(() => _selectedIndex = 2);
          },
          onViewAllReminders: () {
            Navigator.pop(context);
            setState(() => _selectedIndex = 3);
          },
          onAlertTap: (alert) => _openAlertDetail(context, alert),
        ),
      ),
    );
  }

  void _openAlertDetail(BuildContext context, CaregiverAlert alert) {
    CareRecipient? recipient;
    for (final CareRecipient candidate
        in widget.repository.getCareRecipients()) {
      if (candidate.id == alert.careRecipientId) {
        recipient = candidate;
        break;
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            CaregiverAlertDetailPage(alert: alert, careRecipient: recipient),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SystemUiOverlayStyle systemBarStyle = _selectedIndex == 0
        ? const SystemUiOverlayStyle(
            statusBarColor: Color(0xFFB590F0),
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemStatusBarContrastEnforced: false,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Theme.of(context).colorScheme.surface,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemStatusBarContrastEnforced: false,
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemBarStyle,
      child: Theme(
        data: AleraTheme.caregiver(Theme.of(context)),
        child: Builder(
          builder: (context) {
            return Scaffold(
              body: SafeArea(
                bottom: false,
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    CaregiverHomePage(
                      careRecipient: _homeCareRecipient,
                      alerts: widget.repository
                          .getAlerts()
                          .where(
                            (alert) =>
                                alert.careRecipientId == _homeCareRecipient.id,
                          )
                          .toList(),
                      reminders: widget.repository
                          .getReminders()
                          .where(
                            (reminder) =>
                                reminder.careRecipientId ==
                                _homeCareRecipient.id,
                          )
                          .toList(),
                      onViewAllAlerts: () {
                        setState(() => _selectedIndex = 2);
                      },
                      onViewAllReminders: () {
                        setState(() => _selectedIndex = 3);
                      },
                      onAlertTap: (alert) => _openAlertDetail(context, alert),
                    ),
                    CaregiverPeoplePage(
                      careRecipients: widget.repository.getCareRecipients(),
                      onCareRecipientSelected: (careRecipient) =>
                          _openCareRecipient(context, careRecipient),
                    ),
                    CaregiverAlertsPage(
                      alerts: widget.repository.getAlerts(),
                      careRecipients: widget.repository.getCareRecipients(),
                      onAlertTap: (alert) => _openAlertDetail(context, alert),
                    ),
                    const _PlaceholderPage(
                      title: 'Reminders',
                      isTemporary: true,
                    ),
                    const _PlaceholderPage(title: 'More', isTemporary: true),
                  ],
                ),
              ),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface, // Matches the navbar background
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06), // Subtle shadow
                      blurRadius: 5,
                      offset: const Offset(
                        0,
                        -3,
                      ), // Negative Y casts the shadow upward
                    ),
                  ],
                ),
                child: NavigationBar(
                  elevation:
                      0, // Removes M3's default tint elevation so your custom shadow handles depth
                  height: 68,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.grid_view_outlined),
                      selectedIcon: Icon(Icons.grid_view_rounded),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.people_outline),
                      selectedIcon: Icon(Icons.people),
                      label: 'People',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.notifications_none),
                      selectedIcon: Icon(Icons.notifications),
                      label: 'Alerts',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.schedule_outlined),
                      selectedIcon: Icon(Icons.schedule),
                      label: 'Reminders',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.menu),
                      label: 'More',
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  final bool isTemporary;

  const _PlaceholderPage({required this.title, this.isTemporary = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AleraSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AleraTypography.pageTitle),
          const Spacer(),
          Center(
            child: Text(
              isTemporary
                  ? 'Temporary $title placeholder'
                  : '$title screen placeholder',
              style: AleraTypography.body,
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
