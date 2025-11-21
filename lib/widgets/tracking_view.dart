import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:provider/provider.dart';

import '../models/emergency_model.dart';
import '../providers/emergency_provider.dart';
import 'ambulance_icon.dart';

class TrackingView extends StatefulWidget {
  const TrackingView({super.key});

  @override
  State<TrackingView> createState() => _TrackingViewState();
}

class _TrackingViewState extends State<TrackingView> {
  @override
  void initState() {
    super.initState();
    context.read<EmergencyProvider>().getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmergencyProvider>();
    final userPos = provider.userLocation;
    final ambulancePos = provider.ambulanceLocation;
    final centerPoint = ambulancePos ?? userPos;
    final emergency = provider.selectedEmergency;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF5F5), Color(0xFFFEE2E2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Full screen map
          if (centerPoint != null)
            FlutterMap(
              options: MapOptions(
                initialCenter: centerPoint,
                initialZoom: 14,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.mediride',
                  tileProvider: CancellableNetworkTileProvider(),
                ),
                if (provider.ambulanceRoute.length > 1 || provider.userTrail.length > 1)
                  PolylineLayer(
                    polylines: [
                      if (provider.ambulanceRoute.length > 1)
                        Polyline(
                          points: provider.ambulanceRoute,
                          color: Colors.red.shade600,
                          strokeWidth: 4,
                        ),
                      if (provider.userTrail.length > 1)
                        Polyline(
                          points: provider.userTrail,
                          color: Colors.blue.shade400,
                          strokeWidth: 3,
                          borderColor: Colors.blue.shade100,
                          borderStrokeWidth: 1,
                        ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (userPos != null)
                      Marker(
                        point: userPos,
                        width: 46,
                        height: 46,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_pin_circle,
                              size: 40,
                              color: Colors.blueAccent,
                            ),
                            Text(
                              'You',
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    if (ambulancePos != null)
                      Marker(
                        point: ambulancePos,
                        width: 56,
                        height: 56,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AmbulanceIcon(size: 48, color: Colors.red),
                            SizedBox(height: 2),
                            Text(
                              'Ambulance',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                                shadows: [
                                  Shadow(
                                    color: Colors.white,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            )
          else
            const Center(child: CircularProgressIndicator()),
          
          // Top left tiles - compact and left-aligned
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CompactStatusChip(
                      icon: Icons.emergency,
                      label: emergency?.title ?? 'Emergency en route',
                    ),
                    const SizedBox(height: 8),
                    _CompactMetricTile(
                      icon: Icons.directions_car,
                      title: 'Distance',
                      value: '${provider.distance.toStringAsFixed(1)} km',
                    ),
                    const SizedBox(height: 6),
                    _CompactMetricTile(
                      icon: Icons.timer,
                      title: 'ETA',
                      value: '${provider.eta} min',
                    ),
                    const SizedBox(height: 6),
                    const _CompactLiveIndicator(),
                  ],
                ),
              ),
            ),
          ),

          // Fixed cancel button at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cancel Request?'),
                        content: const Text(
                          'Are you sure you want to cancel this ambulance request?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context.read<EmergencyProvider>().resetToHome();
                            },
                            child: const Text('Yes, Cancel'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel Request'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Compact status chip for top left
class _CompactStatusChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CompactStatusChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.red.shade600),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// Compact metric tile for distance/ETA
class _CompactMetricTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _CompactMetricTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(6),
            child: Icon(icon, color: Colors.red.shade600, size: 16),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Compact live indicator
class _CompactLiveIndicator extends StatefulWidget {
  const _CompactLiveIndicator();

  @override
  State<_CompactLiveIndicator> createState() => _CompactLiveIndicatorState();
}

class _CompactLiveIndicatorState extends State<_CompactLiveIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.2).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            ),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Live',
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
