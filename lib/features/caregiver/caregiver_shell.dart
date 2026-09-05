import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/alera_spacing.dart';
import '../../design_system/alera_theme.dart';

import '../../design_system/alera_typography.dart';
import 'domain/repositories/caregiver_repository.dart';
import 'domain/models/care_recipient.dart';
import 'domain/models/caregiver_alert.dart';
import 'data/api/caregiver_alert_api_data_source.dart';
import 'data/api/caregiver_patient_api_data_source.dart';
import 'data/api/dto/patient_dto.dart';
import 'domain/models/health_snapshot.dart';
import 'presentation/home/caregiver_home_page.dart';
import 'presentation/alerts/caregiver_alerts_page.dart';
import 'presentation/alerts/caregiver_alert_detail_page.dart';
import 'presentation/patient_detail/caregiver_patient_detail_page.dart';
import 'presentation/people/caregiver_people_page.dart';
import 'presentation/people/add_patient_page.dart';
import '../../services/alert_notification.dart';

class CaregiverShell extends StatefulWidget {
  final CaregiverRepository repository;
  final CaregiverAlertDataSource? alertDataSource;
  final CaregiverPatientDataSource? patientDataSource;
  final String? householdCode;
  final VoidCallback? onSignOut;
  final Future<CaregiverAlert> Function(String)? loadNotificationAlert;
  final NotificationTapBus? notificationTapBus;

  const CaregiverShell({
    super.key,
    required this.repository,
    this.alertDataSource,
    this.patientDataSource,
    this.householdCode,
    this.onSignOut,
    this.loadNotificationAlert,
    this.notificationTapBus,
  });

  @override
  State<CaregiverShell> createState() => _CaregiverShellState();
}

class _CaregiverShellState extends State<CaregiverShell> {
  int _selectedIndex = 0;
  void Function()? _unsubscribeNotifications;
  int _notificationRevision = 0;
  late final CareRecipient _homeCareRecipient;
  late final List<CareRecipient> _careRecipients;

  @override
  void initState() {
    super.initState();
    _careRecipients = widget.repository.getCareRecipients().toList();
    _homeCareRecipient = _careRecipients.first;
    // AuthGate supplies this loader only for an active caregiver session.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.loadNotificationAlert == null) return;
      _unsubscribeNotifications =
          (widget.notificationTapBus ?? NotificationTapBus.instance).subscribe(
            _openNotificationAlert,
          );
    });
  }

  @override
  void dispose() {
    _unsubscribeNotifications?.call();
    super.dispose();
  }

  Future<void> _openNotificationAlert(AlertNotification event) async {
    final revision = ++_notificationRevision;
    try {
      final alert = await widget.loadNotificationAlert!(event.alertId);
      if (!mounted || revision != _notificationRevision) return;
      if (alert.id.toLowerCase() != event.alertId ||
          alert.status == CaregiverAlertStatus.resolved) {
        _notificationUnavailable();
        return;
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
      setState(() => _selectedIndex = 2);
      _openAlertDetail(context, alert);
    } catch (error) {
      if (!mounted || revision != _notificationRevision) return;
      // The API clears a 401 session; let AuthGate discard its routes.
      if (error is CaregiverAlertsAuthFailure && error.statusCode == 401) {
        return;
      }
      _notificationUnavailable();
    }
  }

  void _notificationUnavailable() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _selectedIndex = 2);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This alert is no longer available.')),
    );
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

  void _openAddPatient(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AddPatientPage(
          dataSource:
              widget.patientDataSource ?? CaregiverPatientApiDataSource(),
          householdCode: widget.householdCode,
          onPatientCreated: _addCreatedPatient,
        ),
      ),
    );
  }

  void _addCreatedPatient(PatientCreatedResponse patient) {
    if (_careRecipients.any((item) => item.id == patient.patientId)) return;
    setState(() {
      _careRecipients.add(
        CareRecipient(
          id: patient.patientId,
          name: patient.fullName,
          relationshipLabel: 'Under your care',
          status: CareStatus.stable,
          alertCount: 0,
          reminderCount: 0,
          quickMessages: const [],
          healthSnapshot: HealthSnapshot(
            heartRateBpm: patient.baselineHeartRate?.round(),
            spo2Percent: patient.baselineSpo2,
            steps: null,
            stressLabel: 'No data',
            sleepDuration: Duration.zero,
            careRiskScore: 0,
            careRiskLabel: 'Not assessed',
            lastCheckIn: patient.createdAt,
            devices: const [],
          ),
        ),
      );
    });
  }

  void _openAlertDetail(BuildContext context, CaregiverAlert alert) {
    CareRecipient? recipient;
    for (final CareRecipient candidate in _careRecipients) {
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
                      careRecipients: _careRecipients,
                      onCareRecipientSelected: (careRecipient) =>
                          _openCareRecipient(context, careRecipient),
                      onAddPatient: () => _openAddPatient(context),
                    ),
                    CaregiverAlertsPage(
                      alerts: widget.repository.getAlerts(),
                      careRecipients: _careRecipients,
                      alertDataSource:
                          widget.alertDataSource ??
                          _RepositoryAlertDataSource(widget.repository),
                      onAlertTap: (alert) => _openAlertDetail(context, alert),
                    ),
                    const _PlaceholderPage(
                      title: 'Reminders',
                      isTemporary: true,
                    ),
                    _PlaceholderPage(
                      title: 'More',
                      isTemporary: true,
                      onSignOut: widget.onSignOut,
                    ),
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
                      color: Colors.black.withValues(
                        alpha: 0.06,
                      ), // Subtle shadow
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

class _RepositoryAlertDataSource implements CaregiverAlertDataSource {
  final CaregiverRepository repository;

  const _RepositoryAlertDataSource(this.repository);

  @override
  Future<List<CaregiverAlert>> fetchAlerts() async => repository.getAlerts();
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  final bool isTemporary;
  final VoidCallback? onSignOut;

  const _PlaceholderPage({
    required this.title,
    this.isTemporary = false,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AleraSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AleraTypography.pageTitle),
          if (onSignOut != null)
            TextButton.icon(
              onPressed: onSignOut,
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
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
