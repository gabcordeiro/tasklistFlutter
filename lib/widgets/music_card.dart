import 'package:flutter/material.dart';
import 'package:tasklist/app/app_state.dart'; // Certifique-se que o caminho está correto

class MusicCard extends StatelessWidget {
  final Music musica;

  const MusicCard({
    super.key,
    required this.musica,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final style = theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.onSecondaryContainer,
      fontWeight: FontWeight.bold,
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Botão de Play
            IconButton(
              icon: const Icon(Icons.play_circle_fill, size: 45, color: Colors.blue),
              onPressed: () {
                // No futuro, o audioplayers entrará aqui
                debugPrint("Tocando agora: ${musica.titulo}");
                debugPrint("URL: ${musica.musicPath}");
              },
            ),
            const SizedBox(width: 12),
            // Informações da Música
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    musica.titulo,
                    style: style,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    "Toque para reproduzir",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Botão de Opções/Remover
            IconButton(
              onPressed: () {
                // Lógica de deletar do Firebase no futuro
              },
              icon: const Icon(Icons.more_vert, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}