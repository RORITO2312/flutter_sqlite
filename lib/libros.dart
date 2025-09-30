class Libro {
  int? id;
  String tituloLibro;

  Libro({this.id, required this.tituloLibro});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tituloLibro': tituloLibro,
    };
  }
}