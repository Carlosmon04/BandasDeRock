import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewUserPage extends StatelessWidget {
  NewUserPage({super.key});

  final nombreController = TextEditingController(text: '');
  final albumController = TextEditingController(text: '');
  final lanzamientoController = TextEditingController(text: 'DD/MM/YY');
  final votosController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Nueva Banda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nombre',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: albumController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Album',
                ),
              ),
              const SizedBox(height: 16.0),
               TextField(
                controller: lanzamientoController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Lanzamiento',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: votosController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Votos',
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  // Add user to Firebase
                  //obtener los valores de los textfields
                  final data = {
                    'Nombre': nombreController.text,
                    'Album': albumController.text,
                    'Lanzamiento': lanzamientoController.text,
                    'Votos' : int.parse(votosController.text)
                  };

                  final instance = FirebaseFirestore.instance;

                  //mostrar un icono de carga

                  //agregar con un ID automatico
                  final respuesta =
                      await instance.collection('Bandas').add(data);

                  // final respuesta = instance
                  //             .collection('usuarios/123/asignatutas_asignadas')
                  //             .add(data);

                  // final respuesta = instance
                  //     .collection('usuarios')
                  //     .doc('123')
                  //     .collection('asignatutas_asignadas')
                  //     .doc()
                  //     .set(data);

                  print(respuesta);
                  Navigator.pop(context);
                 // Navigator.pushNamed(context, );
                },
                child: const Text('Agregar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}