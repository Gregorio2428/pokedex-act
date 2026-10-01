import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

/// Thrown with a message that is safe to show to the user.
class PokemonServiceException implements Exception {
  final String message;
  const PokemonServiceException(this.message);

  @override
  String toString() => message;
}

class PokemonService {
  static const _baseUrl = 'https://pokeapi.co/api/v2/pokemon';

  final http.Client _client;

  PokemonService({http.Client? client}) : _client = client ?? http.Client();

  /// Returns a [Future] (not a Stream): the request produces exactly one
  /// result, then it's done. See the note in PokedexScreen.
  Future<List<Pokemon>> fetchPokemon({int limit = 30}) async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl?limit=$limit'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw PokemonServiceException(
          'The Pokédex server replied with ${response.statusCode}.',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final results = body['results'] as List<dynamic>;

      return results
          .map((e) => Pokemon.fromListJson(e as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw const PokemonServiceException(
        'That took too long. Check your connection and try again.',
      );
    } on http.ClientException {
      throw const PokemonServiceException(
        "Couldn't reach the Pokédex. Are you online?",
      );
    } on FormatException {
      throw const PokemonServiceException(
        'Got a strange response from the server.',
      );
    }
  }
}