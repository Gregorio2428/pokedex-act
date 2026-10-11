import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pokemon_provider.dart';
import '../widgets/backdrop.dart';
import '../widgets/loading_grid.dart';
import '../widgets/pokemon_card.dart' show kInk;
import '../widgets/pokemon_grid.dart';
import '../widgets/state_message.dart';

/// Stateless on purpose: everything it shows comes from [PokemonProvider].
class PokedexScreen extends StatelessWidget {
  const PokedexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PokemonProvider>();

    return Scaffold(
      body: Stack(
        children: [
          const PastelBackdrop(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(onRefresh: state.isLoading ? null : state.fetchPokemon),
                Expanded(
                  child: switch (state.status) {
                    PokemonStatus.loading => const LoadingGrid(),
                    PokemonStatus.error => StateMessage(
                        emoji: '🥺',
                        title: 'Oh no, a wild error!',
                        subtitle: state.errorMessage,
                        actionLabel: 'Try again',
                        onAction: state.fetchPokemon,
                      ),
                    PokemonStatus.success => state.pokemon.isEmpty
                        ? StateMessage(
                            emoji: '🫧',
                            title: 'No Pokémon found',
                            subtitle: 'The Pokédex is empty right now.',
                            actionLabel: 'Refresh',
                            onAction: state.fetchPokemon,
                          )
                        : PokemonGrid(pokemon: state.pokemon),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback? onRefresh;

  const _Header({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 18, 14),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✦ Pokédex',
                  style: TextStyle(
                    color: kInk,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Gotta scroll 'em all",
                  style: TextStyle(color: Color(0xFF7A6A9E), fontSize: 15),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text('Refresh'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF9B7BFF),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}