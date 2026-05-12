import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Header
            Row(
              children: [
                // Profile Image with Gold Border
                Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF8A7311),
                      width: 1.5,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=shailendra'),
                  ),
                ),
                const SizedBox(width: 12),
                // Name
                const Expanded(
                  child: Text(
                    'Shailendra Singh',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B5800), // Slightly darker gold/brown
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                // Notification Icon
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_none_outlined, // More similar to the image
                    color: Color(0xFF4A3E1F),
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Other content can go here
            const Center(
              child: Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
