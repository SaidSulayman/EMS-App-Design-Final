import 'package:flutter/material.dart';

/// A compact ambulance marker used on the map. Shows a medical icon with a
/// small pulsing siren indicator to make movement visually obvious.
class AmbulanceIcon extends StatefulWidget {
  final double size;
  final Color color;

  const AmbulanceIcon({
    super.key,
    this.size = 48,
    this.color = Colors.red,
  });

  @override
  State<AmbulanceIcon> createState() => _AmbulanceIconState();
}

class _AmbulanceIconState extends State<AmbulanceIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background rounded square
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),

          // Medical cross (center)
          Icon(
            Icons.local_hospital,
            color: Colors.white,
            size: size * 0.55,
          ),

          // Pulsing siren at top-left
          Positioned(
            top: 6,
            left: 6,
            child: FadeTransition(
              opacity: Tween(begin: 0.4, end: 1.0).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              ),
              child: ScaleTransition(
                scale: Tween(begin: 0.8, end: 1.3).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
                ),
                child: Container(
                  width: size * 0.18,
                  height: size * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade300,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200.withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
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

