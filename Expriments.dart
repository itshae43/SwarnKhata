import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Light cream background
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // Smooth scroll effect
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            _buildProfileHeader(),  
            _buildGridCard(), 
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildProfileHeader() {
  return Row(
    children: [
      const CircleAvatar(radius: 20, backgroundImage: NetworkImage('...')),
      const SizedBox(width: 12),
      Expanded(child: Text('Shailendra Singh', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold))),
      const Icon(Icons.notifications_none_outlined, size: 28),
    ],
  );
}

Widget _buildGridCard() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFFEFE7DA),
        width: 1,
      ),
      boxShadow: [
       BoxShadow(
         color: const Color(0xFF2C3E50).withOpacity(0.05),
         blurRadius: 12,
        offset: const Offset(0, 4),
    ),
  ],
      
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: const Text('icon'),
        ),
      ]
    ),
  );
}