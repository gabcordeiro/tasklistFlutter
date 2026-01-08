// ARQUIVO: lib/services/music_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ffmpeg_kit_flutter_audio/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter_audio/ffmpeg_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class MusicService {
  // ATENÇÃO: Em produção, evite deixar keys hardcoded. Use variáveis de ambiente (.env)
  final cloudinary = CloudinaryPublic('drbbiae6f', 'projeto_musica', cache: false);

  // Selecionar arquivo (Audio)
  Future<PlatformFile?> selecionarMusic() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: true, // Essencial para Web
    );

    if (result != null) {
      return result.files.first;
    }
    return null;
  }

  // Comprimir Audio (Apenas Mobile)
  Future<String?> comprimirMusic(String pathOriginal) async {
    final diretorioTemp = await getTemporaryDirectory();
    final caminhoComprimido =
        '${diretorioTemp.path}/comprimido_${DateTime.now().millisecondsSinceEpoch}.mp3';

    // Comando FFmpeg: reduz bitrate para 128k (mp3)
    final comandoFFmpeg = '-i "$pathOriginal" -b:a 128k "$caminhoComprimido"';

    final session = await FFmpegKit.execute(comandoFFmpeg);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return caminhoComprimido;
    } else {
      debugPrint("Falha na compressão do áudio.");
      return null;
    }
  }

  // Upload para Cloudinary e Salvar no Firestore
  Future<void> uploadMusicaCompleto(dynamic dado, String nome) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Usuário não logado");
    
    String nomeArtista = user.displayName ?? "Artista TaskList";
    String urlMusica;

    try {
      CloudinaryResponse response;

      // Web usa bytes, Mobile usa path
      if (dado is Uint8List) {
        response = await cloudinary.uploadFile(
          CloudinaryFile.fromBytesData(
            dado,
            identifier: nome,
            resourceType: CloudinaryResourceType.Video, // Audio é 'Video' no Cloudinary
          ),
        );
      } else if (dado is String) {
        response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            dado,
            identifier: nome,
            resourceType: CloudinaryResourceType.Video,
          ),
        );
      } else {
        throw Exception("Tipo de dado inválido para upload");
      }

      urlMusica = response.secureUrl;

      // Salva referência no Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('playlist')
          .add({
        'nome': nome,
        'url': urlMusica,
        'artista': nomeArtista,
        'criadoEm': Timestamp.now(),
        'origem': 'upload_proprio'
      });
      
    } catch (e) {
      debugPrint("Erro no upload: $e");
      rethrow;
    }
  }

  // Fachada para processar o fluxo dependendo da plataforma
  Future<void> processarUpload(PlatformFile arquivo) async {
    if (kIsWeb) {
      final bytes = arquivo.bytes;
      if (bytes != null) {
        await uploadMusicaCompleto(bytes, arquivo.name);
      }
    } else {
      if (arquivo.path != null) {
        String pathParaUpload = arquivo.path!;
        
        // Tenta comprimir
        String? pathComprimido = await comprimirMusic(arquivo.path!);
        if (pathComprimido != null) {
          pathParaUpload = pathComprimido;
        }

        await uploadMusicaCompleto(pathParaUpload, arquivo.name);
      }
    }
  }
}