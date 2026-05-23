import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<AppProvider>(context);

    return Scaffold(

      appBar: AppBar(
        title: const Text("Fitness Planner"),
      ),

      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Text(
              "Total Workouts: ${provider.workoutLogs.length}",

              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Completed This Week: ${provider.thisWeekCompletedCount}",

              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 30),

            if (provider.dailyTip.isNotEmpty)

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Card(

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Text(
                      provider.dailyTip,

                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}