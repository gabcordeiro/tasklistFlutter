import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:tasklist/app/app_state.dart';

class MusicFeed extends StatefulWidget {
  const MusicFeed({super.key});

  @override
  State<MusicFeed> createState() => _MusicFeedState();
}

class _MusicFeedState extends State<MusicFeed> {
  final CardSwiperController controller = CardSwiperController();
  final AudioPlayer _player = AudioPlayer();

  // Variável para controlar visualmente se está tocando ou pausado
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    // Carrega o feed assim que entra na tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyAppState>().carregarFeedGlobal();
    });
  }

  @override
  void dispose() {
    _player
        .dispose(); // Para a música ao sair da tela para não ficar tocando no fundo
    controller.dispose();
    super.dispose();
  }

  // Função para carregar e tocar a música do zero (Auto-play)
  void _tocarPreview(String url) async {
    await _player.stop();
    await _player.play(UrlSource(url));
    if (mounted) {
      setState(() {
        _isPlaying = true;
      });
    }
  }

  // Função para o botão de Play/Pause no meio do cartão
  void _togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
    if (mounted) {
      setState(() {
        _isPlaying = !_isPlaying;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var musicas = appState.feedMusicas;

    if (musicas.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.deepPurple),
              const SizedBox(height: 20),
              const Text(
                "Procurando novos beats...",
                style: TextStyle(color: Colors.white70),
              ),
              // Botão para recarregar caso a lista acabe
              TextButton(
                onPressed: () => appState.carregarFeedGlobal(),
                child: const Text("Recarregar"),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black, // Estilo "Dark Mode"
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Descobrir",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),

            Expanded(
              child: CardSwiper(
                controller: controller,
                // Se tiver menos de 3 musicas, mostra apenas o que tem, senão mostra 3
                numberOfCardsDisplayed: musicas.length < 3 ? musicas.length : 3,
                cardsCount: musicas.length,
                onSwipe: (previousIndex, currentIndex, direction) {
                  _player.stop();

                  // Reseta o ícone para play enquanto carrega a próxima
                  setState(() {
                    _isPlaying = false;
                  });

                  final musicaAtual = musicas[previousIndex];

                  if (direction == CardSwiperDirection.right) {
                    // LIKE (Direita) -> Salva
                    context.read<MyAppState>().curtirMusica(musicaAtual);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Salvo em seus Beats! ❤️"),
                        duration: Duration(seconds: 1),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (direction == CardSwiperDirection.left) {
                    // DISLIKE (Esquerda) -> Oculta
                    context.read<MyAppState>().descurtirMusica(musicaAtual);
                  }

                  // Toca a próxima música (se houver)
                  if (currentIndex != null && currentIndex < musicas.length) {
                    _tocarPreview(musicas[currentIndex].musicPath);
                  }
                  return true;
                },

                // Desenha o Cartão
                cardBuilder:
                    (context, index, percentThresholdX, percentThresholdY) {
                  final musica = musicas[index];

                  // Toca a primeira música automaticamente se o player estiver parado
                  // e for o primeiro card da pilha
                  if (index == 0 &&
                      _player.state != PlayerState.playing &&
                      _player.state != PlayerState.paused) {
                    _tocarPreview(musica.musicPath);
                  }

                  return _buildCard(musica);
                },
              ),
            ),

            // Botões de Ação na parte inferior
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: "dislike",
                    backgroundColor: Colors.red,
                    onPressed: () => controller.swipe(CardSwiperDirection.left),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 30),
                  ),
                  FloatingActionButton(
                    heroTag: "like",
                    backgroundColor: Colors.green, // Cor do "Like"
                    onPressed: () =>
                        controller.swipe(CardSwiperDirection.right),
                    child: const Icon(Icons.favorite,
                        color: Colors.white, size: 30),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Music musica) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Gradiente bonito para o fundo do cartão
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blueGrey[900]!, Colors.black],
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5))
        ],
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        children: [
          // 1. Ícone de fundo (decoração)
          Center(
            child: Icon(Icons.music_note,
                size: 150, color: Colors.white.withOpacity(0.05)),
          ),

          // 2. Botão de Play/Pause Centralizado
          Center(
            child: GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2)
                    ]),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // 3. Informações da música na base do cartão
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black, Colors.transparent],
                  ),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    musica.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person,
                          color: Colors.blueAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        musica.artista,
                        style: const TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Toque no centro para pausar",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
