import 'package:flutter/material.dart';

import '../../../../design_system/alera_colors.dart';
import '../../../../design_system/alera_spacing.dart';
import '../../../../design_system/alera_typography.dart';
import '../../../../design_system/widgets/alera_card.dart';
import '../../domain/models/care_recipient.dart';
import 'widgets/care_recipient_card.dart';

class CaregiverPeoplePage extends StatelessWidget {
  final List<CareRecipient> careRecipients;
  final ValueChanged<CareRecipient> onCareRecipientSelected;
  final VoidCallback? onAddPatient;

  const CaregiverPeoplePage({
    super.key,
    required this.careRecipients,
    required this.onCareRecipientSelected,
    this.onAddPatient,
  });

  void _showMockFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AleraColors.surface,
          padding: const EdgeInsets.fromLTRB(
            AleraSpacing.medium,
            4,
            AleraSpacing.medium,
            4,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'People',
                  style: AleraTypography.pageTitle.copyWith(fontSize: 24),
                ),
              ),
              IconButton(
                tooltip: 'Filter people',
                color: AleraColors.primarySoft,
                iconSize: 26,
                onPressed: () => _showMockFeedback(
                  context,
                  'People filters are not available in the mock yet.',
                ),
                icon: const Icon(Icons.filter_list),
              ),
              IconButton(
                tooltip: 'Edit people',
                color: AleraColors.primarySoft,
                iconSize: 26,
                onPressed: () => _showMockFeedback(
                  context,
                  'Editing people is not available in the mock yet.',
                ),
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            key: const PageStorageKey<String>('caregiver-people-list'),
            padding: const EdgeInsets.fromLTRB(
              AleraSpacing.medium,
              12,
              AleraSpacing.medium,
              AleraSpacing.medium,
            ),
            itemCount: careRecipients.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index < careRecipients.length) {
                final CareRecipient recipient = careRecipients[index];
                return CareRecipientCard(
                  careRecipient: recipient,
                  onTap: () => onCareRecipientSelected(recipient),
                );
              }

              return _AddPatientButton(
                onPressed:
                    onAddPatient ??
                    () => _showMockFeedback(
                      context,
                      'Adding a patient is not available in the mock yet.',
                    ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AddPatientButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddPatientButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AleraCard(
      padding: EdgeInsets.zero,
      onTap: onPressed,
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 24, color: AleraColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              'Add Patient',
              style: AleraTypography.label.copyWith(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
