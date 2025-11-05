import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Page de débogage pour tester la connexion Firestore
class DebugFirestorePage extends StatefulWidget {
  const DebugFirestorePage({super.key});

  @override
  State<DebugFirestorePage> createState() => _DebugFirestorePageState();
}

class _DebugFirestorePageState extends State<DebugFirestorePage> {
  final List<String> _logs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toIso8601String()}: $message');
    });
    debugPrint(message);
  }

  Future<void> _checkConnection() async {
    _addLog('🔍 Vérification de la connexion Firebase...');

    // 1. Vérifier Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _addLog('❌ Aucun utilisateur connecté !');
      return;
    }
    _addLog('✅ Utilisateur connecté: ${user.email}');
    _addLog('   UID: ${user.uid}');

    // 2. Vérifier Firestore
    try {
      final firestore = FirebaseFirestore.instance;
      _addLog('📊 Instance Firestore créée');

      // 3. Tester lecture de la collection tasks
      _addLog('📖 Tentative de lecture de la collection "tasks"...');
      final snapshot = await firestore.collection('tasks').get();
      _addLog('✅ Lecture réussie ! ${snapshot.docs.length} documents trouvés');

      // 4. Afficher les documents existants
      if (snapshot.docs.isEmpty) {
        _addLog('⚠️  Collection vide - aucune tâche trouvée');
      } else {
        for (final doc in snapshot.docs) {
          _addLog('   📄 Document ID: ${doc.id}');
          _addLog('      Data: ${doc.data()}');
        }
      }
    } catch (e) {
      _addLog('❌ ERREUR lors de la lecture: $e');
      if (e.toString().contains('Missing or insufficient permissions')) {
        _addLog('⚠️  PROBLÈME DE PERMISSIONS FIRESTORE !');
        _addLog('   Allez dans la console Firebase:');
        _addLog('   https://console.firebase.google.com/project/flutter-todo-web-305fb/firestore/rules');
        _addLog('   Et configurez les règles de sécurité');
      }
    }
  }

  Future<void> _testWrite() async {
    setState(() {
      _isLoading = true;
    });

    _addLog('✍️  Tentative de création d\'une tâche de test...');

    try {
      final firestore = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _addLog('❌ Aucun utilisateur connecté !');
        return;
      }

      final testTask = {
        'title': 'Tâche de test ${DateTime.now().toIso8601String()}',
        'description': 'Test de création depuis le debug',
        'isCompleted': false,
        'priority': 2, // Medium
        'createdAt': Timestamp.now(),
        'dueDate': null,
        'tags': <String>[],
      };

      _addLog('📝 Données à envoyer: $testTask');

      final docRef = await firestore.collection('tasks').add(testTask);
      _addLog('✅ Tâche créée avec succès !');
      _addLog('   Document ID: ${docRef.id}');

      // Relire pour vérifier
      await _checkConnection();
    } catch (e) {
      _addLog('❌ ERREUR lors de l\'écriture: $e');
      if (e.toString().contains('Missing or insufficient permissions')) {
        _addLog('⚠️  PROBLÈME DE PERMISSIONS FIRESTORE !');
        _addLog('   Les règles Firestore bloquent l\'écriture.');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showFirestoreRules() async {
    _addLog('📋 Règles Firestore recommandées:');
    _addLog('''
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /tasks/{taskId} {
      allow read, write: if request.auth != null;
    }
  }
}
''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Debug Firestore'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // Zone d'actions
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.orange.shade50,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _checkConnection,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Rafraîchir'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testWrite,
                    icon: const Icon(Icons.add),
                    label: const Text('Test écriture'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showFirestoreRules,
                    icon: const Icon(Icons.security),
                    label: const Text('Règles'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Zone de logs
          Expanded(
            child: Container(
              color: Colors.grey.shade900,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  Color color = Colors.white;
                  
                  if (log.contains('✅')) {
                    color = Colors.greenAccent;
                  } else if (log.contains('❌')) {
                    color = Colors.redAccent;
                  } else if (log.contains('⚠️')) {
                    color = Colors.orangeAccent;
                  } else if (log.contains('🔍') || log.contains('📖')) {
                    color = Colors.cyanAccent;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      log,
                      style: TextStyle(
                        color: color,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Indicateur de chargement
          if (_isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.orange,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _logs.clear();
          });
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.clear_all),
      ),
    );
  }
}
