import 'package:flutter/material.dart';

import '../features/caregiver/data/mock/mock_caregiver_repository.dart';
import '../features/caregiver/presentation/auth/caregiver_auth_gate.dart';

class CaregiverInterface extends StatelessWidget {
  const CaregiverInterface({super.key});

  @override
  Widget build(BuildContext context) {
    return const CaregiverAuthGate(repository: MockCaregiverRepository());
  }
}
