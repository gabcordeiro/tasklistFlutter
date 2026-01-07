import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tasklist/services/user_service.dart';

class Tarefa {
  final String id; // O código único do Firestore (Ex: 4qIKyw...)
  final String titulo; // O texto visível (Ex: asd)

  Tarefa({required this.id, required this.titulo});
}

class Anotation {
  final String id; // O código único do Firestore (Ex: 4qIKyw...)
  final String titulo; // O texto visível (Ex: asd)

  Anotation({required this.id, required this.titulo});
}

class Music {
  final String id; // O código único do Firestore (Ex: 4qIKyw...)
  final String titulo; // O texto visível (Ex: asd)
  final String musicPath; // O texto visível (Ex: asd)
  final String artista; // <--- NOVO CAMPO
  Music(
      {required this.id,
      required this.titulo,
      required this.musicPath,
      this.artista = 'Desconhecido'});
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  var favorites = <WordPair>[];

  var listaTarefas = <Tarefa>[];

  var listaAnotation = <Anotation>[];

  var userService = UserService();

  var listamusicas = <Music>[];

  MyAppState() {
    // Assim que o Provider nasce, ele tenta carregar os dados
    carregarTarefasDoFirebase();
  }

  String usuario = 'Usuário';

  bool estaLogado = false;

  //musicas
  bool estaCarregandoMusica = false;

  var feedMusicas = <Music>[];

  void setCarregando(bool valor) {
    estaCarregandoMusica = valor;
    notifyListeners();
  }

  // No MyAppState em app_state.dart

  Future<void> carregarMusicasDoFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // No seu MusicService você salvou em 'playlist', então vamos ler de 'playlist'
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('playlist') // Ajustado para o nome que usamos no upload
          .orderBy('criadoEm', descending: true)
          .get();

      listamusicas.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        listamusicas.add(Music(
          id: doc.id,
          titulo: data['nome'] ?? 'Sem título',
          musicPath: data['url'] ?? '',
          artista: data['artista'] ??
              'Você', // Se não tiver artista, assume que fui eu
        ));
      }
      notifyListeners();
    }
  }

  Future<void> carregarFeedGlobal() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  setCarregando(true); // Ativa o spinner na tela

  try {
    // 1. Coleta IDs para ignorar (O que você já curtiu ou deu dislike)
    final dislikesSnapshot = await FirebaseFirestore.instance
        .collection('usuarios').doc(user.uid).collection('dislikes').get();

    final likesSnapshot = await FirebaseFirestore.instance
        .collection('usuarios').doc(user.uid).collection('playlist').get();

    final idsIgnorados = <String>{};
    for (var doc in dislikesSnapshot.docs) idsIgnorados.add(doc['musicId']);
    for (var doc in likesSnapshot.docs) idsIgnorados.add(doc['url']);

    // 2. Busca Global em todas as coleções 'playlist'
    final snapshot = await FirebaseFirestore.instance
        .collectionGroup('playlist')
        .limit(50)
        .get();

    feedMusicas.clear();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final url = data['url'] ?? '';
      
      // Identifica o dono da música pelo caminho: usuarios/{UID}/playlist/{DOC}
      final donoId = doc.reference.parent.parent?.id;

      // FILTROS: 
      // - Não ser música do próprio usuário
      // - Não estar nos ignorados (dislikes)
      // - Não estar nos curtidos (likes)
      if (donoId == user.uid || idsIgnorados.contains(doc.id) || idsIgnorados.contains(url)) {
        continue;
      }

      feedMusicas.add(Music(
        id: doc.id,
        titulo: data['nome'] ?? 'Sem Título',
        musicPath: url,
        artista: data['artista'] ?? 'Artista da Comunidade',
      ));
    }
  } catch (e) {
    debugPrint("Erro ao carregar feed global: $e");
  } finally {
    setCarregando(false); // Desativa o spinner
    notifyListeners();
  }
}

// Função do botão "Coração" (Like) - Atualizada com Artista
  Future<void> curtirMusica(Music musica) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('playlist')
        .add({
      'nome': musica.titulo,
      'url': musica.musicPath,
      'artista': musica.artista, // <--- Salva o artista
      'curtidoEm': Timestamp.now(),
      'origem': 'feed'
    });

    // Remove do feed pois já foi salva
    feedMusicas.remove(musica);
    notifyListeners();
  }

// Função do botão "X" (Dislike)
  Future<void> descurtirMusica(Music musica) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Salva apenas o ID para nunca mais mostrar
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('dislikes')
        .add({
      'musicId': musica.id,
      'url': musica.musicPath,
      'data': Timestamp.now(),
    });

    // Remove da lista local instantaneamente
    feedMusicas.remove(musica);
    notifyListeners();
  }

//usuario
  Future<void> salvarTarefaNoFirebase(String textoTarefa) async {
    if (textoTarefa.isEmpty) return; // Evita salvar texto vazio

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('tarefas')
          .doc();

      await docRef.set({
        'titulo': textoTarefa,
        'criadoEm': Timestamp.now(),
        'concluida': false,
      });

      // --- AMARRAÇÃO IMPORTANTE ---
      // Após salvar na nuvem, adicionamos na lista local para a tela atualizar na hora!
      listaTarefas.add(textoTarefa.isNotEmpty
          ? Tarefa(id: docRef.id, titulo: textoTarefa)
          : Tarefa(id: docRef.id, titulo: 'Sem título'));
      notifyListeners();
    }
  }

  Future<void> carregarTarefasDoFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('tarefas')
          .orderBy('criadoEm', descending: true)
          .get();

      listaTarefas.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        // MUDANÇA 2: Criamos o objeto Tarefa com ID e Título
        listaTarefas.add(
          Tarefa(
            id: doc.id, // <--- AQUI ESTÁ A MÁGICA DA UNICIDADE
            titulo: data['titulo'] ?? 'Sem título',
          ),
        );
      }
      notifyListeners();
    }
  }

  Future<void> carregarNomeUsuario() async {
    usuario = await userService.fetchUserName();
    notifyListeners();
  }

//anotation
  Future<void> salvarAnotation(String textoAnotation) async {
    // Lógica para salvar a anotação no Firebase]
    if (textoAnotation.isEmpty) return; // Evita salvar texto vazio

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('anotations')
          .doc();

      await docRef.set({
        'titulo': textoAnotation,
        'criadoEm': Timestamp.now(),
      });
      listaAnotation.add(textoAnotation.isNotEmpty
          ? Anotation(id: docRef.id, titulo: textoAnotation)
          : Anotation(
              id: docRef.id,
              titulo: 'Sem título')); // Adiciona a anotação na lista local
      notifyListeners();
    }
  }

  Future<void> carregarAnotation() async {
    final usuarioUid = FirebaseAuth.instance.currentUser;

    if (usuarioUid != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuario')
          .doc(usuarioUid.uid)
          .collection('anotations')
          .get();

      listaAnotation.clear();
      for (var snap in snapshot.docs) {
        final dataSnap = snap.data();
        listaAnotation.add(Anotation(id: snap.id, titulo: dataSnap['titulo']));
      }
      notifyListeners();
    }
  }

//palavras favoritas
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }

//tarefas
  void removeTarefa(String palavra) {
    listaTarefas.remove(palavra);
    notifyListeners();
  }

  void addTarefaLocal(Tarefa tarefa) {
    listaTarefas.add(tarefa);
    notifyListeners();
  }

//ordereded listview
  void reorderTarefa(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = listaTarefas.removeAt(oldIndex);
    listaTarefas.insert(newIndex, item);
    notifyListeners();
  }
}
