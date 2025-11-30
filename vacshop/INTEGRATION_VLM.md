# Guide d'intégration du modèle VLM

## 📍 Localisation du code

Le service VLM est prêt à recevoir votre modèle dans:
- **Fichier:** `lib/services/vlm_service.dart`
- **Modèle TFLite:** `assets/models/vacshop_vlm.tflite`

## ⚠️ Points d'adaptation nécessaires

### 1. Méthode `_preprocessImage()` (Ligne ~85)

Cette méthode prépare l'image pour l'inférence. **À adapter selon votre modèle:**

```dart
Future<List<List<List<List<double>>>>> _preprocessImage(String imagePath)
```

**Questions critiques:**

#### A. Résolution d'entrée
- [ ] Quelle résolution exacte attend votre modèle ?
  - Actuellement configuré: 224x224
  - Format attendu: [hauteur, largeur]
  - Exemple: 320x320, 416x416, 640x640 ?

#### B. Normalisation des pixels
- [ ] Quelle normalisation utilisez-vous ?
  - Actuellement: ImageNet standard
    - mean = [0.485, 0.456, 0.406]
    - std = [0.229, 0.224, 0.225]
  - Alternatives courantes:
    - [0, 1] : diviser par 255.0
    - [-1, 1] : (pixel / 127.5) - 1
    - Autre ?

#### C. Format de couleur
- [ ] RGB ou BGR ?
  - Actuellement: RGB
  - Si BGR, inverser les canaux

#### D. Type de données
- [ ] float32, float16, ou uint8 ?
  - Actuellement: float32
  - Impact sur la taille et la performance

#### E. Ordre des dimensions
- [ ] Format NHWC ou NCHW ?
  - Actuellement: NHWC [1, height, width, channels]
  - TensorFlow: NHWC
  - PyTorch/ONNX: NCHW

**Code à modifier:**
```dart
// Ligne ~100-120 dans vlm_service.dart
final inputTensor = List.generate(
  1,
  (_) => List.generate(
    HEIGHT,  // ← Votre résolution
    (y) => List.generate(
      WIDTH,   // ← Votre résolution
      (x) {
        final pixel = resized.getPixel(x, y);
        return [
          // ← Votre normalisation ici
        ];
      },
    ),
  ),
);
```

---

### 2. Méthode `_postprocessOutput()` (Ligne ~145)

Cette méthode interprète la sortie du modèle. **À adapter selon votre architecture:**

```dart
ScanResult _postprocessOutput(List<dynamic> output, String imagePath)
```

**Questions critiques:**

#### A. Structure de sortie
- [ ] Quel est le format exact de la sortie ?

**Exemples de formats possibles:**

**Format 1: Sortie directe**
```json
{
  "output": [amount, confidence, currency_id]
}
```

**Format 2: Détections multiples**
```json
{
  "detections": [
    {
      "bbox": [x, y, width, height],
      "amount": 25.75,
      "currency": 2,  // Index de devise
      "confidence": 0.98
    }
  ]
}
```

**Format 3: Sortie séparée**
```json
{
  "amount_output": [tensor_values],
  "currency_output": [probabilities],
  "confidence_output": value
}
```

#### B. Extraction du montant
- [ ] Comment est encodé le montant ?
  - Valeur directe (float) ?
  - Classification par plages ?
  - Régression sur digits ?
  - Tokens à décoder ?

#### C. Extraction de la devise
- [ ] Comment est encodée la devise ?
  - Index de classe (0=USD, 1=EUR, etc.) ?
  - Code ISO direct (string) ?
  - Probabilités par devise ?
  - Autre ?

- [ ] Mapping des indices vers les codes ISO:
```dart
const currencyMapping = [
  'USD',  // Index 0
  'EUR',  // Index 1
  'GBP',  // Index 2
  // ... votre mapping complet
];
```

#### D. Score de confiance
- [ ] Format du score de confiance ?
  - Valeur [0, 1] directe ?
  - Softmax de probabilités ?
  - Logits à convertir ?

#### E. Détections multiples
- [ ] Le modèle peut-il détecter plusieurs prix par image ?
  - Si oui, comment sélectionner le bon ?
  - Score de confiance le plus élevé ?
  - Position dans l'image ?
  - Taille du prix ?

**Code à modifier:**
```dart
// Ligne ~160-200 dans vlm_service.dart
ScanResult _postprocessOutput(List<dynamic> output, String imagePath) {
  // ← Votre logique de parsing ici
  
  // Exemple pour format direct:
  final amount = output[0] as double;
  final confidence = output[1] as double;
  final currencyIndex = output[2] as int;
  
  return ScanResult(
    amount: amount,
    currency: currencyMapping[currencyIndex],
    confidence: confidence,
    imagePath: imagePath,
  );
}
```

---

### 3. Configuration du modèle (Ligne ~35-50)

**Questions sur l'optimisation:**

#### A. Quantification
- [ ] Type de quantification utilisé ?
  - INT8 (8-bit integers)
  - FP16 (16-bit floating point)
  - FP32 (32-bit floating point, pas de quantification)
  
  **Impact:**
  - INT8: Très rapide, ~4x plus petit, légère perte de précision
  - FP16: Bon compromis, ~2x plus petit
  - FP32: Précision maximale, plus lent et lourd

#### B. Taille du modèle
- [ ] Taille du fichier .tflite ?
  - Important pour l'app size et le temps de chargement
  - Exemple: 5 MB, 20 MB, 50 MB ?

#### C. Performance cible
- [ ] Temps d'inférence attendu ?
  - Sur quel appareil de référence ?
  - iOS ou Android ?
  - Exemple: < 500ms sur iPhone 12, < 1s sur Android mid-range

#### D. Accélération hardware
- [ ] Votre modèle supporte:
  - [ ] GPU Delegate (Android/iOS)
  - [ ] NNAPI (Android)
  - [ ] Core ML (iOS)
  - [ ] XNNPACK (CPU optimisé)

**Code à configurer:**
```dart
// Ligne ~38-46 dans vlm_service.dart
_interpreter = await Interpreter.fromAsset(
  AppConstants.vlmModelPath,
  options: InterpreterOptions()
    ..threads = 4  // ← Nombre de threads CPU
    ..useNnApiForAndroid = true  // ← Activer NNAPI ?
    ..addDelegate(XNNPackDelegate())  // ← XNNPACK ?
    // ..addDelegate(GpuDelegate())  // ← GPU delegate ?
);
```

---

## 🧪 Fichiers de test requis

Pour valider l'intégration, fournir:

### 1. Modèle TFLite
- [ ] Fichier `vacshop_vlm.tflite` (ou votre nom)
- [ ] Metadata embarquées ?
- [ ] Vocabulaire/labels externes ?

### 2. Images de test
- [ ] Dataset de 10-20 images avec annotations
  ```json
  {
    "image": "test_001.jpg",
    "expected": {
      "amount": 25.75,
      "currency": "EUR",
      "confidence": 0.98
    }
  }
  ```

### 3. Configuration
- [ ] Fichier de config JSON avec:
  - Résolution d'entrée
  - Paramètres de normalisation
  - Mapping des devises
  - Seuil de confiance recommandé

**Exemple de config.json:**
```json
{
  "model": {
    "input_shape": [1, 320, 320, 3],
    "input_type": "float32",
    "normalization": {
      "mean": [0.485, 0.456, 0.406],
      "std": [0.229, 0.224, 0.225]
    }
  },
  "output": {
    "format": "direct",
    "fields": ["amount", "confidence", "currency_id"]
  },
  "currencies": ["USD", "EUR", "GBP", "CAD", ...],
  "confidence_threshold": 0.75
}
```

---

## 📋 Checklist d'intégration

### Phase 1: Réception du modèle
- [ ] Modèle TFLite reçu et placé dans `assets/models/`
- [ ] Images de test fournies
- [ ] Documentation du format d'entrée/sortie

### Phase 2: Adaptation du code
- [ ] `_preprocessImage()` adapté selon spécifications
- [ ] `_postprocessOutput()` adapté selon format de sortie
- [ ] Mapping des devises configuré
- [ ] Configuration d'optimisation ajustée

### Phase 3: Tests
- [ ] Test de chargement du modèle
- [ ] Test d'inférence sur images de référence
- [ ] Validation des résultats vs ground truth
- [ ] Mesure du temps d'inférence
- [ ] Test sur devices réels (iOS + Android)

### Phase 4: Optimisation
- [ ] Profiling des performances
- [ ] Ajustement des paramètres d'accélération
- [ ] Validation du seuil de confiance
- [ ] Tests edge cases (mauvais éclairage, angle, etc.)

---

## 🚀 Commandes pour tester

### Tester le modèle isolément
```dart
// Dans un test unitaire
test('VLM inference test', () async {
  final vlmService = VLMService.instance;
  await vlmService.initialize();
  
  final result = await vlmService.scanImage('test_image.jpg');
  
  expect(result.amount, 25.75);
  expect(result.currency, 'EUR');
  expect(result.confidence, greaterThan(0.75));
});
```

### Mesurer les performances
```dart
final stopwatch = Stopwatch()..start();
final result = await vlmService.scanImage(imagePath);
stopwatch.stop();

print('Inference time: ${stopwatch.elapsedMilliseconds}ms');
print('Result: ${result.toString()}');
```

---

## 📞 Contact pour questions

**Développeur App:** Olivier Bertsrand
**Développeur VLM:** [À compléter]

**Questions urgentes à clarifier avant de continuer:**
1. Format exact d'entrée du modèle
2. Format exact de sortie du modèle
3. Mapping des devises (indices → codes ISO)
4. Dataset de test avec ground truth

---

## 📝 Notes additionnelles

### Fichiers modifiés lors de l'intégration:
- `lib/services/vlm_service.dart` (principal)
- `lib/config/constants.dart` (paramètres VLM)
- `assets/models/vacshop_vlm.tflite` (le modèle)
- Possiblement: fichiers de vocabulaire/labels

### Performance cible:
- **Inference:** < 1.5s sur device mid-range
- **Precision:** > 90% sur dataset de test
- **Confiance:** Seuil recommandé 0.75

### Fallbacks en cas d'erreur:
- Modèle non chargé: Mode dégradé (saisie manuelle)
- Confiance faible: Demander confirmation utilisateur
- Devise non reconnue: Proposer sélection manuelle
