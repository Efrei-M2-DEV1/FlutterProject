import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreTestWidget extends StatefulWidget {
  const FirestoreTestWidget({super.key});

  @override
  State<FirestoreTestWidget> createState() => _FirestoreTestWidgetState();
}

class _FirestoreTestWidgetState extends State<FirestoreTestWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _status = 'En attente...';
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _testFirestore();
  }

  Future<void> _testFirestore() async {
    _addLog('🔍 Test de connexion Firestore...');

    try {
      _addLog('📖 Lecture de la collection tasks...');
      final snapshot = await _firestore.collection('tasks').get();
      _addLog('✅ Collection tasks lue avec succès');
      _addLog('📊 Nombre de documents: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        _addLog('⚠️ Aucune tâche trouvée');
        _addLog('📝 Tentative de création d\'une tâche de test...');
        final docRef = await _firestore.collection('tasks').add({
          'title': 'Tâche de test',
          'description': 'Créée automatiquement pour tester Firestore',
          'isCompleted': false,
          'priority': 2,
          'createdAt': Timestamp.now(),
          'tags': [],
        });
        _addLog('✅ Tâche de test créée avec ID: ${docRef.id}');
      } else {
        _addLog('📝 Tâches trouvées:');
        for (var doc in snapshot.docs) {
          _addLog('  - ${doc.data()['title']} (ID: ${doc.id})');
        }
      }

      setState(() {
        _status = '✅ Firestore fonctionne !';
      });
    } catch (e) {
      _addLog('❌ ERREUR: $e');
      setState(() {
        _status = '❌ Erreur Firestore';
      });
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add(message);
    });
    debugPrint(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Firestore'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _status,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Logs:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(_logs[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _testFirestore,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
