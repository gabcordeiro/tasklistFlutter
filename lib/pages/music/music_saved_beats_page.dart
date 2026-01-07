import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';
import 'package:tasklist/widgets/music_card.dart'; // Reutilizamos seu card!

class SavedBeatsPage extends StatelessWidget {
  const SavedBeatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    
    // Você precisa garantir que o appState.carregarMusicasDoFirebase()
    // esteja carregando o campo 'artista' também no loop for.
    var minhasMusicas = appState.listamusicas;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Beats Salvos"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: minhasMusicas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                  SizedBox(height: 20),
                  Text("Você ainda não curtiu nenhum beat."),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: minhasMusicas.length,
              itemBuilder: (context, index) {
                final musica = minhasMusicas[index];
                return Column(
                  children: [
                    MusicCard(musica: musica),
                    // Pequeno texto mostrando o artista abaixo do card (ou dentro do card se preferir editar o widget)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0, bottom: 8),
                        child: Text(
                          "Prod por: ${musica.artista}",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
    );
  }
}