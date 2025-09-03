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
git clone <URL_DU_REPO>
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

## 📂 Structure du projet

```
lib/
  app.dart
  main.dart
  router/
  common/        # thème, widgets communs
  features/
    splash/      # écran Splash
    auth/        # login/inscription (à implémenter)
    tasks/       # liste de tâches
```

- Navigation : **go_router**
- UI de base : Splash → Auth → Tasks
- Gestion d’état : **Provider** (sera branché sur `TaskProvider`)

---

## 🔧 Commandes utiles
- [ ] `flutter clean` → nettoyer le projet
- [ ] `flutter pub get` → installer les dépendances
- [ ] `flutter analyze` → vérifier le code (lint)
- [ ] `flutter test` → lancer les tests (à venir)

---

## 🌱 Git Workflow
- [ ] Créer vos branches à partir de `dev` → `feat/<nom-feature>`
- [ ] PR vers `dev` → review obligatoire
- [ ] `staging` = intégration stable
- [ ] `main` = version finale

---

✅ Vous pouvez maintenant lancer l’app et commencer à coder vos features.
