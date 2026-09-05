import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/elderly_reminder.dart';

class ElderlyReminderSupabaseService {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<List<ElderlyReminder>> getRemindersForPatient(
    String patientId,
  ) async {
    final response =
        await _supabase
            .from('reminder_occurrences')
            .select('''
              reminder_occurrence_id,
              reminder_template_id,
              scheduled_at,
              due_at,
              status,
              reminder_templates!inner(
                patient_id,
                title,
                instructions,
                category,
                priority,
                snooze_allowed,
                default_snooze_minutes
              )
            ''')
            .eq(
              'reminder_templates.patient_id',
              patientId,
            )
            .order(
              'due_at',
              ascending: true,
            );

    return (response as List)
        .map(
          (json) => ElderlyReminder.fromSupabase(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}