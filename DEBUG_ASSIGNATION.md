# 🔍 Guide de débogage - Problème d'assignation

## 📋 Symptômes

1. ✅ Les utilisateurs disponibles s'affichent correctement dans le dialog
2. ✅ Le bouton "Assigner" fonctionne (notification verte)
3. ❌ Le badge "X assigné(s)" n'apparaît PAS dans la TaskTile
4. ❌ Les tâches assignées n'apparaissent PAS chez l'utilisateur assigné

## 🎯 Points de vérification

### 1. Vérifier que les règles Firestore sont déployées

**CRITIQUE** : Sans règles déployées, les mises à jour Firestore échoueront silencieusement.

1. Allez sur : https://console.firebase.google.com/project/flutter-todo-web-305fb/firestore/rules
2. Vérifiez que les règles contiennent :
   ```
   // Règles pour la collection 'users'
   match /users/{userId} {
     allow read: if request.auth != null;  // DOIT ÊTRE COMME ÇA
   }
   ```
3. Cliquez sur "Publier" si ce n'est pas déjà fait

### 2. Vérifier les données dans Firestore

1. Allez sur : https://console.firebase.google.com/project/flutter-todo-web-305fb/firestore/data
2. Ouvrez la collection `tasks`
3. Sélectionnez une tâche
4. **Vérifiez que le champ `assignedTo` existe et contient un tableau d'UIDs**
   - ✅ Bon exemple : `assignedTo: ["riXsDCyTOVZi0gyr3pKZUxAkjT02"]`
   - ❌ Mauvais : Champ absent ou vide `[]`

### 3. Analyser les logs de l'application

Lors de l'assignation, vous devriez voir dans la console :

```
📌 TaskService.assignUserToTask: taskId=abc123, userIdToAssign=xyz456
✅ TaskService.assignUserToTask: Succès
🎨 TaskTile: Affichage badge assignés - task.id=abc123, assignedCount=1, assignedTo=[xyz456]
```

**Si vous voyez ❌ erreurs** :

- Vérifiez les règles Firestore
- Vérifiez que la tâche existe
- Vérifiez les permissions

**Si vous NE voyez PAS les logs 📌** :

- L'assignation n'est pas appelée
- Vérifiez le code du dialog

**Si vous NE voyez PAS les logs 🎨** :

- La TaskTile ne reçoit pas la mise à jour
- Le Provider ne notifie pas les changements

### 4. Tester l'isolation des utilisateurs

Pour vérifier que les tâches assignées apparaissent bien :

1. **Compte A (créateur)** : Créez une tâche
2. **Compte A** : Assignez la tâche à Compte B
3. **Déconnectez-vous du Compte A**
4. **Connectez-vous au Compte B**
5. **Vérifiez** : La tâche doit apparaître dans la liste du Compte B

**Si la tâche n'apparaît pas** :

- Vérifiez que `assignedTo` contient bien l'UID du Compte B dans Firestore
- Vérifiez les logs du stream Firestore : `TaskService.tasksStream()`
- Vérifiez les règles de lecture : `request.auth.uid in resource.data.get('assignedTo', [])`

## 🛠️ Actions correctives

### Si l'assignation échoue silencieusement

1. **Ajoutez des try-catch** dans le dialog :

   ```dart
   try {
     await provider.assignUserToTask(widget.task.id, userId);
     print('✅ Assignation réussie');
   } catch (e) {
     print('❌ Erreur assignation: $e');
   }
   ```

2. **Vérifiez les permissions Firestore** :
   - L'utilisateur connecté doit être le créateur de la tâche
   - Règle : `allow update: if resource.data.userId == request.auth.uid`

### Si le badge n'apparaît pas

1. **Vérifiez que TaskTile reçoit la tâche mise à jour** :

   - Le Provider doit émettre `notifyListeners()` après l'assignation
   - Le stream Firestore doit émettre la nouvelle version de la tâche

2. **Forcez un rebuild** du widget après assignation :
   - Le dialog utilise `context.watch<TaskProvider>()` ✅
   - Le TaskListScreen écoute le Provider ✅

### Si la tâche n'apparaît pas chez l'utilisateur assigné

1. **Vérifiez la requête Firestore** :

   ```dart
   // Dans tasksStream(), vérifiez que cette requête existe :
   final assignedTasksStream = col
       .where('assignedTo', arrayContains: uid)
       .orderBy('createdAt', descending: true)
       .snapshots()
   ```

2. **Vérifiez l'index Firestore** :
   - Allez sur : https://console.firebase.google.com/project/flutter-todo-web-305fb/firestore/indexes
   - Index requis : Collection `tasks`, Champs `assignedTo` (Array-contains) + `createdAt` (Descending)

## 📊 Checklist de test

- [ ] Règles Firestore déployées
- [ ] Index Firestore créés (userId+createdAt, assignedTo+createdAt)
- [ ] Logs d'assignation visibles (📌 et ✅)
- [ ] Champ `assignedTo` visible dans Firestore Data
- [ ] Badge "X assigné(s)" visible dans la tâche
- [ ] Tâche assignée visible chez l'utilisateur B
- [ ] Désassignation fonctionne (icône X dans le chip)
- [ ] Compteur se met à jour en temps réel

## 🎓 Commandes utiles

### Hot reload

```bash
r  # Dans le terminal Flutter
```

### Redémarrage complet

```bash
R  # Dans le terminal Flutter
```

### Voir les logs Firestore

Ajoutez dans `task_service.dart` :

```dart
_tasksSub = _taskService.tasksStream().listen(
  (list) {
    debugPrint('🔄 Stream Firestore: ${list.length} tâches reçues');
    for (var task in list) {
      debugPrint('  - ${task.title}: assignedTo=${task.assignedTo}');
    }
    // ...
  }
);
```
