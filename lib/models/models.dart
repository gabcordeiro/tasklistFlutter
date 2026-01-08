// ARQUIVO: lib/models/models.dart

class Tarefa {
  final String id;
  final String titulo;
  Tarefa({required this.id, required this.titulo});
}

class Anotation {
  final String id;
  final String titulo;
  Anotation({required this.id, required this.titulo});
}

class Music {
  final String id;
  final String titulo;
  final String musicPath;
  final String artista;

  Music({
    required this.id,
    required this.titulo,
    required this.musicPath,
    this.artista = 'Desconhecido',
  });
}