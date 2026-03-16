// Legacy soccer screen from the betting UI design is no longer used.
// Keeping the file minimal to avoid linter errors while preserving history.

import 'package:flutter/material.dart';

class SoccerScreen extends StatelessWidget {
  const SoccerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Soccer screen is deprecated in Cricbuzz app.'),
      ),
    );
  }
}

