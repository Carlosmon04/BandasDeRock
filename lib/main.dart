import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bandasderock/firebase_options.dart';
import 'package:bandasderock/new_bandas_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bandas De Rock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Bandas'),
      routes: {
        '/new_banda': (context) => NewUserPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final Todasbandas = firestore.collection('Bandas').snapshots();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Todasbandas,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final listabandas = snapshot.data!.docs;

            return ListView.builder(
              itemCount: listabandas.length,
              itemBuilder: (context, index) {
                final banda = listabandas[index];

                return Dismissible(
                  key: Key(banda.id),
                  direction: DismissDirection.endToStart, // Permitir solo deslizamiento hacia la izquierda
                  background: Container(
                    color: Colors.red, // Color de fondo al deslizar
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    
                 FirebaseFirestore.instance.collection('Bandas').where('Nombre', isEqualTo:  banda['Nombre'])
           .get().then((QuerySnapshot){
            QuerySnapshot.docs.forEach((doc) {doc.reference.delete(); }
            );
           });

                    
                
                    // No se realiza ninguna acción al deslizar, ya que la acción se manejará mediante el GestureDetector
                  },
                  child: GestureDetector(
                    onLongPress: () {
                      // Lógica del gesto al deslizar hacia la izquierda
                      print('Gesto ejecutado: ${banda['Nombre']}');
                      
                      // Aquí puedes agregar la lógica que deseas ejecutar cuando se realice el gesto
                    },
                    child: ListTile(
                      title: Text(banda['Nombre']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(banda['Album']),
                          Text(banda['Lanzamiento']),
                        ],
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          // Función de callback cuando se toca el icono de votos
                          print('Botón oprimido: ${banda['Nombre']}');

                          // Incrementa el número de votos en 1
                          banda.reference.update({'Votos': (banda['Votos'] ?? 0) + 1});
                        },
                        child: Column(
                          children: [
                            Icon(Icons.favorite_rounded, color: Colors.redAccent),
                            Text('${banda['Votos'] ?? 0}', style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/new_banda');
        },
        tooltip: 'Nueva Banda',
        child: const Icon(Icons.add),
      ),
    );
  }
}
