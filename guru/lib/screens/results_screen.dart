import 'package:flutter/material.dart';
import '../services/mock_data.dart';
import 'assessments_screen.dart';

class ResultsScreen extends StatelessWidget {
  final int score;
  final String testType;
  const ResultsScreen({super.key, required this.score, required this.testType});

  @override
  Widget build(BuildContext context) {
    mockResults.add(AssessmentResult(testType: testType, score: score, date: DateTime.now()));

    int previousBest = 0;
    if (testType == 'Vertical Jump') {
      previousBest = mockResults.where((r) => r.testType == testType).map((r) => r.score).fold(0, (max, e) => e > max ? e : max);
    }
    bool isPersonalBest = score > previousBest;

    return Scaffold(
      appBar: AppBar(title: const Text('Test Complete')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your Score:', style: Theme.of(context).textTheme.headlineMedium),
            Text('$score', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (isPersonalBest)
              const Text('🎉 New Personal Best!', style: TextStyle(fontSize: 20, color: Colors.green)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Back to Assessments'),
            ),
          ],
        ),
      ),
    );
  }
}