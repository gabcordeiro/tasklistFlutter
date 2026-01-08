// ARQUIVO: lib/providers/app_state.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/user_service.dart';

class MyAppState extends ChangeNotifier {
  // --- Serviços e Estado ---
  final userService = UserService();
  String usuario = 'Usuário';
  bool estaLogado = false;
  
  // --- Tutorial ---
  var current = WordPair.random();
  var favorites = <WordPair>[];

  // --- Listas ---
  var listaTarefas = <Tarefa>[];
  var listaAnotation = <Anotation>[];
  var listamusicas = <Music>[]; // Minhas músicas
  var feedMusicas = <Music>[];  // Feed Global
  
  bool estaCarregandoMusica = false;

  MyAppState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        estaLogado = true;
        carregarNomeUsuario();
        carregarTarefasDoFirebase();
        carregarAnotation();
        carregarMusicasDoFirebase();
      } else {
        limparDadosLocais();
      }
      notifyListeners();
    });
  }

  void setCarregando(bool valor) {
    estaCarregandoMusica = valor;
    notifyListeners();
  }

  Future<void> carregarNomeUsuario() async {
    usuario = await userService.fetchUserName();
    notifyListeners();
  }

  void limparDadosLocais() {
    listamusicas.clear();
    feedMusicas.clear();
    listaTarefas.clear();
    listaAnotation.clear();
    favorites.clear();
    estaLogado = false;
    usuario = 'Usuário';
    notifyListeners();
  }

  // --- MÚSICA: Playlist Pessoal ---

  Future<void> carregarMusicasDoFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('playlist')
          .orderBy('criadoEm', descending: true)
          .get();

      listamusicas.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        listamusicas.add(Music(
          id: doc.id,
          titulo: data['nome'] ?? 'Sem título',
          musicPath: data['url'] ?? '',
          artista: data['artista'] ?? 'Você',
        ));
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Erro playlist: $e");
    }
  }

  Future<void> deletarMusica(Music musica) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('playlist')
          .doc(musica.id)
          .delete();

      listamusicas.removeWhere((m) => m.id == musica.id);
      notifyListeners();
    } catch (e) {
      debugPrint("Erro deletar: $e");
    }
  }

  // --- MÚSICA: Feed Global ---

  Future<void> carregarFeedGlobal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setCarregando(true);

    try {
      // Pega o que devo ignorar (Dislikes e Meus uploads)
      final dislikes = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('dislikes')
          .get();

      final minhas = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('playlist')
          .get();

      final ignorar = <String>{};
      for (var d in dislikes.docs) ignorar.add(d['url']);
      for (var m in minhas.docs) ignorar.add(m['url']);

      // Busca tudo (Nota: em prod, usar limit())
      final snapshot = await FirebaseFirestore.instance
          .collectionGroup('playlist')
          .get();

      feedMusicas.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final url = data['url'] ?? '';

        if (ignorar.contains(url)) continue;

        feedMusicas.add(Music(
          id: doc.id,
          titulo: data['nome'] ?? 'Sem Título',
          musicPath: url,
          artista: data['artista'] ?? 'Produtor',
        ));
      }
    } catch (e) {
      debugPrint("Erro Feed: $e");
    } finally {
      setCarregando(false);
    }
  }

  // --- MÚSICA: Interações ---

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
      'artista': musica.artista,
      'criadoEm': Timestamp.now(), // Usar 'criadoEm' para manter padrão de ordenação
      'origem': 'feed_like'
    });

    listamusicas.insert(0, musica);
    feedMusicas.remove(musica);
    notifyListeners();
  }

  Future<void> descurtirMusica(Music musica) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('dislikes')
        .add({
      'musicId': musica.id,
      'url': musica.musicPath,
      'data': Timestamp.now(),
    });

    feedMusicas.remove(musica);
    notifyListeners();
  }

  Future<void> removerDosCurtidos(Music musica) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('playlist')
          .doc(musica.id)
          .delete();

      // Opcional: Remover dos dislikes se existir, para poder aparecer no feed de novo
      final dislikeQuery = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('dislikes')
          .where('url', isEqualTo: musica.musicPath)
          .get();

      for (var doc in dislikeQuery.docs) {
        await doc.reference.delete();
      }

      listamusicas.removeWhere((m) => m.id == musica.id);
      carregarFeedGlobal(); // Atualiza feed
      notifyListeners();
    } catch (e) {
      debugPrint("Erro remover curtida: $e");
    }
  }

  // --- TAREFAS ---

  Future<void> salvarTarefaNoFirebase(String textoTarefa) async {
    if (textoTarefa.isEmpty) return;
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

      listaTarefas.insert(0, Tarefa(id: docRef.id, titulo: textoTarefa));
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
        listaTarefas.add(Tarefa(id: doc.id, titulo: doc['titulo'] ?? ''));
      }
      notifyListeners();
    }
  }

  void removeTarefa(Tarefa tarefa) {
    listaTarefas.remove(tarefa);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('tarefas')
          .doc(tarefa.id)
          .delete();
    }
    notifyListeners();
  }

  // --- ANOTAÇÕES ---

  Future<void> salvarAnotation(String textoAnotation) async {
    if (textoAnotation.isEmpty) return;
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

      listaAnotation.add(Anotation(id: docRef.id, titulo: textoAnotation));
      notifyListeners();
    }
  }

  Future<void> carregarAnotation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('anotations')
          .orderBy('criadoEm', descending: true)
          .get();

      listaAnotation.clear();
      for (var snap in snapshot.docs) {
        listaAnotation.add(Anotation(
          id: snap.id, 
          titulo: snap.data()['titulo'] ?? ''
        ));
      }
      notifyListeners();
    }
  }

  // --- TUTORIAL / WORDPAIRS ---
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
  void reorderTarefa(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = listaTarefas.removeAt(oldIndex);
    listaTarefas.insert(newIndex, item);
    notifyListeners();
  }
  Future<void> resetarDislikesECarregarFeed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setCarregando(true);

    try {
      final dislikesSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('dislikes')
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in dislikesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print("Histórico de dislikes limpo!");
      await carregarFeedGlobal();
    } catch (e) {
      print("Erro ao resetar dislikes: $e");
    } finally {
       // setCarregando(false); // carregarFeedGlobal já faz isso
    }
  }
  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}