# 🔍 Vérification et Correction de l'Assignation

## Problème identifié

Les logs montrent que l'assignation "réussit" côté client mais le tableau `assignedTo` reste vide dans Firestore. Cela indique que **Firestore rejette silencieusement la mise à jour**.

## 🎯 Solution en 3 étapes

### Étape 1 : Déployer les règles simplifiées

1. **Allez sur** : https://console.firebase.google.com/project/flutter-todo-web-305fb/firestore/rules

2. **Remplacez TOUT par** :

```plaintext
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Règles pour la collection 'users'
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && request.auth.uid == userId;
      allow delete: if false;
    }

    // Règles pour la collection 'tasks'
    match /tasks/{taskId} {
      // Lecture : autorisée si créateur OU assigné
      allow read: if request.auth != null && (
        resource.data.userId == request.auth.uid ||
        request.auth.uid in resource.data.get('assignedTo', [])
      );

      // Création : autorisée si authentifié
      allow create: if request.auth != null &&
        request.resource.data.userId == request.auth.uid;

      // Mise à jour : autorisée si créateur (userId ne change pas)
      allow update: if request.auth != null &&
        resource.data.userId == request.auth.uid &&
        request.resource.data.userId == resource.data.userId;

      // Suppression : autorisée si créateur
      allow delete: if request.auth != null &&
        resource.data.userId == request.auth.uid;
    }
  }
}
```

3. **Cliquez sur "Publier"**

4. **Attendez 5 secondes**

### Étape 2 : Ajouter le champ assignedTo aux tâches existantes

Les tâches créées avant la fonctionnalité d'assignation n'ont PAS le champ `assignedTo`. Il faut l'initialiser.

**Option A : Via la console Firebase (RECOMMANDÉ)**

1. **Allez sur** : https://console.firebase.google.com/project/flutter-todo-web-305fb/firestore/data

2. **Pour chaque tâche qui n'a PAS le champ `assignedTo`** :
   - Cliquez sur la tâche
   - Cliquez sur "Ajouter un champ"
   - Nom : `assignedTo`
   - Type : `array` (tableau)
   - Valeur : Laissez vide `[]`
   - Cliquez sur "Ajouter"

**Option B : Script dans la console Firebase**

1. Allez sur : https://console.firebase.google.com/project/flutter-todo-web-305fb/firestore/data

2. Ouvrez la console JavaScript du navigateur (F12)

3. Collez ce script :

```javascript
// ATTENTION : Exécuter ce script UNIQUEMENT si vous savez ce que vous faites
// Il modifie toutes les tâches qui n'ont pas le champ assignedTo

const db = firebase.firestore();
const batch = db.batch();

db.collection("tasks")
  .get()
  .then((snapshot) => {
    let count = 0;
    snapshot.docs.forEach((doc) => {
      if (!doc.data().assignedTo) {
        batch.update(doc.ref, { assignedTo: [] });
        count++;
      }
    });

    if (count > 0) {
      batch.commit().then(() => {
        console.log(`✅ ${count} tâches mises à jour avec assignedTo: []`);
      });
    } else {
      console.log("✅ Toutes les tâches ont déjà le champ assignedTo");
    }
  });
```

**Option C : Créer une nouvelle tâche pour tester**

Si vous voulez juste tester, créez une NOUVELLE tâche (qui aura automatiquement `assignedTo: []`) et testez l'assignation dessus.

### Étape 3 : Tester l'assignation

1. **Redémarrez votre app** :

   - Dans le terminal Flutter, tapez `R` (Hot Restart)

2. **Ouvrez une tâche**

3. **Cliquez sur "Gérer les utilisateurs assignés"**

4. **Assignez un utilisateur**

5. **Vérifiez dans les logs** :

   ```
   📌 TaskService.assignUserToTask: taskId=xxx, userIdToAssign=yyy
   ✅ TaskService.assignUserToTask: Succès
   ```

6. **Vérifiez dans Firebase** :
   - Allez sur : https://console.firebase.google.com/project/flutter-todo-web-305fb/firestore/data
   - Sélectionnez la tâche
   - Le champ `assignedTo` doit contenir : `["UID_de_l_utilisateur"]`

## 🐛 Si ça ne fonctionne toujours pas

### Vérification 1 : Les règles sont-elles vraiment déployées ?

- Rafraîchissez la page des règles
- Vérifiez que la ligne 33 est bien : `request.resource.data.userId == resource.data.userId;`
- Pas de mention de `ownerName`

### Vérification 2 : Y a-t-il des erreurs dans la console ?

Regardez les logs Flutter. Si vous voyez :

```
❌ TaskService.assignUserToTask: Erreur permission-denied - Missing or insufficient permissions
```

Cela signifie que les règles ne sont pas déployées ou incorrectes.

### Vérification 3 : Le champ assignedTo existe-t-il ?

Dans Firestore Data, si le champ `assignedTo` n'existe pas du tout, créez-le manuellement :

- Type : `array`
- Valeur : `[]`

## 📊 Checklist finale

- [ ] Règles Firestore déployées (version simplifiée)
- [ ] Toutes les tâches ont le champ `assignedTo` (même si vide)
- [ ] App redémarrée avec `R`
- [ ] Assignation testée
- [ ] Champ `assignedTo` vérifié dans Firebase Data
- [ ] Badge "X assigné(s)" visible dans l'UI

## 🎯 Résultat attendu

Après ces 3 étapes :

1. **Dans l'UI** : Le badge "1 assigné" doit apparaître
2. **Dans Firebase** : `assignedTo: ["riXsDCyTOVZi0gyr3pKZUxAkjT02"]`
3. **Chez l'utilisateur assigné** : La tâche apparaît dans sa liste
