import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/pokemon_provider.dart';
import 'screens/pokedex_screen.dart';

void main() {
  runApp(
    // One provider at the top of the tree = one source of truth for the app.
    ChangeNotifierProvider(
      create: (_) => PokemonProvider(),
      child: const PokedexApp(),
    ),
  );
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF9B7BFF),
        textTheme: GoogleFonts.fredokaTextTheme(),
      ),
      home: const PokedexScreen(),
    );
  }
}