import 'package:flutter/material.dart';

import '../models/heart_rate_data.dart';

class HeartRateDisplay extends StatelessWidget {
  final HeartRateData heartRateData;

  const HeartRateDisplay({
    super.key,
    required this.heartRateData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
      ),
      child: Padding(padding: const EdgeInsetsGeometry.all(16),
      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Row(//IconRow
                    children: [const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      ),
                      const SizedBox(width: 8),

                       Text('Heart Rate'),
                      
                      ],
                  ),

                  
                  Padding(
                    padding: const EdgeInsets.only(top: 70),
                    child: Row(children: [
                        Text('${heartRateData.displayedHeartRate} BPM',
                        style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                        ),)
                    ],),
                  )
              ],
      ),  
      
      )
    );
  }
}