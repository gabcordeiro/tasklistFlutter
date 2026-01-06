import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ffmpeg_kit_flutter_audio/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter_audio/ffmpeg_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data'; // Necessário para o Uint8List
import 'dart:io'; // Necessário para o File(dado)

class MusicService {

  Future<PlatformFile?> selecionarMusic() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: true, // <--- ESSENCIAL para o Chrome (Web)
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

  final storageRef = FirebaseStorage.instance
      .ref()
      .child('usuarios/${user.uid}/musicas/$nome');

  // --- CORREÇÃO AQUI ---
  if (dado is Uint8List) {
    // Caso seja Web (bytes)
    await storageRef.putData(dado);
  } else if (dado is String) {
    // Caso seja Android (caminho/path)
    // Precisamos converter a String em um objeto File do dart:io
    await storageRef.putFile(File(dado));
  } else {
    throw "Tipo de dado inválido para upload";
  }

  // Pega o link gerado
  String urlMusica = await storageRef.getDownloadURL();

  // Salva no Firestore
  await FirebaseFirestore.instance
      .collection('usuarios')
      .doc(user.uid)
      .collection('playlist')
      .add({
    'nome': nome,
    'url': urlMusica,
    'criadoEm': Timestamp.now(),
  });
}

  Future<void> processarUpload(PlatformFile arquivo) async {
    if (kIsWeb) {
      // ESTRATÉGIA WEB:
      // Usamos os bytes direto, sem comprimir (FFmpeg não roda aqui)
      final bytes = arquivo.bytes;
      await uploadMusicaCompleto(bytes, arquivo.name);
    } else {
      // ESTRATÉGIA ANDROID:
      // Temos o path, então podemos comprimir antes de subir
      String? pathComprimido = await comprimirMusic(arquivo.path!);
      await uploadMusicaCompleto(pathComprimido, arquivo.name);
    }
  }

}
