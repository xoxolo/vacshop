# VacShop - Application Mobile Flutter

## 📱 Vue d'ensemble

VacShop est une application mobile innovante utilisant la technologie VLM (Vision Language Model) pour scanner et convertir automatiquement les prix en différentes devises, permettant aux voyageurs de gérer leur budget en temps réel, 100% hors ligne.

**Tagline:** Voyagez malin, budgétez simple

## 🏗️ Architecture

### Stack Technique
- **Framework:** Flutter 3.2+
- **Gestion d'état:** Riverpod
- **Base de données:** Isar (NoSQL locale)
- **ML/AI:** TFLite Flutter (VLM on-device)
- **Authentification:** Firebase Auth (Google, Facebook, Email/Password)
- **Stockage sécurisé:** flutter_secure_storage

### Structure du projet

```
vacshop/
├── lib/
│   ├── main.dart                    # Point d'entrée
│   ├── config/
│   │   ├── theme.dart               # Thème et couleurs
│   │   └── constants.dart           # Constantes app
│   ├── models/                      # Modèles Isar
│   │   ├── user.dart
│   │   ├── budget.dart
│   │   ├── article.dart
│   │   ├── exchange_rate.dart
│   │   └── scan_result.dart
│   ├── services/                    # Services métier
│   │   ├── database_service.dart    # CRUD Isar
│   │   ├── auth_service.dart        # Authentification
│   │   ├── vlm_service.dart         # Inférence VLM ⚠️
│   │   └── currency_service.dart    # Conversion devises
│   ├── providers/                   # Riverpod providers
│   ├── screens/                     # Écrans UI
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   ├── home/
│   │   ├── scan/
│   │   └── dashboard/
│   └── widgets/                     # Composants réutilisables
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       └── social_auth_button.dart
├── assets/
│   ├── images/
│   ├── icons/
│   ├── models/
│   │   └── vacshop_vlm.tflite     # Modèle VLM ⚠️
│   ├── data/
│   │   └── exchange_rates.json     # Taux initiaux
│   └── fonts/
│       └── Inter/                   # Police Inter
└── pubspec.yaml
```

## ✅ Fonctionnalités implémentées

### 1. Architecture & Configuration ✓
- ✓ Structure projet Flutter optimisée
- ✓ Configuration Riverpod + Isar
- ✓ Thème complet (couleurs, typographie, composants)
- ✓ Constantes et configuration centralisée

### 2. Authentification ✓
- ✓ Service Firebase Auth complet
- ✓ Login/Signup Email/Password
- ✓ OAuth Google & Facebook
- ✓ Connexion offline avec credentials cachés
- ✓ Stockage sécurisé (flutter_secure_storage)

### 3. Base de données Isar ✓
- ✓ Modèles: User, Budget, Article, ExchangeRate, Currency
- ✓ Service database avec CRUD complet
- ✓ Queries optimisées
- ✓ Relations et statistiques

### 4. Conversion de devises ✓
- ✓ Service offline avec 20+ devises
- ✓ Taux de change stockés localement
- ✓ Mise à jour online (optionnelle)
- ✓ Conversion multi-devises avec pivot USD

### 5. Service VLM ⚠️ (Prêt pour intégration)
- ✓ Architecture TFLite complète
- ✓ Preprocessing d'images
- ⚠️ Post-processing à adapter selon modèle fourni
- ⚠️ Format d'entrée/sortie à confirmer

### 6. UI/UX ✓ (Partiel)
- ✓ Splash screen avec animation
- ✓ Login screen complet
- ✓ Widgets réutilisables (Button, TextField, etc.)
- ⏳ Signup, Onboarding, Home, Dashboard, Scan (à compléter)

## 🎨 Design System

### Couleurs
- **Primary:** #4A90E2 (Bleu)
- **Secondary:** #2DD4BF (Vert turquoise)
- **Accent:** #8B5CF6 (Violet)
- **Success:** #10B981
- **Warning:** #F59E0B
- **Error:** #EF4444

### Typographie
- **Police:** Inter (Regular, Medium, SemiBold, Bold)
- **Tailles:** H1 (32px) → Caption (12px)

## 🔧 Installation & Setup

### Prérequis
```bash
flutter --version  # Flutter 3.2.0 ou supérieur
dart --version     # Dart 3.0.0 ou supérieur
```

### Installation des dépendances
```bash
cd vacshop
flutter pub get
```

### Générer les fichiers Isar
```bash
flutter pub run build_runner build
```

### Configuration Firebase
1. Créer un projet Firebase
2. Télécharger `google-services.json` (Android) et `GoogleService-Info.plist` (iOS)
3. Placer dans les dossiers appropriés

### Lancer l'app
```bash
flutter run
```

## ⚠️ INTÉGRATION VLM - QUESTIONS CRITIQUES

Le service VLM est prêt mais nécessite des informations du modèle développé par l'autre équipe :

### 1. Format d'entrée
- [ ] Résolution exacte ? (actuellement 224x224)
- [ ] Normalisation (mean/std) ?
- [ ] Format de couleur (RGB/BGR) ?
- [ ] Type de données (float32/uint8) ?

### 2. Format de sortie
- [ ] Structure du tensor de sortie ?
- [ ] Comment sont encodés montant et devise ?
- [ ] Format du score de confiance ?
- [ ] Détections multiples par image ?

### 3. Configuration
- [ ] Quantification (INT8/FP16/FP32) ?
- [ ] Taille du modèle ?
- [ ] Temps d'inférence cible ?

### 4. Fichiers nécessaires
- [ ] Modèle TFLite (vacshop_vlm.tflite)
- [ ] Fichiers annexes (vocabulaire, labels) ?
- [ ] Dataset de test pour validation ?

**📍 Localisation du code à adapter :**
`lib/services/vlm_service.dart` - Voir commentaires `// À ADAPTER`

## 📋 Prochaines étapes de développement

### Phase 1: Compléter les écrans principaux (2-3 jours)
```
[ ] Onboarding screen (3 slides)
[ ] Signup screen
[ ] Home screen (landing + navigation)
[ ] Scan screen (camera + viewfinder)
[ ] Scan result screen
[ ] Article details screen (formulaire)
[ ] Dashboard screen (stats + budgets)
```

### Phase 2: Intégration VLM (1-2 jours)
```
[ ] Recevoir et tester le modèle VLM
[ ] Adapter preprocessing/postprocessing
[ ] Tests d'inférence
[ ] Optimisation performance
```

### Phase 3: Gestion des budgets (2-3 jours)
```
[ ] Providers Riverpod pour budgets
[ ] CRUD budgets (créer, modifier, supprimer)
[ ] Calculs montants utilisés/restants
[ ] Graphiques progression
```

### Phase 4: Historique & Statistiques (1-2 jours)
```
[ ] Écran historique avec filtres
[ ] Statistiques détaillées
[ ] Export données (optionnel)
```

### Phase 5: Paramètres & Profil (1 jour)
```
[ ] Écran profil utilisateur
[ ] Paramètres app (devises, notifications)
[ ] Gestion compte
```

### Phase 6: Polish & Tests (2-3 jours)
```
[ ] Tests unitaires services
[ ] Tests widgets
[ ] Corrections bugs
[ ] Optimisations performance
[ ] Animations et transitions
```

## 🚀 Commandes utiles

```bash
# Générer les fichiers
flutter pub run build_runner build --delete-conflicting-outputs

# Analyser le code
flutter analyze

# Formatter le code
dart format lib/

# Tests
flutter test

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## 📊 Métriques de performance cibles

- **Temps de lancement:** < 2s
- **Inférence VLM:** < 1.5s
- **Taille app:** < 50 MB (avec modèle VLM)
- **Consommation RAM:** < 200 MB
- **Taille base de données:** < 10 MB (1000 scans)

## 🔐 Sécurité

- Credentials stockés avec flutter_secure_storage (AES-256)
- Communications Firebase chiffrées (SSL/TLS)
- Base de données Isar locale (non accessible hors app)
- Pas de données sensibles en clair

## 📄 Documentation additionnelle

### Modèles de données

**User**
- uid, email, displayName, defaultCurrency
- Gestion online/offline

**Budget**
- name, totalAmount, currency, startDate, endDate
- Calcul montants utilisés via articles

**Article**
- amount, detectedCurrency, confidence
- convertedAmount, category, quantity
- Lien vers budget

**ExchangeRate**
- fromCurrency, toCurrency, rate
- Mise à jour périodique

## 🎯 Différenciation brevetable

**Aspects techniques uniques :**
1. Architecture VLM embarquée offline (vs OCR cloud)
2. Compression et quantification du modèle pour mobile
3. Système de cache intelligent des taux de change
4. Pipeline de preprocessing optimisé pour détection prix multi-devises
5. Gestion contextuelle (photos → extraction structurée)

## 📞 Support & Contact

**Développeur principal:** Olivier Bertsrand  
**Entreprise:** Da Vinci Nova Corp  
**Financement:** CNRC

---

**Status projet:** 🟡 En développement actif  
**Version:** 1.0.0 (MVP)  
**Dernière mise à jour:** Novembre 2024
