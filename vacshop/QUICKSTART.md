# 🚀 Quick Start - VacShop

## Installation rapide (5 minutes)

### 1. Prérequis
```bash
# Vérifier Flutter
flutter doctor

# Si Flutter n'est pas installé:
# Télécharger depuis https://flutter.dev
```

### 2. Installation
```bash
cd vacshop
flutter pub get
```

### 3. Générer les fichiers Isar
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Lancer l'app
```bash
# Sur émulateur/simulateur
flutter run

# Sur device physique
flutter run -d <device-id>
```

---

## ⚠️ Si erreurs à la compilation

### Erreur: "Isar schemas not found"
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Erreur: "Firebase not configured"
**L'app peut tourner sans Firebase pour le développement.**

Pour activer Firebase (optionnel):
1. Créer projet sur https://console.firebase.google.com
2. Télécharger `google-services.json` (Android)
3. Télécharger `GoogleService-Info.plist` (iOS)
4. Placer dans les dossiers appropriés

### Erreur: "TFLite model not found"
**Normal - le modèle VLM n'est pas encore fourni.**

L'app fonctionne sans le modèle, le scan sera en mode mock.

---

## 📱 Tester l'app sans setup complet

### Mode développement rapide
L'app peut être testée **immédiatement** avec:
- ✅ UI complète fonctionnelle
- ✅ Navigation entre écrans
- ✅ Animations et design
- ⚠️ Auth désactivée (bypass possible)
- ⚠️ VLM en mode mock

### Bypass auth temporaire
Pour tester sans Firebase, modifier `main.dart`:
```dart
// Commenter ces lignes:
await Firebase.initializeApp();
```

Et dans `splash_screen.dart`:
```dart
// Forcer navigation vers home:
Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
```

---

## 📂 Structure du projet

```
vacshop/
├── lib/
│   ├── main.dart              # Point d'entrée
│   ├── config/                # Configuration
│   ├── models/                # Modèles de données
│   ├── services/              # Logique métier
│   ├── screens/               # Écrans UI
│   └── widgets/               # Composants
├── assets/                    # Ressources
├── pubspec.yaml               # Dépendances
├── README.md                  # Documentation complète
├── INTEGRATION_VLM.md         # Guide VLM
└── DELIVERABLE.md             # Statut du projet
```

---

## 🎯 Écrans disponibles

1. **Splash** - Animation de démarrage
2. **Onboarding** - 3 slides d'introduction
3. **Login** - Connexion email + OAuth
4. **Signup** - Inscription
5. **Home** - Navigation principale
6. **Dashboard** - Stats et budget
7. **Scan** - Caméra avec overlay
8. **Settings** - Paramètres

**Navigation:** Bottom bar dans HomeScreen

---

## 🔧 Commandes utiles

### Développement
```bash
# Hot reload (Ctrl+S ou Cmd+S)
# Hot restart (Shift+Cmd+R)

# Analyser le code
flutter analyze

# Formatter
dart format lib/

# Clean & rebuild
flutter clean && flutter pub get
```

### Build
```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web (si nécessaire)
flutter build web
```

---

## 📝 Notes importantes

### Assets manquants
- Polices Inter (télécharger de Google Fonts)
- Icônes SVG OAuth (optionnel)
- Logo VacShop (créer ou utiliser icône Material)

### Firebase (optionnel pour développement)
- Authentification fonctionne sans Firebase en mode offline
- Créer projet Firebase seulement pour production

### Modèle VLM
- L'app fonctionne sans le modèle
- Le scan retournera des valeurs mock
- Voir `INTEGRATION_VLM.md` pour intégration

---

## 🐛 Debugging

### Afficher les logs
```bash
flutter logs

# Ou dans VS Code:
# Debug Console automatiquement
```

### Inspecter la base de données
```bash
# Les fichiers Isar sont dans:
# Android: /data/data/com.vacshop/files/
# iOS: Library/Application Support/

# Utiliser Isar Inspector (à venir)
```

---

## ✅ Checklist premier lancement

- [ ] `flutter pub get` exécuté
- [ ] `build_runner` exécuté (pour Isar)
- [ ] Émulateur/device connecté
- [ ] `flutter run` sans erreurs

**Si tout est ✅ → L'app devrait s'ouvrir !**

---

## 📚 Documentation complète

- **README.md** - Architecture et fonctionnalités
- **INTEGRATION_VLM.md** - Guide intégration modèle
- **DELIVERABLE.md** - État du projet et roadmap

---

## 🎓 Apprendre Flutter

### Ressources
- [Flutter Documentation](https://docs.flutter.dev)
- [Riverpod Documentation](https://riverpod.dev)
- [Isar Documentation](https://isar.dev)

### Structure du code
Le code suit les best practices Flutter:
- Widgets StatefulWidget/StatelessWidget
- Services singleton pour logique métier
- Riverpod pour state management
- Async/await pour asynchrone

---

## 💡 Conseils

### Développement efficace
1. Utiliser hot reload (rapide)
2. Commenter Firebase temporairement
3. Tester sur émulateur d'abord
4. Utiliser Flutter DevTools

### Problèmes fréquents
- **Gradle sync failed** → Relancer Android Studio
- **Pods install failed** → `cd ios && pod install`
- **Widget not updating** → Vérifier setState()

---

## 🚀 Prêt à coder !

```bash
cd vacshop
flutter pub get
flutter pub run build_runner build
flutter run
```

**L'app devrait démarrer en ~30 secondes 🎉**

---

**Questions ?**
- Voir README.md pour détails complets
- Voir INTEGRATION_VLM.md pour le modèle
- Voir DELIVERABLE.md pour roadmap
