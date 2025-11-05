import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_colors.dart';

/// Page temporaire pour migrer les tâches existantes
class MigrationScreen extends StatefulWidget {
  const MigrationScreen({super.key});

  @override
  State<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends State<MigrationScreen> {
  bool _isMigrating = false;
  String _status = 'Prêt à migrer';
  int _totalTasks = 0;
  int _migratedTasks = 0;

  Future<void> _checkMigrationStatus() async {
    setState(() {
      _status = 'Vérification...';
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .get();

      int needsMigration = 0;
      for (var doc in snapshot.docs) {
        if (!doc.data().containsKey('assignedTo')) {
          needsMigration++;
        }
      }

      setState(() {
        _totalTasks = snapshot.docs.length;
        _status = needsMigration > 0
            ? '$needsMigration tâches sur $_totalTasks ont besoin de migration'
            : 'Toutes les tâches sont à jour !';
      });
    } catch (e) {
      setState(() {
        _status = 'Erreur: $e';
      });
    }
  }

  Future<void> _runMigration() async {
    setState(() {
      _isMigrating = true;
      _status = 'Migration en cours...';
      _migratedTasks = 0;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .get();

      setState(() {
        _totalTasks = snapshot.docs.length;
      });

      final batch = FirebaseFirestore.instance.batch();
      int count = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (!data.containsKey('assignedTo')) {
          batch.update(doc.reference, {'assignedTo': []});
          count++;
          setState(() {
            _migratedTasks = count;
            _status = 'Migration: $count/$_totalTasks tâches...';
          });
        }
      }

      await batch.commit();

      setState(() {
        _isMigrating = false;
        _status = '✅ Migration terminée ! $count tâches migrées.';
      });

      // Retourner à l'écran précédent après 2 secondes
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop();
      });
    } catch (e) {
      setState(() {
        _isMigrating = false;
        _status = '❌ Erreur: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkMigrationStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Migration des Tâches'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isMigrating
                    ? Icons.sync
                    : _status.contains('✅')
                    ? Icons.check_circle
                    : Icons.warning,
                size: 80,
                color: _isMigrating
                    ? AppColors.primary
                    : _status.contains('✅')
                    ? AppColors.success
                    : AppColors.warning,
              ),
              const SizedBox(height: 32),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (_isMigrating && _totalTasks > 0) ...[
                const SizedBox(height: 24),
                LinearProgressIndicator(
                  value: _totalTasks > 0 ? _migratedTasks / _totalTasks : 0,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text('$_migratedTasks / $_totalTasks'),
              ],
              const SizedBox(height: 48),
              if (!_isMigrating && !_status.contains('✅'))
                ElevatedButton.icon(
                  onPressed: _runMigration,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Lancer la Migration'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _checkMigrationStatus,
                child: const Text('Vérifier à nouveau'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
