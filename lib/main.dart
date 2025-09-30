import 'package:flutter/material.dart';
import 'database_helper.dart'; // <--- IMPORTACIÓN CORREGIDA
import 'libros.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
    final items = await dbHelper.getItems();
    setState(() {
      this.items = items;
    });
  }

  void _mostrarFormulario([int? id]) async {
    if (id != null) {
      final libroExistente = items.firstWhere((item) => item.id == id);
      _tituloController.text = libroExistente.tituloLibro;
    } else {
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
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(hintText: id == null ? 'Ingrese el título' : 'Editar título'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_tituloController.text.isEmpty) return; // Evitar títulos vacíos
                if (id == null) {
                  await _agregarNuevoLibro();
                } else {
                  await _actualizarLibro(id);
                }
                _tituloController.text = '';
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Agregar' : 'Actualizar'),
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
        title: const Text("SqlLite Flutter"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final libro = items[index];
          return ListTile(
            title: Text(libro.tituloLibro),
            subtitle: Text('ID: ${libro.id}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: () => _eliminarLibro(libro.id!),
            ),
            onTap: () => _mostrarFormulario(libro.id),
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