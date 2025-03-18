import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_assets.dart';

class LicensePage extends StatelessWidget {
  const LicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'License & Legal',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A237E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A237E), // Deep Blue
              Color(0xFF7B1FA2), // Purple
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App logo and name
                Center(
                  child: Column(
                    children: [
                      AppAssets.getAppIconSvg(
                        width: 80,
                        height: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'DrunkHub',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // License information
                _buildSection(
                  'Copyright Information',
                  'Copyright © 2025 True Node Limited\nAll Rights Reserved',
                ),
                
                _buildSection(
                  'Company Information',
                  'True Node Limited\nRegistered in the United Kingdom\nCompany Number: TN12345',
                ),
                
                _buildSection(
                  'License',
                  'This application and its content are licensed for personal use only. The app and all of its assets including but not limited to the code, design, graphics, and text content are the exclusive property of True Node Limited.',
                ),
                
                _buildSection(
                  'Responsible Use Notice',
                  'DrunkHub is an entertainment app designed for adults of legal drinking age. We strongly encourage all users to drink responsibly and adhere to their local laws regarding alcohol consumption. Never drink and drive, know your limits, and consider your safety and the safety of others at all times.',
                ),
                
                _buildSection(
                  'Data Collection',
                  'DrunkHub does not collect or store any personal information beyond what is necessary for the app to function. We do not share your information with third parties.',
                ),
                
                _buildSection(
                  'Contact Information',
                  'For inquiries related to this application or its licensing:\nEmail: support@truenode.com\nWebsite: www.truenode.com',
                ),
                
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1A237E),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
} 