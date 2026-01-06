import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:tasklist/app/app_state.dart';

class MusicCard extends StatefulWidget {
  final Music musica;

  const MusicCard({super.key, required this.musica});

  @override
  State<MusicCard> createState() => _MusicCardState();
}

class _MusicCardState extends State<MusicCard> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Listener para detectar quando a música acabar sozinha
    _player.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose(); // Limpeza de memória
    super.dispose();
  }

  Future<void> _togglePlay() async {
    try {
      if (_isPlaying) {
        await _player.stop();
      } else {
        // widget.musica.musicPath contém a URL do Cloudinary salva no Firestore
        await _player.play(UrlSource(widget.musica.musicPath));
      }

      if (mounted) {
        setState(() {
          _isPlaying = !_isPlaying;
        });
      }
    } catch (e) {
      debugPrint("Erro ao reproduzir áudio: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao carregar o áudio.")),
        );
      }
    }
  }

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
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.stop_circle : Icons.play_circle_fill,
                size: 45,
                color: _isPlaying ? Colors.red : Colors.blue,
              ),
              onPressed: _togglePlay,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.musica.titulo,
                    style: style,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _isPlaying ? "Reproduzindo..." : "Toque para reproduzir",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // Futura implementação de menu (deletar, etc)
              },
              icon: const Icon(Icons.more_vert, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}