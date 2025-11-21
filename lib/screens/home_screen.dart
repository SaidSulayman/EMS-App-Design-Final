import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/emergency_provider.dart';
import '../widgets/emergency_selector.dart';
import '../widgets/tracking_view.dart';
import '../widgets/rating_view.dart';
import '../widgets/trip_history_view.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emergencyProvider = context.watch<EmergencyProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_hospital, color: Colors.red),
            SizedBox(width: 8),
            Text('MediRide'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          PopupMenuButton<int>(
            icon: CircleAvatar(
              backgroundColor: Colors.red.shade100,
              child: Text(
                user?.initials ?? 'U',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            onSelected: (value) {
              if (value == 1) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              } else if (value == 2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon')),
                );
              } else if (value == 3) {
                context.read<AuthProvider>().logout();
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<int>>[
              PopupMenuItem<int>(
                enabled: false,
                child: Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? 'User'),
                        Text(
                          user?.email ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: 12),
                    Text('Profile', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: Row(
                  children: [
                    const Icon(Icons.settings_outlined),
                    const SizedBox(width: 12),
                    Text('Settings', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const PopupMenuItem<int>(
                value: 3,
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Log out', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(context, emergencyProvider),
      bottomNavigationBar: emergencyProvider.appState == AppState.home
          ? BottomNavigationBar(
              currentIndex: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              onTap: (index) {
                if (index == 1) {
                  emergencyProvider.showHistory();
                } else if (index == 2) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                }
              },
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, EmergencyProvider provider) {
    switch (provider.appState) {
      case AppState.home:
      case AppState.selecting:
        return const EmergencySelector();
      case AppState.requesting:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text(
                'Finding nearest ambulance...',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Please wait',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      case AppState.tracking:
        return const TrackingView();
      case AppState.completed:
        return const RatingView();
      case AppState.history:
        return const TripHistoryView();
    }
  }
}
