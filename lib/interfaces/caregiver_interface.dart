import 'package:flutter/material.dart';

import '../features/caregiver/caregiver_shell.dart';
import '../features/caregiver/data/mock/mock_caregiver_repository.dart';

class CaregiverInterface extends StatelessWidget {
  const CaregiverInterface({super.key});

  @override
  Widget build(BuildContext context) {
    return const CaregiverShell(repository: MockCaregiverRepository());
  }
}
