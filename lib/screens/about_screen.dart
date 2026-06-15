import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.info),
            SizedBox(width: 8),
            Text('Über die App'),
          ],
        ),
      ),
      body: const Center(child: Text('Einfach die süßen Jungs')),
    );
  }
}
