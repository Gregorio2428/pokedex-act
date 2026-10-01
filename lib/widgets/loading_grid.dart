import 'package:flutter/material.dart';

import 'glass_panel.dart';
import 'pokemon_grid.dart';

/// Pulsing skeleton cards shown while the request is in flight.
class LoadingGrid extends StatefulWidget {
  const LoadingGrid({super.key});

  @override
  State<LoadingGrid> createState() => _LoadingGridState();
}

class _LoadingGridState extends State<LoadingGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: kGridDelegate,
      itemCount: 12,
      itemBuilder: (context, i) => FadeTransition(
        opacity: Tween(begin: 0.45, end: 1.0).animate(
          CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
        ),
        child: GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(alignment: Alignment.centerRight, child: _bar(36, 16)),
              const Spacer(),
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(150),
                  ),
                ),
              ),
              const Spacer(),
              Center(child: _bar(80, 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(150),
          borderRadius: BorderRadius.circular(10),
        ),
      );
}