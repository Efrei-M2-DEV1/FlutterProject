# 📱 FlutterProject

Projet Flutter — base avec navigation (`go_router`) et arborescence organisée.

---

## 🚀 Installation

### ✅ Prérequis
- [ ] Installer **Flutter** (version stable 3.35.x minimum) → `flutter --version`
- [ ] Installer un IDE (**VS Code** avec extensions Flutter/Dart, ou Android Studio)
- [ ] Éviter les chemins synchronisés (**OneDrive / iCloud**) → placez le projet dans `C:\Dev\flutterproject` ou `~/Dev/flutterproject`

---

### ✅ Cloner le projet
```bash
git clone https://github.com/Efrei-M2-DEV1/FlutterProject.git
cd flutterproject
flutter pub get
flutter doctor
```

---

### ✅ Lancer l’application

#### Option 1 : Web server (recommandée, fiable)
```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8081
```
➡️ Ouvrez ensuite l’URL affichée (ex: `http://127.0.0.1:8081`) dans **Chrome** ou **Edge**.

#### Option 2 : Chrome / Edge (si ça marche chez vous)
```bash
flutter run -d chrome
```

⚠️ Si le navigateur ne se lance pas correctement :
- Fermez tous les Chrome/Edge
- Nettoyez les profils debug :
  ```powershell
  taskkill /IM chrome.exe /F; taskkill /IM msedge.exe /F
  Remove-Item -Recurse -Force "$env:TEMP\flutter_tools*" -ErrorAction SilentlyContinue
  ```
- Relancez `flutter run -d chrome`  
Sinon restez en **web-server**.

---

### ✅ Windows spécifique
- [ ] Activer **Mode développeur** dans Windows (sinon erreurs de symlinks)
- [ ] Pour le build Windows Desktop : installer **Visual Studio** avec workload *Desktop development with C++*

---

### ✅ Android (optionnel, si vous testez sur mobile)
1. Installer Android Studio
2. Dans **SDK Manager → SDK Tools** cocher :
   - Android **SDK Command-line Tools (latest)**
   - **Platform-Tools**
   - **Build-Tools**
3. Exécuter :
   ```bash
   flutter doctor --android-licenses
   flutter doctor
   ```

---

## � Configuration Firebase

### ✅ Prérequis Firebase
1. Créer un projet sur [Firebase Console](https://console.firebase.google.com/)
2. Installer **Firebase CLI** :
   ```bash
   npm install -g firebase-tools
   firebase login
   ```
3. Installer **FlutterFire CLI** :
   ```bash
   dart pub global activate flutterfire_cli
   ```

### ✅ Configuration du projet Firebase

#### 1️⃣ Initialiser Firebase dans le projet
```bash
cd /chemin/vers/FlutterProject
flutterfire configure
```

Sélectionnez :
- Votre projet Firebase existant
- Les plateformes : **Web**, **Android**, **iOS** (selon vos besoins)

Cette commande crée automatiquement :
- `lib/firebase_options.dart` (configuration Firebase)
- `android/app/google-services.json` (Android)
- `ios/Runner/GoogleService-Info.plist` (iOS)

#### 2️⃣ Activer Firestore Database
Dans la **Firebase Console** :
1. Aller dans **Firestore Database**
2. Cliquer sur **Créer une base de données**
3. Choisir le mode :
   - **Mode test** (pour le développement) - les règles seront ouvertes temporairement
   - **Mode production** - sécurisé par défaut

#### 3️⃣ Règles de sécurité Firestore (recommandées)

Pour le développement, règles basiques dans **Firestore → Règles** :
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Collection des tâches - accès public pour le développement
    match /tasks/{taskId} {
      allow read, write: if true;
    }
  }
}
```

⚠️ **Pour la production**, sécuriser avec l'authentification :
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Tâches accessibles uniquement aux utilisateurs authentifiés
    match /tasks/{taskId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### 4️⃣ Vérifier l'installation
```bash
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8081
```

Vérifiez dans la console :
```
✅ Firebase initialisé avec succès
```

### ✅ Structure Firebase dans le projet

```
lib/
  firebase_options.dart         # Configuration Firebase (auto-générée)
  features/
    tasks/
      data/
        firestore_task_service.dart   # Service Firestore
        task_repository.dart          # Repository (abstraction)
      domain/
        models/
          task.dart                    # Modèle de tâche
      presentation/
        providers/
          task_provider.dart           # Provider avec écoute temps réel
```

### ✅ Fonctionnalités Firebase implémentées

- ✅ **Firestore** : Base de données temps réel pour les tâches
- ✅ **Écoute en temps réel** : Les modifications sont synchronisées automatiquement
- ✅ **CRUD complet** : Créer, Lire, Mettre à jour, Supprimer des tâches
- ✅ **Statistiques** : Calcul automatique des stats (total, complétées, en attente)
- 🔜 **Authentication** : À venir (Firebase Auth)

---

## �📂 Structure du projet

```
lib/
  app.dart                # Point d'entrée principal de l'app (MaterialApp, Provider, etc.)
  main.dart               # Bootstrap Flutter (runApp)
  router/                 # Configuration et gestion des routes (go_router)
  common/                 # Thème, widgets réutilisables, helpers, extensions
  features/               # Modules fonctionnels (découpage par domaine)
    splash/               # Écran d'accueil (SplashScreen)
    auth/                 # Authentification (login, inscription, gestion utilisateur)
    tasks/                # Gestion des tâches (listes, CRUD, etc.)
    ...                   # Ajouter vos autres features ici
  models/                 # Modèles de données (ex: Task, User)
  providers/              # Gestion d'état (ex: TaskProvider, AuthProvider)
  services/               # Accès aux API, Firebase, stockage local, etc.
  utils/                  # Fonctions utilitaires, constantes, validations
test/
  example_test.dart       # Exemple de test unitaire
  ...                     # Vos autres tests
assets/
  images/                 # Images statiques
  fonts/                  # Polices personnalisées
  ...
```

- **Navigation** : `go_router` centralisé dans `router/`
- **Gestion d’état** : `Provider` dans `providers/`
- **Découpage par feature** : chaque domaine fonctionnel dans son dossier
- **Séparation claire** : modèles, services, utilitaires, assets

➡️ Cette organisation facilite la scalabilité, la maintenance et la collaboration.

---

## 🔧 Commandes utiles
- [ ] `flutter clean` → nettoyer le projet
- [ ] `flutter pub get` → installer les dépendances
- [ ] `flutter analyze` → vérifier le code (lint)
- [ ] `flutter test` → lancer les tests (à venir)
- [ ] `flutterfire configure` → reconfigurer Firebase

---

## 🎯 Démarrage rapide pour les développeurs

### Premier lancement (configuration initiale)
```bash
# 1. Cloner et installer
git clone https://github.com/Efrei-M2-DEV1/FlutterProject.git
cd FlutterProject
flutter pub get

# 2. Configurer Firebase (si pas déjà fait)
flutterfire configure

# 3. Lancer l'app
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8081
```

### Développement quotidien
```bash
# Lancer en mode web serveur
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8081

# Puis ouvrir : http://127.0.0.1:8081
```

### Données de test
L'application peut charger des données de test dans Firestore pour faciliter le développement.
Ces données incluent plusieurs tâches avec différentes priorités et statuts.

---

## 🌱 Git Workflow
- [ ] Créer vos branches à partir de `dev` → `feat/<nom-feature>`
- [ ] PR vers `dev` → review obligatoire
- [ ] `staging` = intégration stable
- [ ] `main` = version finale

---

✅ Vous pouvez maintenant lancer l’app et commencer à coder vos features.
