import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [Icon(Icons.school), SizedBox(width: 8), Text('Tutorial')],
        ),
      ),
      body: const Center(child: Text('Tutorial Screen')),
    );
  }
}
