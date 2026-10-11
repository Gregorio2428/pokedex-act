import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../screens/pokemon_detail_screen.dart';
import 'pokemon_card.dart';

const kGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 210,
  childAspectRatio: 0.82,
  crossAxisSpacing: 14,
  mainAxisSpacing: 14,
);

/// The scrollable grid of Pokémon.
class PokemonGrid extends StatelessWidget {
  final List<Pokemon> pokemon;

  const PokemonGrid({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      physics: const BouncingScrollPhysics(),
      gridDelegate: kGridDelegate,
      itemCount: pokemon.length,
      itemBuilder: (context, i) {
        final item = pokemon[i];
        return PokemonCard(
          pokemon: item,
          index: i,
          onTap: () {
            // Selection goes into app state; the detail page reads it back.
            context.read<PokemonProvider>().selectPokemon(item);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PokemonDetailScreen()),
            );
          },
        );
      },
    );
  }
}