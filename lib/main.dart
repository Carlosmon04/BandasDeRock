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
    final todasBandas = firestore.collection('Bandas').snapshots();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: todasBandas,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final listaBandas = snapshot.data!.docs;

            return ListView.builder(
              itemCount: listaBandas.length,
              itemBuilder: (context, index) {
                final banda = listaBandas[index];

                final String? urlImagen = banda['URLimagen'] as String?;

                return Dismissible(
                  key: Key(banda.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    banda.reference.delete();
                  },
                  child: ListTile(
                    leading: urlImagen != null
                        ? Image.network(
                            urlImagen,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.image_not_supported, color: Colors.grey, size: 50);
                            },
                          )
                        : null,
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

                        if (urlImagen != null)
                        {
                             banda.reference.update({'Votos': (banda['Votos'] ?? 0) + 1});
                        }
                        else
                        {
                            ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No se puede votar por esta banda porque no tiene una imagen.')));
                        }
                        
                      },
                      child: Column(
                        children: [
                          Icon(Icons.favorite_rounded, color: Colors.redAccent),
                          Text('${banda['Votos'] ?? 0}', style: const TextStyle(fontSize: 16)),
                        ],
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