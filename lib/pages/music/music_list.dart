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

    // Filtramos para mostrar apenas músicas onde o artista é "Você"
    // ou que não foram marcadas como vindas do feed.
    var meusUploads =
        appState.listamusicas.where((m) => m.artista == 'Você').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Beats Postados"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () => appState.carregarMusicasDoFirebase(),
        child: meusUploads.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.only(top: 10, bottom: 80),
                itemCount: meusUploads.length,
                itemBuilder: (context, index) {
                  final musica = meusUploads[index];
                  return MusicCard(musica: musica,isMyUpload: true);
                },
              ),
      ),
    );
  }

  // Widget para quando não houver músicas
  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      // Usamos ListView para o RefreshIndicator funcionar
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
