import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline PDF Scanner')),
      body: const Center(child: Text('Recent documents will appear here.')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/capture'),
        label: const Text('New Scan'),
        icon: const Icon(Icons.camera_alt_outlined),
      ),
    );
  }
}
