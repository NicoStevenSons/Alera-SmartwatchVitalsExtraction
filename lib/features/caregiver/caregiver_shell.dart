import 'package:flutter/material.dart';

import '../../design_system/alera_spacing.dart';
import '../../design_system/alera_theme.dart';
import '../../design_system/alera_typography.dart';
import 'domain/repositories/caregiver_repository.dart';
import 'domain/models/care_recipient.dart';
import 'presentation/people/caregiver_people_page.dart';

class CaregiverShell extends StatefulWidget {
  final CaregiverRepository repository;

  const CaregiverShell({super.key, required this.repository});

  @override
  State<CaregiverShell> createState() => _CaregiverShellState();
}

class _CaregiverShellState extends State<CaregiverShell> {
  int _selectedIndex = 0;
  CareRecipient? _selectedCareRecipient;

  void _selectCareRecipient(CareRecipient careRecipient) {
    setState(() {
      _selectedCareRecipient = careRecipient;
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AleraTheme.caregiver(Theme.of(context)),
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: SafeArea(
              bottom: false,
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _PlaceholderPage(
                    key: ValueKey(
                      'selected-patient-${_selectedCareRecipient?.id}',
                    ),
                    title: 'Home',
                  ),
                  CaregiverPeoplePage(
                    careRecipients: widget.repository.getCareRecipients(),
                    onCareRecipientSelected: _selectCareRecipient,
                  ),
                  const _PlaceholderPage(title: 'Alerts'),
                  const _PlaceholderPage(title: 'Reminders', isTemporary: true),
                  const _PlaceholderPage(title: 'More', isTemporary: true),
                ],
              ),
            ),
            bottomNavigationBar: NavigationBar(
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
                NavigationDestination(icon: Icon(Icons.menu), label: 'More'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  final bool isTemporary;

  const _PlaceholderPage({
    super.key,
    required this.title,
    this.isTemporary = false,
  });

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
