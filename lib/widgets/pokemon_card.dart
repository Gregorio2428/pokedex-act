import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import 'glass_panel.dart';

const kInk = Color(0xFF3B2A5C);

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final int index;

  const PokemonCard({super.key, required this.pokemon, required this.index});

  @override
  Widget build(BuildContext context) {
    // Staggered pop-in; the delay repeats every 8 items so items that scroll
    // in later don't wait long.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + (index % 8) * 70),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0).toDouble(),
        child: Transform.translate(offset: Offset(0, (1 - v) * 26), child: child),
      ),
      child: GlassPanel(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(170),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pokemon.paddedId,
                  style: const TextStyle(
                    color: kInk,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // soft glow behind the artwork
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withAlpha(220),
                          Colors.white.withAlpha(0),
                        ],
                      ),
                    ),
                  ),
                  Image.network(
                    pokemon.imageUrl,
                    fit: BoxFit.contain,
                    cacheWidth: 300,
                    loadingBuilder: (context, child, progress) => progress == null
                        ? child
                        : const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Color(0xFF9B7BFF),
                            ),
                          ),
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.catching_pokemon,
                      size: 48,
                      color: Color(0xFFB9A6F5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              pokemon.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: kInk,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}