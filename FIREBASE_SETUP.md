# 🔥 Configuration Firebase - Guide étape par étape

## 📧 Compte Firebase
Email : eric.amour2022@gmail.com

---

## 🚀 Étapes de configuration

### 1️⃣ Créer/Accéder au projet Firebase

1. Aller sur [Firebase Console](https://console.firebase.google.com/)
2. Se connecter avec : **eric.amour2022@gmail.com**
3. Cliquer sur **"Ajouter un projet"** ou sélectionner un projet existant
4. Nom du projet suggéré : **flutter-todolist-app** (ou votre choix)

---

### 2️⃣ Configurer la plateforme Web

1. Dans la console Firebase, cliquer sur **⚙️ Paramètres du projet**
2. Descendre jusqu'à **"Vos applications"**
3. Cliquer sur l'icône **</> Web**
4. Enregistrer l'app :
   - Nom : **FlutterProject Web**
   - ✅ Cocher : "Configurer également Firebase Hosting"
5. Copier les valeurs affichées :

```javascript
const firebaseConfig = {
  apiKey: "VOTRE_API_KEY",
  authDomain: "VOTRE_PROJECT_ID.firebaseapp.com",
  projectId: "VOTRE_PROJECT_ID",
  storageBucket: "VOTRE_PROJECT_ID.appspot.com",
  messagingSenderId: "VOTRE_SENDER_ID",
  appId: "VOTRE_APP_ID"
};
```

---

### 3️⃣ Activer Firestore Database

1. Dans le menu latéral, cliquer sur **"Firestore Database"**
2. Cliquer sur **"Créer une base de données"**
3. Choisir le mode : **Mode test** (pour le développement)
4. Sélectionner la région : **europe-west1** (Belgique) ou **us-central1**
5. Cliquer sur **"Activer"**

---

### 4️⃣ Configurer les règles Firestore

Dans **Firestore Database → Règles**, remplacer par :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Collection des tâches - accès public en mode développement
    match /tasks/{taskId} {
      allow read, write: if true;
    }
  }
}
```

⚠️ **Important** : Ces règles sont ouvertes pour le développement. 
En production, sécuriser avec l'authentification.

Cliquer sur **"Publier"**.

---

### 5️⃣ Mettre à jour firebase_options.dart

Remplacer les valeurs dans `lib/firebase_options.dart` :

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'VOTRE_API_KEY',
  appId: 'VOTRE_APP_ID',
  messagingSenderId: 'VOTRE_SENDER_ID',
  projectId: 'VOTRE_PROJECT_ID',
  authDomain: 'VOTRE_PROJECT_ID.firebaseapp.com',
  storageBucket: 'VOTRE_PROJECT_ID.appspot.com',
);
```

---

### 6️⃣ Tester l'application

```bash
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8081
```

Vérifier dans la console :
```
✅ Firebase initialisé avec succès
```

---

### 7️⃣ Vérifier Firestore

1. Retourner dans Firebase Console → Firestore Database
2. Vous devriez voir une collection **"tasks"** se créer automatiquement
3. Les tâches créées dans l'app apparaîtront ici en temps réel

---

## 📝 Commandes utiles

```bash
# Reconfigurer Firebase automatiquement (si FlutterFire CLI configuré)
flutterfire configure

# Voir les logs Firebase
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8081 -v

# Nettoyer et relancer
flutter clean
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8081
```

---

## 🆘 Aide

Si vous rencontrez des problèmes :
1. Vérifier que toutes les clés sont correctement copiées
2. Vérifier que Firestore est activé
3. Vérifier les règles de sécurité Firestore
4. Regarder la console du navigateur (F12) pour les erreurs

---

✅ Une fois configuré, l'application sera connectée à Firebase et les tâches seront synchronisées en temps réel !
