import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklist/app/app_state.dart';
import 'package:tasklist/services/music_service.dart';

class MusicUpload extends StatelessWidget {
  const MusicUpload({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta o AppState
    var appState = context.watch<MyAppState>();
    var musicService = MusicService();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indicador Visual
            appState.estaCarregandoMusica
                ? const CircularProgressIndicator()
                : const Icon(Icons.cloud_upload_outlined, size: 80, color: Colors.blue),

            const SizedBox(height: 20),

            // Botão de Upload
            ElevatedButton.icon(
              onPressed: appState.estaCarregandoMusica
                  ? null // Desabilita se estiver carregando
                  : () async {
                      // 1. Seleciona o arquivo
                      final arquivo = await musicService.selecionarMusic();

                      if (arquivo != null) {
                        try {
                          // 2. Ativa o loading na tela
                          appState.setCarregando(true);

                          // 3. Processa: Comprime (se mobile) -> Upload Cloudinary -> Salva Firestore
                          await musicService.processarUpload(arquivo);

                          // 4. Atualiza a lista local baixando do Firestore novamente
                          await appState.carregarMusicasDoFirebase();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Música enviada com sucesso!"),
                                  backgroundColor: Colors.green),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Erro no upload: $e"),
                                  backgroundColor: Colors.red),
                            );
                          }
                        } finally {
                          // 5. Desativa o loading
                          appState.setCarregando(false);
                        }
                      }
                    },
              icon: const Icon(Icons.upload_file),
              label: Text(appState.estaCarregandoMusica
                  ? "Processando..."
                  : "Selecionar e Enviar Música"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}