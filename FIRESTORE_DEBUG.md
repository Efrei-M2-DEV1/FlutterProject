# 🔧 Guide de débogage Firestore

## Problème actuel
Les tâches ne sont pas créées dans la console Firebase malgré une connexion réussie.

## ✅ Checklist de diagnostic

### 1. Vérifier l'authentification Firebase
- [ ] Ouvrir l'application : http://127.0.0.1:8082
- [ ] Se connecter avec : eric.amour2022@gmail.com
- [ ] Vérifier dans la console : https://console.firebase.google.com/project/flutter-todo-web-305fb/authentication/users

### 2. Vérifier les règles Firestore
- [ ] Ouvrir : https://console.firebase.google.com/project/flutter-todo-web-305fb/firestore/rules
- [ ] Vérifier que les règles permettent l'écriture

**Règles recommandées pour le développement :**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Règles pour la collection tasks
    match /tasks/{taskId} {
      // Autoriser lecture/écriture uniquement pour utilisateurs authentifiés
      allow read, write: if request.auth != null;
    }
  }
}
```

**Règles pour le test (TEMPORAIRE UNIQUEMENT) :**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /tasks/{taskId} {
      // ⚠️ ATTENTION : Règles ouvertes pour TEST uniquement !
      allow read, write: if true;
    }
  }
}
```

### 3. Utiliser la page de debug
- [ ] Dans l'application, cliquer sur l'icône 🐛 en haut à droite
- [ ] Cliquer sur "Test écriture" pour créer une tâche de test
- [ ] Observer les logs pour identifier l'erreur exacte

### 4. Vérifier la console navigateur
- [ ] Ouvrir les DevTools du navigateur (F12)
- [ ] Aller dans l'onglet "Console"
- [ ] Essayer de créer une tâche
- [ ] Noter les erreurs affichées

## 🔍 Erreurs courantes

### Erreur : "Missing or insufficient permissions"
**Cause :** Les règles Firestore bloquent l'écriture

**Solution :**
1. Aller dans https://console.firebase.google.com/project/flutter-todo-web-305fb/firestore/rules
2. Mettre à jour les règles (voir ci-dessus)
3. Cliquer sur **"Publier"** (en haut à droite)
4. Attendre 1-2 minutes pour que les règles se propagent
5. Réessayer

### Erreur : "No user signed in"
**Cause :** Utilisateur non connecté

**Solution :**
1. Se déconnecter de l'application
2. Se reconnecter avec eric.amour2022@gmail.com
3. Réessayer de créer une tâche

### Collection "tasks" n'apparaît pas
**Cause :** La collection n'est créée qu'après la première écriture réussie

**Solution :**
1. Vérifier que les règles Firestore sont correctes
2. Créer une première tâche avec succès
3. Rafraîchir la console Firebase : https://console.firebase.google.com/project/flutter-todo-web-305fb/firestore/data

## 📊 Vérification des données

### Voir les données dans Firestore
1. Ouvrir : https://console.firebase.google.com/project/flutter-todo-web-305fb/firestore/data
2. Chercher la collection "tasks"
3. Si elle existe, vérifier les documents à l'intérieur

### Structure attendue d'un document task
```json
{
  "title": "Ma tâche",
  "description": "Description de la tâche",
  "isCompleted": false,
  "priority": 2,
  "createdAt": "Timestamp",
  "dueDate": null,
  "tags": []
}
```

## 🛠️ Actions de dépannage

### Si les règles sont correctes mais ça ne fonctionne toujours pas

1. **Vérifier la connexion Firebase dans la console navigateur :**
   ```javascript
   // Dans la console navigateur (F12)
   firebase.apps.length  // Doit retourner 1 ou plus
   ```

2. **Tester manuellement dans la console navigateur :**
   ```javascript
   // Dans la console navigateur (F12)
   firebase.firestore().collection('tasks').add({
     title: 'Test manuel',
     description: 'Test depuis console',
     isCompleted: false,
     priority: 2,
     createdAt: firebase.firestore.Timestamp.now(),
     tags: []
   }).then(doc => console.log('Créé:', doc.id))
   ```

3. **Vérifier les quotas Firebase :**
   - Ouvrir : https://console.firebase.google.com/project/flutter-todo-web-305fb/usage
   - Vérifier que vous n'avez pas atteint les limites

## 📝 Logs utiles

Pour voir les logs détaillés dans l'application :
1. Aller sur la page de debug (icône 🐛)
2. Les logs apparaîtront avec des codes couleur :
   - 🟢 Vert : Succès
   - 🔴 Rouge : Erreur
   - 🟠 Orange : Avertissement
   - 🔵 Cyan : Information

## 🎯 Prochaines étapes

Une fois que le test d'écriture fonctionne dans la page de debug :

1. ✅ La collection "tasks" devrait apparaître dans Firebase
2. Retourner à la page des tâches
3. Essayer de créer une tâche normale
4. Vérifier qu'elle apparaît dans la liste ET dans Firebase

## 📞 Besoin d'aide ?

Si après toutes ces vérifications ça ne fonctionne toujours pas :

1. Copier les logs de la page de debug
2. Copier les erreurs de la console navigateur (F12)
3. Vérifier une dernière fois les règles Firestore
4. Partager ces informations pour un diagnostic plus approfondi
