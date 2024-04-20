import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class NewUserPage extends StatefulWidget {
  NewUserPage({Key? key}) : super(key: key);

  @override
  _NewUserPageState createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {
  final _formKey = GlobalKey<FormState>();
  final storage = FirebaseStorage.instance.ref();

  final nombreController = TextEditingController(text: '');
  final albumController = TextEditingController(text: '');
  final lanzamientoController = TextEditingController(text: '');
  final votosController = 0;

  String? urlImagen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Nueva Banda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nombre',
                    hintText: 'Nombre de Banda',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: albumController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Álbum',
                    hintText: 'Álbum de la banda',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el nombre del álbum';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    XFile? image = await picker.pickImage(source: ImageSource.gallery);

                    if (image != null) {
                      Reference imagenRef = storage.child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');

                      try {
                        await imagenRef.putFile(File(image.path));
                        urlImagen = await imagenRef.getDownloadURL();
                        print('Imagen subida exitosamente: $urlImagen');
                      } catch (e) {
                        print('Error al subir la imagen: $e');
                      }
                    }
                  },
                  child: const Text('Subir foto del álbum (Opcional)'),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: lanzamientoController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Lanzamiento',
                    hintText: 'DD/MM/YY',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la fecha de lanzamiento';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    final instance = FirebaseFirestore.instance;

                    if (_formKey.currentState!.validate()) {
                      final query = await instance.collection('Bandas').where('Nombre', isEqualTo: nombreController.text.trim()).get();
                      final quero = await instance.collection('Bandas').where('Album', isEqualTo: albumController.text.trim()).get();

                      if (query.docs.isEmpty && quero.docs.isEmpty) {
                        final data = {
                            'Nombre': nombreController.text,
                            'Album': albumController.text,
                            'Lanzamiento': lanzamientoController.text,
                            'Votos': votosController,
                            'URLimagen': urlImagen, 
                        };

                        final respuesta = await instance.collection('Bandas').add(data);

                        print(respuesta);

                        // Regresar a la pantalla anterior después de agregar los datos
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ya existe una banda con el mismo nombre o álbum')),
                        );
                      }
                    }
                  },
                  child: const Text('Agregar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}