import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'Services/background_sync_service.dart';
import 'interfaces/interface_selection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Workmanager().initialize(
    callbackDispatcher,
  );

  await Workmanager().registerPeriodicTask(
    'alera-periodic-health-upload',
    aleraBackgroundSyncTask,
    frequency: const Duration(
      minutes: 15,
    ),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );

  runApp(const AleraApp());
}

class AleraApp extends StatelessWidget {
  const AleraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InterfaceSelection(),
    );
  }
}