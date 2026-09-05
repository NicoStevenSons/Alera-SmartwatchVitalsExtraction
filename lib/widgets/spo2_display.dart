import 'package:flutter/material.dart';

import '../models/spo2_data.dart';

class SpO2Display extends StatelessWidget {
  final SpO2Data spo2Data;

  const SpO2Display({super.key, required this.spo2Data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bloodtype, color: Colors.red),

                Text('SpO2'),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Row(
                children: [
                  Text(
                    '${spo2Data.displayedPercent}%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
