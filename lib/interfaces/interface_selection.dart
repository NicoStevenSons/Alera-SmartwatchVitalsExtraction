import 'package:flutter/material.dart';

import 'elderly_interface.dart';
import 'caregiver_interface.dart';

class InterfaceSelection extends StatelessWidget {
  const InterfaceSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Alera'),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Text(
                'Choose Interface',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ElderlyInterface(),
                      ),
                    );
                  },
                  child: const Text('Elderly Interface'),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CaregiverInterface(),
                      ),
                    );
                  },
                  child: const Text('Caregiver Interface'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
