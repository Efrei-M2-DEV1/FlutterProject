import 'package:cloud_firestore/cloud_firestore.dart';

/// Script de migration pour ajouter le champ assignedTo aux tâches existantes
class TaskMigration {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Migrer toutes les tâches pour ajouter le champ assignedTo
  Future<void> migrateAllTasks() async {
    print('🔄 Début de la migration des tâches...');

    try {
      // Récupérer toutes les tâches
      final snapshot = await _firestore.collection('tasks').get();

      print('📊 ${snapshot.docs.length} tâches trouvées');

      int migrated = 0;
      int skipped = 0;

      // Mettre à jour chaque tâche
      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Vérifier si le champ assignedTo existe déjà
        if (!data.containsKey('assignedTo')) {
          await doc.reference.update({
            'assignedTo': [], // Tableau vide par défaut
          });
          migrated++;
          print('✅ Tâche ${doc.id} migrée');
        } else {
          skipped++;
          print('⏭️  Tâche ${doc.id} déjà migrée');
        }
      }

      print('✅ Migration terminée !');
      print('   - Tâches migrées: $migrated');
      print('   - Tâches déjà à jour: $skipped');
      print('   - Total: ${snapshot.docs.length}');
    } catch (e) {
      print('❌ Erreur lors de la migration: $e');
      rethrow;
    }
  }

  /// Vérifier si la migration est nécessaire
  Future<bool> needsMigration() async {
    try {
      final snapshot = await _firestore.collection('tasks').limit(1).get();

      if (snapshot.docs.isEmpty) {
        print('ℹ️  Aucune tâche dans la base de données');
        return false;
      }

      final firstTask = snapshot.docs.first.data();
      final needsMigration = !firstTask.containsKey('assignedTo');

      if (needsMigration) {
        print('⚠️  Migration nécessaire - champ assignedTo manquant');
      } else {
        print('✅ Pas de migration nécessaire');
      }

      return needsMigration;
    } catch (e) {
      print('❌ Erreur lors de la vérification: $e');
      return false;
    }
  }
}
