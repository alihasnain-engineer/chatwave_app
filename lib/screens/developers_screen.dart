import 'package:flutter/material.dart';

class DevelopersScreen extends StatelessWidget {
  const DevelopersScreen({super.key});

  // Developer information - easily extendable
  static const List<Map<String, dynamic>> developers = [
    {
      'name': 'Ali Hasnain',
      'role': 'Frontend Developer',
      'image': 'assets/developers/ali.png',
      'color': Colors.blue,
    },
    {
      'name': 'Dawood',
      'role': 'Backend Developer',
      'image': 'assets/developers/dawood.png',
      'color': Colors.green,
    },
    {
      'name': 'Ahmad Yasin',
      'role': 'UI/UX Designer',
      'image': 'assets/developers/ahmadyaseen.png',
      'color': Colors.purple,
    },
    {
      'name': 'Ahmad',
      'role': 'Full Stack Developer',
      'image': 'assets/developers/ahmad.png',
      'color': Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Credits'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade400,
                          Colors.purple.shade400,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.code,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Developed by',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ChatWave Team',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Developer List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: developers.length,
                itemBuilder: (context, index) {
                  final dev = developers[index];
                  return _DeveloperCard(
                    name: dev['name'] as String,
                    role: dev['role'] as String,
                    imagePath: dev['image'] as String,
                    color: dev['color'] as Color,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeveloperCard extends StatelessWidget {
  final String name;
  final String role;
  final String imagePath;
  final Color color;

  const _DeveloperCard({
    required this.name,
    required this.role,
    required this.imagePath,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                color,
                color.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: _buildAvatar(),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              role,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    // Try to load image from assets, fallback to icon
    try {
      return ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            );
          },
        ),
      );
    } catch (e) {
      return const Icon(
        Icons.person,
        color: Colors.white,
        size: 30,
      );
    }
  }
}

