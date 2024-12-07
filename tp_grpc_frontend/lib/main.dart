import 'package:tp_grpc/GrpcClient.dart';
import 'package:flutter/material.dart';
import 'generated/compte.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter gRPC Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ComptesPage(),
    );
  }
}

class ComptesPage extends StatefulWidget {
  final grpcClient = GrpcClient();
  ComptesPage({super.key});

  @override
  State<ComptesPage> createState() => _ComptePaState();
}

class _ComptePaState extends State<ComptesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liste des comptes"),
      ),
      body: FutureBuilder(
          future: widget.grpcClient.fetchAllComptes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Aucun compte trouvé.'));
            } else {
              final comptes = snapshot.data;
              return ListView.separated(
                itemCount: comptes!.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                ),
                itemBuilder: (context, index) {
                  final compte = comptes[index];
                  return ListTile(
                    title: Text(
                      'Type : ${compte.type}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text('Solde : ${compte.solde}'),
                        Text('Créé le : ${compte.dateCreation}'),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          widget.grpcClient.deleteCompte(compte.id);
                        });
                      },
                      icon: Icon(Icons.delete, color: Colors.red),
                      
                    ),
                  );
                },
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addCompteDialog(widget.grpcClient);
        },
        tooltip: 'Ajouter un compte',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addCompteDialog(GrpcClient grpcClient) {
    return showDialog(
      context: context,
      builder: (context) {
        String type = 'COURANT';
        String dateCreation = '';
        double solde = 0.0;
        return AlertDialog(
          title: Text(
            'Ajouter un compte',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Type',
                    labelStyle: TextStyle(color: Colors.blue),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                    ),
                  ),
                  value: type,
                  items: [
                    DropdownMenuItem(value: 'COURANT', child: Text('COURANT')),
                    DropdownMenuItem(value: 'EPARGNE', child: Text('EPARGNE')),
                  ],
                  onChanged: (value) {
                    type = value!;
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Solde',
                    labelStyle: TextStyle(color: Colors.blue),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    solde = double.tryParse(value) ?? 0.0;
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Date de Création',
                    labelStyle: TextStyle(color: Colors.blue),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                    ),
                  ),
                  onChanged: (value) {
                    dateCreation = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Couleur personnalisée
                foregroundColor: Colors.white, // Couleur du texte
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Bords arrondis
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Espacement interne
              ),
              onPressed: () async {
                if (type.isEmpty || dateCreation.isEmpty || solde <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez remplir tous les champs correctement!')),
                  );
                  return;
                }
                try {
                  final newCompte = await grpcClient.saveCompte(
                    type,
                    solde,
                    dateCreation,
                  );
                  setState(() {
                    grpcClient.fetchAllComptes();
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
}
