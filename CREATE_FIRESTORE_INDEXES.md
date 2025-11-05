# 🔧 Création des Index Firestore - GUIDE RAPIDE

## ⚠️ Erreur Actuelle

Vous voyez cette erreur dans la console :

```
[cloud_firestore/failed-precondition] The query requires an index.
```

C'est **NORMAL** ! Notre nouveau système de privacy nécessite des index composites.

## ✅ Solution Rapide (2 minutes)

### Étape 1 : Cliquer sur les Liens

Dans votre terminal, vous voyez deux liens qui commencent par :

```
https://console.firebase.google.com/v1/r/project/flutter-todo-web-305fb/...
```

**Action** :

1. Copiez le **premier lien** (celui avec `userId`)
2. Collez-le dans votre navigateur
3. Cliquez sur **"Créer l'index"**
4. Attendez ~2-5 minutes (Firebase crée l'index en arrière-plan)

5. Répétez avec le **second lien** (celui avec `assignedTo`)
6. Cliquez sur **"Créer l'index"**
7. Attendez ~2-5 minutes

### Étape 2 : Vérifier la Création

1. Allez dans **Firebase Console** → **Firestore Database** → **Index**
2. Vous devriez voir 2 nouveaux index :
   - `tasks` : `userId (Ascending) + createdAt (Descending)`
   - `tasks` : `assignedTo (Array) + createdAt (Descending)`
3. Statut doit passer de **"Building"** à **"Enabled"**

### Étape 3 : Relancer l'App

Une fois les index créés (statut **Enabled**) :

```bash
# Appuyez sur 'R' dans le terminal Flutter pour Hot Restart
# OU relancez complètement
flutter run -d edge
```

## 🎯 Les Deux Index Nécessaires

### Index 1 : Tâches Créées (userId)

```
Collection : tasks
Fields indexed:
  - userId (Ascending)
  - createdAt (Descending)
  - __name__ (Descending)
Query scope: Collection
```

**Pourquoi ?** Pour récupérer rapidement toutes les tâches créées par un utilisateur, triées par date.

### Index 2 : Tâches Assignées (assignedTo)

```
Collection : tasks
Fields indexed:
  - assignedTo (Array-contains)
  - createdAt (Descending)
  - __name__ (Descending)
Query scope: Collection
```

**Pourquoi ?** Pour récupérer rapidement toutes les tâches où l'utilisateur est assigné, triées par date.

## 🚀 Après Création des Index

Une fois les index créés, votre application :

- ✅ Affichera uniquement VOS tâches
- ✅ Affichera les tâches où vous êtes assigné
- ✅ Sera rapide même avec des milliers de tâches
- ✅ Respectera la privacy (règles Firestore)

## 🔍 Vérification que Tout Fonctionne

1. **Connectez-vous** avec votre compte
2. **Créez une tâche** → elle s'affiche immédiatement
3. **Créez un second compte** dans un autre navigateur (mode incognito)
4. **Vérifiez** que les tâches du premier compte ne sont PAS visibles
5. **Retournez au premier compte** → Modifiez une tâche → "Assigner des utilisateurs" → Sélectionnez le second compte
6. **Vérifiez dans le second compte** → La tâche assignée est maintenant visible

## ⏱️ Temps de Création des Index

- **Petite base** (< 100 documents) : ~30 secondes - 2 minutes
- **Base moyenne** (100-1000 documents) : ~2-5 minutes
- **Grande base** (> 1000 documents) : ~5-15 minutes

⚠️ **IMPORTANT** : Ne fermez pas la page pendant la création !

## 🆘 Dépannage

**Erreur persiste après création ?**

- Vérifiez que le statut est **"Enabled"** (pas "Building")
- Faites un **Hot Restart** (R) ou relancez l'app
- Videz le cache du navigateur

**Les index ne se créent pas ?**

- Vérifiez votre quota Firebase (plan gratuit limité)
- Essayez de créer manuellement depuis Console → Firestore → Index

**Je ne vois pas les liens dans la console ?**
Créez manuellement :

1. Firebase Console → Firestore → Index
2. Cliquez sur **"Créer un index composite"**
3. Utilisez les configurations ci-dessus

## 📝 Création Manuelle (Alternative)

Si les liens ne marchent pas, voici les étapes manuelles :

### Index 1 (userId)

1. Console Firebase → Firestore Database → Index
2. Cliquer sur **"Créer un index composite"**
3. Remplir :
   - **Collection ID** : `tasks`
   - **Champs** :
     - `userId` → Ascending
     - `createdAt` → Descending
   - **Query scope** : Collection
4. Créer

### Index 2 (assignedTo)

1. Cliquer à nouveau sur **"Créer un index composite"**
2. Remplir :
   - **Collection ID** : `tasks`
   - **Champs** :
     - `assignedTo` → Array-contains
     - `createdAt` → Descending
   - **Query scope** : Collection
3. Créer

---

✅ **Après ces étapes, votre système de privacy et d'assignation sera pleinement opérationnel !**
