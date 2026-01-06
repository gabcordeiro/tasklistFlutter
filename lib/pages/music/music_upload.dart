// No MusicUpload.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';
import 'package:tasklist/services/music_service.dart';

class MusicUpload extends StatelessWidget {
  const MusicUpload({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var musicService = MusicService(); // Instancia o service

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note, size: 100, color: Colors.blue),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              // 1. Seleciona
              final arquivo = await musicService.selecionarMusic();
              if (arquivo != null) {
                // 2. Processa e sobe (o Service já faz a lógica de Web/Android)
                await musicService.processarUpload(arquivo);
                
                // 3. Atualiza a lista após o upload
                await appState.carregarMusicasDoFirebase();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Upload concluído!")),
                );
              }
            },
            icon: Icon(Icons.upload_file),
            label: Text("Selecionar e Enviar Música"),
          ),
        ],
      ),
    );
  }
}