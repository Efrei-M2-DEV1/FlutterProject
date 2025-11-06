# Configuration de la Sécurité Firestore

## ⚠️ IMPORTANT - Déploiement des Règles de Sécurité

Pour que votre application fonctionne correctement avec le système de privacy et d'assignation, vous **DEVEZ** mettre à jour les règles de sécurité Firestore dans la console Firebase.

### Étapes à Suivre

1. **Ouvrir la Console Firebase**

   - Allez sur [console.firebase.google.com](https://console.firebase.google.com)
   - Sélectionnez votre projet

2. **Accéder aux Règles Firestore**

   - Dans le menu de gauche, cliquez sur **Firestore Database**
   - Cliquez sur l'onglet **Règles** (Rules)

3. **Copier les Nouvelles Règles**

   - Copiez **INTÉGRALEMENT** le contenu du fichier `firestore.rules` (situé à la racine du projet)
   - Collez-le dans l'éditeur de règles de la console Firebase

4. **Publier les Règles**
   - Cliquez sur **Publier** (Publish)
   - Attendez la confirmation de déploiement

### 🔒 Ce que Font les Nouvelles Règles

#### Collection `users`

- ✅ Lecture : Un utilisateur peut lire uniquement son propre document
- ✅ Création : Un utilisateur peut créer uniquement son propre document
- ✅ Mise à jour : Un utilisateur peut modifier uniquement son propre document
- ❌ Suppression : Interdite pour tous

#### Collection `tasks`

- ✅ **Lecture** : Autorisée si :
  - L'utilisateur est le créateur de la tâche (userId)
  - OU l'utilisateur est dans la liste `assignedTo`
- ✅ **Création** : Autorisée si :
  - L'utilisateur est authentifié
  - Le `userId` de la tâche correspond à l'utilisateur qui la crée
- ✅ **Mise à jour** : Autorisée si :
  - L'utilisateur est le créateur (userId)
  - Les champs `userId` et `ownerName` ne sont pas modifiés
- ✅ **Suppression** : Autorisée si :
  - L'utilisateur est le créateur (userId)

### 🚀 Nouvelles Fonctionnalités Disponibles

1. **Privacy par Défaut**
   - Les tâches sont privées par défaut
   - Seul le créateur peut les voir et les gérer
2. **Assignation d'Utilisateurs**

   - Le créateur peut assigner d'autres utilisateurs à ses tâches
   - Les utilisateurs assignés peuvent voir la tâche
   - Pour assigner : Cliquez sur "Modifier" une tâche → "Assigner des utilisateurs"

3. **Sécurité Renforcée**
   - Impossible de modifier l'owner d'une tâche
   - Impossible de supprimer une tâche d'un autre utilisateur
   - Filtrage automatique des tâches côté serveur

### 🧪 Tester la Sécurité

Pour vérifier que tout fonctionne :

1. **Créer deux comptes utilisateurs différents**

   - Créez un compte A
   - Créez une tâche avec le compte A
   - Déconnectez-vous

2. **Se connecter avec le compte B**

   - Vous ne devriez PAS voir les tâches du compte A
   - Créez une tâche avec le compte B

3. **Retourner au compte A**

   - Modifiez la tâche créée par A
   - Cliquez sur "Assigner des utilisateurs"
   - Cochez le compte B

4. **Vérifier avec le compte B**
   - La tâche du compte A devrait maintenant être visible
   - Mais vous ne pouvez pas la supprimer (seulement la voir/modifier)

### ⚡ Création d'Index Composites

Si vous voyez une erreur comme :

```
The query requires an index. You can create it here: [URL]
```

1. Cliquez sur l'URL fournie dans l'erreur
2. Firebase créera automatiquement l'index nécessaire
3. Attendez quelques minutes (création d'index)
4. Rechargez l'application

### 🔄 Migration des Données Existantes

Si vous avez déjà des tâches dans Firestore créées avant ce changement :

1. Elles auront peut-être un champ `assignedTo` vide ou inexistant
2. Les nouvelles règles nécessitent que ce champ existe
3. Options :
   - **Option 1** : Supprimer toutes les anciennes tâches
   - **Option 2** : Ajouter manuellement le champ `assignedTo: []` à chaque document existant dans la console Firebase

### 📝 Structure des Documents

#### Document User

```javascript
{
  email: "user@example.com",
  name: "John Doe",
  createdAt: Timestamp
}
```

#### Document Task

```javascript
{
  userId: "uid_du_createur",
  ownerName: "John Doe",
  assignedTo: ["uid_utilisateur_1", "uid_utilisateur_2"],
  title: "Titre de la tâche",
  description: "Description",
  priority: "medium", // "low", "medium", "high"
  tags: [],
  createdAt: Timestamp,
  dueDate: Timestamp | null,
  isCompleted: false
}
```

### 🆘 Dépannage

**Erreur : "Missing or insufficient permissions"**

- Vérifiez que vous avez bien publié les nouvelles règles
- Vérifiez que vous êtes connecté
- Vérifiez que le champ `assignedTo` existe dans vos documents

**Les tâches ne s'affichent pas**

- Vérifiez que le filtre de requête fonctionne (regardez la console développeur)
- Créez de nouvelles tâches après avoir déployé les règles
- Vérifiez qu'un index composite n'est pas nécessaire

**Impossible d'assigner des utilisateurs**

- Vérifiez que d'autres utilisateurs existent dans la collection `users`
- L'utilisateur courant est automatiquement exclu de la liste
