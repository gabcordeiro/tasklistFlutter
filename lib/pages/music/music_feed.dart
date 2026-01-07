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
  
  // Para controlar qual música está visível
  int _currentIndex = 0;

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
    _player.dispose(); // Para a música ao sair da tela
    controller.dispose();
    super.dispose();
  }

  // Função para tocar a música do cartão atual
  void _tocarPreview(String url) async {
    await _player.stop();
    await _player.play(UrlSource(url));
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var musicas = appState.feedMusicas;

    if (musicas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.black, // Estilo "Dark Mode" de balada
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Descobrir", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            
            Expanded(
              child: CardSwiper(
                controller: controller,
                cardsCount: musicas.length,
                numberOfCardsDisplayed: 3, // Efeito de pilha
                
                // O que acontece quando arrasta (Like/Dislike)
                onSwipe: (previousIndex, currentIndex, direction) {
                  _player.stop(); // Para a música anterior
                  
                  // Se for para a direita, é Like!
                  if (direction == CardSwiperDirection.right) {
                    print("Curtiu a música: ${musicas[previousIndex].titulo}");
                    // Aqui você colocaria a lógica de salvar nos favoritos
                  }
                  
                  // Toca a próxima música (se houver)
                  if (currentIndex != null && currentIndex < musicas.length) {
                     _tocarPreview(musicas[currentIndex].musicPath);
                  }
                  
                  return true;
                },
                
                // Desenha o Cartão
                cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                  final musica = musicas[index];
                  // Toca a primeira música automaticamente
                  if (index == 0 && _player.state != PlayerState.playing) {
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
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                   FloatingActionButton(
                    heroTag: "like",
                    backgroundColor: Colors.green, // Cor do "Like"
                    onPressed: () => controller.swipe(CardSwiperDirection.right),
                    child: const Icon(Icons.favorite, color: Colors.white),
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
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5))
        ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Capa do Álbum (Simulada com Ícone por enquanto)
          Expanded(
            child: Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueGrey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(Icons.music_note, size: 100, color: Colors.white54),
              ),
            ),
          ),
          
          // Informações
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  musica.titulo,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Artista Desconhecido", // Você pode adicionar campo 'artista' no Firebase depois
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40), // Espaço para não ficar em cima dos botões
        ],
      ),
    );
  }
}