import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'libros.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formulario SQLite',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController _tituloController = TextEditingController();
  List<Libro> items = [];

  @override
  void initState() {
    super.initState();
    _cargarListaLibros();
  }

  Future<void> _cargarListaLibros() async {
    final itemsCargados = await dbHelper.getItems();
    setState(() {
      items = itemsCargados;
    });
  }

  // SOLUCIÓN: Esta función implementa el formulario en un ModalBottomSheet
  void _mostrarFormulario([int? id]) async {
    // Si se pasa un ID, es para editar. Llenamos el campo de texto.
    if (id != null) {
      final libroExistente = items.firstWhere((item) => item.id == id);
      _tituloController.text = libroExistente.tituloLibro;
    } else {
      // Si no hay ID, es un libro nuevo. Limpiamos el campo.
      _tituloController.text = '';
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          // Esto hace que el formulario suba cuando aparece el teclado
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(hintText: id == null ? 'Ingrese el nuevo título' : 'Editar título'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_tituloController.text.isEmpty) return;

                if (id == null) {
                  await _agregarNuevoLibro();
                } else {
                  await _actualizarLibro(id);
                }
                
                // Limpiamos el texto y cerramos el formulario
                _tituloController.text = '';
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Agregar Nuevo' : 'Actualizar'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _agregarNuevoLibro() async {
    final nuevoLibro = Libro(tituloLibro: _tituloController.text);
    await dbHelper.insertLibro(nuevoLibro);
    _cargarListaLibros();
  }

  Future<void> _actualizarLibro(int id) async {
    await dbHelper.actualizar(
      'libros',
      {'tituloLibro': _tituloController.text},
      where: 'id = ?',
      whereArgs: [id],
    );
    _cargarListaLibros();
  }

  void _eliminarLibro(int id) async {
    await dbHelper.eliminar('libros', where: 'id = ?', whereArgs: [id]);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Libro eliminado correctamente')));
    _cargarListaLibros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Formulario en SQLite"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final libro = items[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(libro.tituloLibro),
              subtitle: Text('ID: ${libro.id}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _eliminarLibro(libro.id!),
              ),
              onTap: () => _mostrarFormulario(libro.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}