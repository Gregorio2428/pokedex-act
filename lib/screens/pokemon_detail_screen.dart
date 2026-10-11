import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/backdrop.dart';
import '../widgets/glass_panel.dart';
import '../widgets/pokemon_card.dart' show kInk;
import '../widgets/type_chip.dart';

/// Detail page. Everything shown comes from [PokemonProvider].
/// Wide screens: image panel on the left, info panel on the right.
/// Narrow screens: the two panels stack.
class PokemonDetailScreen extends StatelessWidget {
  const PokemonDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PokemonProvider>();
    final pokemon = state.selected;

    return Scaffold(
      body: Stack(
        children: [
          const PastelBackdrop(),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                    child: IconButton.filled(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withAlpha(170),
                        foregroundColor: kInk,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (pokemon == null) {
                        return const Center(
                          child: Text(
                            'No Pokémon selected',
                            style: TextStyle(color: kInk, fontSize: 18),
                          ),
                        );
                      }

                      final wide = constraints.maxWidth >= 720;
                      final imagePanel = _ImagePanel(pokemon: pokemon);
                      final infoPanel = _InfoPanel(pokemon: pokemon, state: state);

                      return Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 940),
                              child: wide
                                  ? SizedBox(
                                      height: 500,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(child: imagePanel),
                                          const SizedBox(width: 24),
                                          Expanded(child: infoPanel),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(height: 340, child: imagePanel),
                                        const SizedBox(height: 20),
                                        infoPanel,
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Left panel: the big artwork.
class _ImagePanel extends StatelessWidget {
  final Pokemon pokemon;

  const _ImagePanel({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 48,
      padding: const EdgeInsets.all(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.white.withAlpha(230),
                  Colors.white.withAlpha(0),
                ],
              ),
            ),
          ),
          Hero(
            tag: 'pokemon-${pokemon.id}',
            child: Image.network(
              pokemon.imageUrl,
              fit: BoxFit.contain,
              cacheWidth: 800,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.catching_pokemon,
                size: 96,
                color: Color(0xFFB9A6F5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Right panel: ID, NAME, POKEMON TYPE.
class _InfoPanel extends StatelessWidget {
  final Pokemon pokemon;
  final PokemonProvider state;

  const _InfoPanel({required this.pokemon, required this.state});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 48,
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'ID', child: _ValueText(pokemon.paddedId)),
          const SizedBox(height: 28),
          _InfoRow(label: 'NAME', child: _ValueText(pokemon.displayName)),
          const SizedBox(height: 28),
          _InfoRow(
            label: 'POKEMON TYPE',
            child: _TypesValue(pokemon: pokemon, state: state),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _InfoRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7A6A9E),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _ValueText extends StatelessWidget {
  final String text;

  const _ValueText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: kInk,
        fontSize: 34,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// Loading / error / success for the type lookup.
class _TypesValue extends StatelessWidget {
  final Pokemon pokemon;
  final PokemonProvider state;

  const _TypesValue({required this.pokemon, required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state.typesStatus) {
      case PokemonStatus.loading:
        return const SizedBox(
          height: 36,
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF9B7BFF),
                ),
              ),
              SizedBox(width: 12),
              Text('Loading…', style: TextStyle(color: kInk, fontSize: 16)),
            ],
          ),
        );
      case PokemonStatus.error:
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              "Couldn't load types.",
              style: TextStyle(color: kInk, fontSize: 16),
            ),
            TextButton(
              onPressed: () => state.fetchTypes(pokemon),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7B5CE0),
              ),
              child: const Text('Retry'),
            ),
          ],
        );
      case PokemonStatus.success:
        if (state.types.isEmpty) {
          return const _ValueText('—');
        }
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [for (final t in state.types) TypeChip(type: t)],
        );
    }
  }
}