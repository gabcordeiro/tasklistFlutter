import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ffmpeg_kit_flutter_audio/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter_audio/ffmpeg_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class MusicService {
  // Configuração do seu Cloudinary
  final cloudinary =
      CloudinaryPublic('drbbiae6f', 'projeto_musica', cache: false);

  Future<PlatformFile?> selecionarMusic() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: true, // Essencial para funcionar no Chrome/Web
    );

    if (result != null) {
      return result.files.first;
    }
    return null;
  }

  Future<String?> comprimirMusic(String pathOriginal) async {
    final diretorioTemp = await getTemporaryDirectory();
    final caminhoComprimido =
        '${diretorioTemp.path}/comprimido_${DateTime.now().millisecondsSinceEpoch}.mp3';

    // Comando FFmpeg para reduzir o bitrate para 128k
    final comandoFFmpeg = '-i "$pathOriginal" -b:a 128k "$caminhoComprimido"';

    final session = await FFmpegKit.execute(comandoFFmpeg);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return caminhoComprimido;
    } else {
      return null;
    }
  }

  Future<void> uploadMusicaCompleto(dynamic dado, String nome) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String urlMusica;

    try {
      CloudinaryResponse response;

      // Realiza o upload para o Cloudinary dependendo do tipo de dado
      if (dado is Uint8List) {
        // Fluxo Web
        response = await cloudinary.uploadFile(
          CloudinaryFile.fromBytesData(
            dado,
            identifier: nome,
            resourceType:
                CloudinaryResourceType.Video, // Áudio é tratado como vídeo
          ),
        );
      } else if (dado is String) {
        // Fluxo Android
        response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            dado,
            identifier: nome,
            resourceType:
                CloudinaryResourceType.Video, // Áudio é tratado como vídeo
          ),
        );
      } else {
        throw "Tipo de dado inválido para upload";
      }

      // URL final do áudio hospedado
      urlMusica = response.secureUrl;

      // Salva a referência (link) no Firestore para listar na UI
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('playlist')
          .add({
        'nome': nome,
        'url': urlMusica,
        'criadoEm': Timestamp.now(),
      });
    } catch (e) {
      debugPrint("Erro no upload para Cloudinary: $e");
      rethrow;
    }
  }

  Future<void> processarUpload(PlatformFile arquivo) async {
    if (kIsWeb) {
      // No Web usamos os bytes diretamente
      final bytes = arquivo.bytes;
      if (bytes != null) {
        await uploadMusicaCompleto(bytes, arquivo.name);
      }
    } else {
      // No Android usamos o path e comprimimos com FFmpeg
      if (arquivo.path != null) {
        String? pathComprimido = await comprimirMusic(arquivo.path!);
        // Se a compressão falhar, tentamos subir o original como fallback
        await uploadMusicaCompleto(
            pathComprimido ?? arquivo.path!, arquivo.name);
      }
    }
  }
}
