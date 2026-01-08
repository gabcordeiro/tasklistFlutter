import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:tasklist/app/app_state.dart';
import 'package:tasklist/models/models.dart';

class MusicFeed extends StatefulWidget {
  const MusicFeed({super.key});

  @override
  State<MusicFeed> createState() => _MusicFeedState();
}

class _MusicFeedState extends State<MusicFeed> {
  final CardSwiperController controller = CardSwiperController();
  final AudioPlayer _player = AudioPlayer();
  
  String? _currentUrl;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<MyAppState>().feedMusicas.isEmpty) {
        context.read<MyAppState>().carregarFeedGlobal();
      }
    });
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause(String url) async {
    if (_currentUrl == url && _isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      await _player.stop();
      await _player.play(UrlSource(url));
      setState(() {
        _currentUrl = url;
        _isPlaying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var musicas = appState.feedMusicas;

    // 1. TELA DE CARREGAMENTO
    if (appState.estaCarregandoMusica) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
        ),
      );
    }

    // 2. TELA VAZIA (EMPTY STATE)
    if (musicas.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SingleChildScrollView( // Proteção contra overflow em telas pequenas
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.music_off, size: 80, color: Colors.white24),
                const SizedBox(height: 20),
                const Text(
                  "Sem novos beats por enquanto.",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () => appState.resetarDislikesECarregarFeed(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Resetar Feed & Recarregar"),
                )
              ],
            ),
          ),
        ),
      );
    }

    // 3. TELA PRINCIPAL (CARD SWIPER)
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Descobrir",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            
            Expanded(
              // PROTEÇÃO RangeError: Só renderiza o CardSwiper se a lista não estiver vazia
              child: musicas.isNotEmpty 
                  ? CardSwiper(
                controller: controller,
                cardsCount: musicas.length,
                // PROTEÇÃO RangeError: Garante que não exiba mais cartas do que existem
                numberOfCardsDisplayed: musicas.length >= 3 ? 3 : musicas.length,
                onSwipe: (previousIndex, currentIndex, direction) {
                  _player.stop();
                  setState(() {
                    _isPlaying = false;
                    _currentUrl = null;
                  });

                  final musicaAtual = musicas[previousIndex];

                  if (direction == CardSwiperDirection.right) {
                    appState.curtirMusica(musicaAtual);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Salvo: ${musicaAtual.titulo}"), 
                        duration: const Duration(milliseconds: 800)
                      ),
                    );
                  } else if (direction == CardSwiperDirection.left) {
                    appState.descurtirMusica(musicaAtual);
                  }
                  return true;
                },
                cardBuilder: (context, index, horizontalOffset, verticalOffset) {
                  // PROTEÇÃO RangeError extra
                  if (index >= musicas.length) return const SizedBox();
                  return _buildCard(musicas[index]);
                },
              ) : const SizedBox(),
            ),
            
            // Botões Inferiores
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: "dislike_btn",
                    backgroundColor: Colors.grey[800],
                    onPressed: () {
                      if (musicas.isNotEmpty) controller.swipe(CardSwiperDirection.left);
                    },
                    child: const Icon(Icons.close, color: Colors.red),
                  ),
                  FloatingActionButton(
                    heroTag: "like_btn",
                    backgroundColor: Colors.white,
                    onPressed: () {
                      if (musicas.isNotEmpty) controller.swipe(CardSwiperDirection.right);
                    },
                    child: const Icon(Icons.favorite, color: Colors.green),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // WIDGET DO CARD COM PROTEÇÃO DE OVERFLOW
  Widget _buildCard(Music music) {
    final isThisPlaying = (_currentUrl == music.musicPath && _isPlaying);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[900]!, Colors.grey[850]!],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))
        ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Center(
              child: Icon(Icons.music_note, size: 120, color: Colors.white.withOpacity(0.03)),
            ),
            // Padding e Flexible evitam o Overflow
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Container da "Capa" flexível
                  Flexible(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade900,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isThisPlaying ? Icons.graphic_eq : Icons.music_note,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Textos com limites
                  Text(
                    music.titulo,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    music.artista,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  // Botão de Play
                  IconButton(
                    iconSize: 56,
                    icon: Icon(
                      isThisPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: Colors.deepPurpleAccent,
                    ),
                    onPressed: () => _togglePlayPause(music.musicPath),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}