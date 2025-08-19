import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/car_card.dart';
import '../providers/car_provider.dart';
import '../services/database_service.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseService _databaseService = DatabaseService();
  int _carsListed = 0;
  int _favorites = 0;
  String _userName = 'Yusuf Osama';
  String _userEmail = 'yusuf@example.com';
  String _userLocation = 'Alexandria, EG';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      await _databaseService.ensureInitialized();

      // Get user data (using first user as default for demo)
      final users = await _databaseService.getAllUsers();
      if (users.isNotEmpty) {
        final user = users.first;
        _userName = user.name;
        _userEmail = user.email;
        _userLocation = user.location;
        _carsListed = user.listedCarIds.length;
        _favorites = user.favoriteCarIds.length;
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _userEmail,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _userLocation,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Quick Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Cars Listed', _carsListed.toString()),
                _buildStatCard('Favorites', _favorites.toString()),
              ],
            ),
            const SizedBox(height: 32),

            // Settings
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Manage your notifications',
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.security,
              title: 'Privacy',
              subtitle: 'Manage your privacy settings',
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.help,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.info,
              title: 'About',
              subtitle: 'App version and information',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
