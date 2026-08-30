import 'package:flutter/material.dart';

class CaregiverInterface extends StatelessWidget {
  const CaregiverInterface({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: const Text(
            'Alera - Caregiver',
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(
                text: 'Patients',
              ),
              Tab(
                text: 'Alerts',
              ),
              Tab(
                text: 'Reminders',
              ),
            ],
          ),
        ),

        body: const TabBarView(
          children: [
            // PATIENTS TAB
            SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Patients',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(
                    height: 16,
                  ),

                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.person,
                      ),
                      title: Text(
                        'Elderly Patient',
                      ),
                      subtitle: Text(
                        'View patient health information',
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ALERTS TAB
            Center(
              child: Text(
                'Alerts',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),

            // REMINDERS TAB
            Center(
              child: Text(
                'Reminders',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}