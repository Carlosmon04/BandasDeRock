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

  // This widget is the root of your application.
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
    // final users = firestore.collection('usuarios').get();
    final Todasbandas = firestore.collection('Bandas').snapshots();
    final borrar =  FirebaseFirestore.instance;



    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Todasbandas,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final listabandas = snapshot.data!.docs; // La lista de documentos

            return ListView.builder(
              itemCount: listabandas.length,
              itemBuilder: (context, index) {
                final banda = listabandas[index];

                // user.id;

                return ListTile(
                  title: Text(banda['Nombre']),
                  subtitle: Column(  crossAxisAlignment: CrossAxisAlignment.start, children:
                   [Text(banda['Album']),
                   Text(banda['Lanzamiento']),
                   ]
                   ),
                   trailing: GestureDetector(
    onTap: () {
      // Función de callback cuando se toca el icono
      print('Botón oprimido: ${banda['Nombre']}');

    borrar.collection('Bandas').where('Nombre', isEqualTo: banda['Nombre']).get().then((QuerySnapshot) {
      QuerySnapshot.docs.forEach((doc) {
       int votosactuales = doc['Votos'];
       int nuevosvotos = votosactuales + 1;
       doc.reference.update({'Votos': nuevosvotos});
       });
    });

    },
    child: Column(
      children: [
        const Icon(Icons.favorite_rounded,color: Colors.redAccent,),
        Text('${banda['Votos']}', style: const TextStyle(fontSize: 16),),
      ],
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
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}