import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';
import 'package:tasklist/models/models.dart';

class MusicCard extends StatelessWidget {
  final Music musica;
  final bool isMyUpload; // <--- NOVA PROPRIEDADE

  const MusicCard({
    super.key, 
    required this.musica, 
    required this.isMyUpload
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.read<MyAppState>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[900],
      child: ListTile(
        leading: Icon(isMyUpload ? Icons.cloud_done : Icons.favorite, color: Colors.pinkAccent),
        title: Text(musica.titulo, style: const TextStyle(color: Colors.white)),
        subtitle: Text(musica.artista, style: const TextStyle(color: Colors.white70)),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white70),
          onSelected: (value) {
            if (value == 'remover') {
              if (isMyUpload) {
                appState.deletarMusica(musica); // Deleta o post original
              } else {
                appState.removerDosCurtidos(musica); // Tira dos favoritos e volta pro feed
              }
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'remover',
              child: Row(
                children: [
                  Icon(Icons.delete, color: isMyUpload ? Colors.red : Colors.orange),
                  const SizedBox(width: 8),
                  Text(isMyUpload ? 'Excluir Postagem' : 'Remover dos Salvos'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}