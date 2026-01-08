import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';
import 'package:tasklist/widgets/music_card.dart';

class SavedBeatsPage extends StatelessWidget {
  const SavedBeatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    
    // FILTRO CHAVE: Pegamos todas as músicas da playlist, 
    // mas mostramos apenas as que NÃO foram postadas por você.
    var curtidasNoFeed = appState.listamusicas.where((m) => m.artista != 'Você').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Beats Curtidos"),
        backgroundColor: Colors.pinkAccent, // Cor diferente para diferenciar de "Meus Uploads"
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black, // Dark mode para combinar com o feed
      body: curtidasNoFeed.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, size: 80, color: Colors.white24),
                  const SizedBox(height: 20),
                  const Text(
                    "Sua lista de curtidas está vazia.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const Text(
                    "Dê um like no Feed para salvar beats aqui!",
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: curtidasNoFeed.length,
              itemBuilder: (context, index) {
                final musica = curtidasNoFeed[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      MusicCard(musica: musica,isMyUpload: false),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 24.0),
                          child: Text(
                            "Prod por: ${musica.artista}",
                            style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}