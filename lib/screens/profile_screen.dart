import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/emergency_provider.dart';
import '../services/firebase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  int _tripCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTripCount();
  }

  Future<void> _loadTripCount() async {
    final userId = _firebaseService.currentUser?.uid;
    if (userId != null) {
      final count = await _firebaseService.getTripCount(userId);
      if (mounted) {
        setState(() {
          _tripCount = count;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final emergency = context.watch<EmergencyProvider>();
    final localTripCount = emergency.tripHistory.length;
    final totalTripCount = _tripCount + localTripCount;
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.red.shade100,
                        child: Text(
                          user?.initials ?? 'U',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name.isNotEmpty == true ? user!.name : 'Guest User',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'No email on file',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      _StatTile(
                        label: 'Trips requested',
                        value: _isLoading ? '...' : totalTripCount.toString(),
                        icon: Icons.history,
                      ),
                      const VerticalDivider(width: 32),
                      _StatTile(
                        label: 'Phone',
                        value: user?.phone ?? 'Not provided',
                        icon: Icons.phone,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Name'),
                      subtitle: Text(user?.name ?? 'Guest'),
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(user?.email ?? 'Not set'),
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.phone_outlined),
                      title: const Text('Phone'),
                      subtitle: Text(user?.phone ?? 'Not set'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Need to update your information? Contact MediRide support and we’ll help you keep your details accurate.',
                style: TextStyle(color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.red.shade600),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

