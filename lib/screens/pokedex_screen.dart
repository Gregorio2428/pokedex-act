import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../widgets/loading_grid.dart';
import '../widgets/pokemon_card.dart' show kInk;
import '../widgets/pokemon_grid.dart';
import '../widgets/state_message.dart';

/// WHY A FUTURE AND NOT A STREAM?
///
/// A Stream models *many values over time* (live chat, location updates,
/// websockets). Here we make one HTTP request and get one complete list back,
/// after which nothing else will ever arrive. That's exactly a Future: one
/// value, once, or an error. FutureBuilder maps 1:1 onto our UI states
/// (waiting -> loading, hasError -> error, data -> grid / empty), and retrying
/// is just assigning a new Future. A Stream would add subscription
/// management for zero benefit. If the Pokédex ever needed live updates,
/// that's when we'd switch.
class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  final _service = PokemonService();
  late Future<List<Pokemon>> _future = _service.fetchPokemon(limit: 30);

  void _reload() {
    setState(() => _future = _service.fetchPokemon(limit: 30));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _Backdrop(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Header(),
                Expanded(
                  child: FutureBuilder<List<Pokemon>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const LoadingGrid();
                      }
                      if (snapshot.hasError) {
                        return StateMessage(
                          emoji: '🥺',
                          title: 'Oh no, a wild error!',
                          subtitle: '${snapshot.error}',
                          actionLabel: 'Try again',
                          onAction: _reload,
                        );
                      }
                      final list = snapshot.data ?? const <Pokemon>[];
                      if (list.isEmpty) {
                        return StateMessage(
                          emoji: '🫧',
                          title: 'No Pokémon found',
                          subtitle: 'The Pokédex is empty right now.',
                          actionLabel: 'Refresh',
                          onAction: _reload,
                        );
                      }
                      return PokemonGrid(pokemon: list);
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 18, 24, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pokedex',
            style: TextStyle(
              color: kInk,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 2),
          Text(
            "Gotta getget",
            style: TextStyle(color: Color(0xFF7A6A9E), fontSize: 15),
          ),
        ],
      ),
    );
  }
}

/// Pastel gradient with a few soft "light blobs" so the glass has something
/// to blur.
class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFD9EC), Color(0xFFE0D4FF), Color(0xFFCDEBFF)],
            ),
          ),
        ),
        _blob(top: -60, left: -50, size: 240, color: const Color(0xFFFF9CCB)),
        _blob(top: 260, right: -80, size: 280, color: const Color(0xFFA98BFF)),
        _blob(bottom: -70, left: 30, size: 260, color: const Color(0xFF8FD6FF)),
      ],
    );
  }

  Widget _blob({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color.withAlpha(170), color.withAlpha(0)]),
        ),
      ),
    );
  }
}