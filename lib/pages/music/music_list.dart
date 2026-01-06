import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';
import 'package:tasklist/widgets/music_card.dart';
// Importe o seu MusicCard aqui. Ex:
// import 'package:tasklist/widgets/music_card.dart';

class MusicList extends StatelessWidget {
  const MusicList({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var musicas = appState.listamusicas;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => appState.carregarMusicasDoFirebase(),
        child: musicas.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.only(top: 10, bottom: 80),
                itemCount: musicas.length,
                itemBuilder: (context, index) {
                  final musica = musicas[index];
                  return MusicCard(musica: musica);
                },
              ),
      ),
    );
  }

  // Widget para quando não houver músicas
  Widget _buildEmptyState(BuildContext context) {
    return ListView( // Usamos ListView para o RefreshIndicator funcionar
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(
          child: Column(
            children: [
              Icon(Icons.library_music_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Sua playlist está vazia",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              Text("Faça um upload para começar!"),
            ],
          ),
        ),
      ],
    );
  }
}