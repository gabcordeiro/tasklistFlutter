import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';
import 'package:tasklist/widgets/big_card_favorite.dart';


class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();


    return Center(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Voce tem ${appState.favorites.length} palavras favoritas.'),
          ...appState.favorites.map(
            (favorites) => BigCardFavorite(texto: favorites),
          ),
          SizedBox(height: 30),

        ],
      ),
    );
  }
}
