import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

/// The three states the UI can be in (used for the list AND the type lookup).
enum PokemonStatus { loading, success, error }

/// App state for the Pokédex. Every value the UI shows (list, status, error
/// message, selected Pokémon, its types) lives here, not inside widgets.
class PokemonProvider extends ChangeNotifier {
  static const _listUrl = 'https://pokeapi.co/api/v2/pokemon?limit=30';
  static const _detailUrl = 'https://pokeapi.co/api/v2/pokemon';

  // ---- list state ----
  PokemonStatus _status = PokemonStatus.loading;
  List<Pokemon> _pokemon = [];
  String _errorMessage = '';

  // ---- detail state ----
  Pokemon? _selected;
  List<String> _types = [];
  PokemonStatus _typesStatus = PokemonStatus.loading;
  final Map<int, List<String>> _typeCache = {};

  PokemonProvider() {
    fetchPokemon();
  }

  PokemonStatus get status => _status;
  bool get isLoading => _status == PokemonStatus.loading;
  List<Pokemon> get pokemon => _pokemon;
  String get errorMessage => _errorMessage;

  Pokemon? get selected => _selected;
  List<String> get types => _types;
  PokemonStatus get typesStatus => _typesStatus;

  /// The main API call. Used for the first load AND for refresh/retry.
  Future<void> fetchPokemon() async {
    _status = PokemonStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse(_listUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final results = body['results'] as List<dynamic>;
        _pokemon = results
            .map((e) => Pokemon.fromListJson(e as Map<String, dynamic>))
            .toList();
        _status = PokemonStatus.success;
      } else {
        _fail('The Pokédex server replied with ${response.statusCode}.');
      }
    } on TimeoutException {
      _fail('That took too long. Check your connection and try again.');
    } on http.ClientException {
      _fail("Couldn't reach the Pokédex. Are you online?");
    } on FormatException {
      _fail('Got a strange response from the server.');
    } catch (_) {
      _fail('Something went wrong. Please try again.');
    }

    notifyListeners();
  }

  /// Remembers which Pokémon was tapped, then loads its types.
  void selectPokemon(Pokemon pokemon) {
    _selected = pokemon;
    fetchTypes(pokemon);
  }

  /// Types aren't in the list response, so we ask for this Pokémon's details.
  Future<void> fetchTypes(Pokemon pokemon) async {
    final cached = _typeCache[pokemon.id];
    _types = cached ?? [];
    _typesStatus = cached != null ? PokemonStatus.success : PokemonStatus.loading;
    notifyListeners();
    if (cached != null) return;

    var result = PokemonStatus.error;
    var names = <String>[];

    try {
      final response = await http
          .get(Uri.parse('$_detailUrl/${pokemon.id}'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final entries = (body['types'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList()
          ..sort((a, b) => (a['slot'] as int).compareTo(b['slot'] as int));
        names = entries
            .map((e) => (e['type'] as Map<String, dynamic>)['name'] as String)
            .toList();
        _typeCache[pokemon.id] = names;
        result = PokemonStatus.success;
      }
    } catch (_) {
      result = PokemonStatus.error;
    }

    // The user may have opened a different Pokémon while we were waiting.
    if (_selected?.id != pokemon.id) return;

    _types = names;
    _typesStatus = result;
    notifyListeners();
  }

  void _fail(String message) {
    _status = PokemonStatus.error;
    _errorMessage = message;
  }
}