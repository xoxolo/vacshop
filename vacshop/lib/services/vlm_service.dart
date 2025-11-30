import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/scan_result.dart';
import '../config/constants.dart';

/// Service d'inférence VLM pour la détection de prix
/// 
/// IMPORTANT: Ce service est préparé pour recevoir le modèle VLM
/// développé par l'autre équipe. Les méthodes de preprocessing et
/// postprocessing devront être adaptées selon les spécifications
/// exactes du modèle fourni.
class VLMService {
  static VLMService? _instance;
  Interpreter? _interpreter;
  bool _isInitialized = false;
  
  VLMService._();
  
  static VLMService get instance {
    _instance ??= VLMService._();
    return _instance!;
  }
  
  /// Initialiser le modèle VLM
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Charger le modèle TFLite
      _interpreter = await Interpreter.fromAsset(
        AppConstants.vlmModelPath,
        options: InterpreterOptions()
          ..threads = 4 // Utiliser 4 threads pour meilleure performance
          ..useNnApiForAndroid = true // Accélération hardware Android
          ..addDelegate(XNNPackDelegate()), // Optimisation CPU
      );
      
      _isInitialized = true;
      print('✅ VLM Model initialized successfully');
      print('Input shape: ${_interpreter!.getInputTensor(0).shape}');
      print('Output shape: ${_interpreter!.getOutputTensor(0).shape}');
    } catch (e) {
      print('❌ Error initializing VLM model: $e');
      throw Exception('Failed to initialize VLM model: $e');
    }
  }
  
  /// Effectuer l'inférence sur une image
  Future<ScanResult> scanImage(String imagePath) async {
    if (!_isInitialized || _interpreter == null) {
      throw Exception('VLM model not initialized. Call initialize() first.');
    }
    
    try {
      // 1. Préprocesser l'image
      final inputTensor = await _preprocessImage(imagePath);
      
      // 2. Préparer le tensor de sortie
      // NOTE: La forme exacte dépendra du modèle fourni
      // Exemple pour un output [1, num_classes] ou [1, detection_boxes, 5]
      final outputTensor = List.filled(1 * 100, 0.0).reshape([1, 100]);
      
      // 3. Exécuter l'inférence
      final stopwatch = Stopwatch()..start();
      _interpreter!.run(inputTensor, outputTensor);
      stopwatch.stop();
      
      print('⚡ Inference time: ${stopwatch.elapsedMilliseconds}ms');
      
      // 4. Post-traiter les résultats
      final result = _postprocessOutput(outputTensor, imagePath);
      
      return result;
    } catch (e) {
      print('❌ Error during VLM inference: $e');
      throw Exception('VLM inference failed: $e');
    }
  }
  
  /// Préprocesser l'image pour l'inférence
  /// 
  /// ADAPTATIONS NÉCESSAIRES selon le modèle fourni:
  /// - Résolution d'entrée (actuellement 224x224)
  /// - Normalisation (mean/std)
  /// - Format de couleur (RGB/BGR)
  /// - Type de données (float32/uint8)
  Future<List<List<List<List<double>>>>> _preprocessImage(String imagePath) async {
    // Charger l'image
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception('Failed to decode image');
    }
    
    // Redimensionner à la taille attendue par le modèle
    final resized = img.copyResize(
      image,
      width: AppConstants.vlmInputImageWidth,
      height: AppConstants.vlmInputImageHeight,
    );
    
    // Convertir en tensor [1, height, width, 3] normalisé
    final inputTensor = List.generate(
      1,
      (_) => List.generate(
        AppConstants.vlmInputImageHeight,
        (y) => List.generate(
          AppConstants.vlmInputImageWidth,
          (x) {
            final pixel = resized.getPixel(x, y);
            
            // Normalisation standard ImageNet (à adapter selon le modèle)
            // mean = [0.485, 0.456, 0.406], std = [0.229, 0.224, 0.225]
            return [
              (pixel.r / 255.0 - 0.485) / 0.229, // R
              (pixel.g / 255.0 - 0.456) / 0.224, // G
              (pixel.b / 255.0 - 0.406) / 0.225, // B
            ];
          },
        ),
      ),
    );
    
    return inputTensor;
  }
  
  /// Post-traiter la sortie du modèle
  /// 
  /// ADAPTATIONS NÉCESSAIRES selon le format de sortie du modèle:
  /// - Structure des prédictions
  /// - Extraction du montant et de la devise
  /// - Calcul du score de confiance
  ScanResult _postprocessOutput(
    List<dynamic> output,
    String imagePath,
  ) {
    // EXEMPLE DE POST-PROCESSING
    // Cette implémentation devra être adaptée selon le format exact
    // du modèle VLM fourni par l'autre développeur
    
    // Scénario 1: Output direct [amount, confidence, currency_code]
    // Scénario 2: Output avec détections multiples
    // Scénario 3: Output JSON-like structuré
    
    // Pour l'instant, on simule une structure simple
    // Le modèle réel retournera probablement:
    // {
    //   "detections": [
    //     {"amount": 25.75, "currency": "EUR", "confidence": 0.98, "bbox": [x,y,w,h]}
    //   ]
    // }
    
    try {
      // À ADAPTER: Parser la sortie du modèle
      // Exemple simplifié:
      final flatOutput = output[0] as List;
      
      // Extraire les informations (indices à adapter)
      final amount = flatOutput[0] as double;
      final confidence = flatOutput[1] as double;
      final currencyCode = _extractCurrencyCode(flatOutput);
      
      return ScanResult(
        amount: amount,
        currency: currencyCode,
        confidence: confidence,
        imagePath: imagePath,
        rawData: {
          'raw_output': output.toString(),
        },
      );
    } catch (e) {
      print('❌ Error postprocessing VLM output: $e');
      
      // Fallback en cas d'erreur
      return ScanResult(
        amount: 0.0,
        currency: 'UNKNOWN',
        confidence: 0.0,
        imagePath: imagePath,
        rawData: {'error': e.toString()},
      );
    }
  }
  
  /// Extraire le code de devise depuis la sortie
  /// À ADAPTER selon le modèle
  String _extractCurrencyCode(List<dynamic> output) {
    // Le modèle pourrait retourner:
    // - Un index de classe à mapper
    // - Un token à décoder
    // - Directement le code ISO
    
    // Exemple: si le modèle retourne un index de classe
    const currencyMapping = [
      'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY',
      // ... autres devises
    ];
    
    // À adapter selon la sortie réelle
    if (output.length > 2) {
      final currencyIndex = (output[2] as num).toInt();
      if (currencyIndex >= 0 && currencyIndex < currencyMapping.length) {
        return currencyMapping[currencyIndex];
      }
    }
    
    return 'USD'; // Fallback par défaut
  }
  
  /// Vérifier si le modèle est prêt
  bool get isReady => _isInitialized && _interpreter != null;
  
  /// Libérer les ressources
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}

// Extension helper pour reshape
extension ListReshape on List {
  List reshape(List<int> shape) {
    if (shape.length == 2) {
      final result = <List>[];
      final chunkSize = shape[1];
      for (int i = 0; i < length; i += chunkSize) {
        result.add(sublist(i, i + chunkSize));
      }
      return result;
    }
    return this;
  }
}

/// ============================================================
/// QUESTIONS POUR L'INTÉGRATION DU MODÈLE VLM:
/// ============================================================
/// 
/// 1. FORMAT D'ENTRÉE:
///    - Résolution attendue ? (actuellement 224x224)
///    - Normalisation ? (mean/std values)
///    - Format couleur ? (RGB ou BGR)
///    - Type de données ? (float32 ou uint8)
/// 
/// 2. FORMAT DE SORTIE:
///    - Structure exacte du tensor de sortie ?
///    - Comment sont encodés le montant et la devise ?
///    - Format du score de confiance ?
///    - Y a-t-il des détections multiples par image ?
/// 
/// 3. CONFIGURATION:
///    - Quantification utilisée ? (INT8, FP16, FP32)
///    - Taille du modèle ?
///    - Temps d'inférence cible ?
/// 
/// 4. DÉPENDANCES:
///    - Fichiers supplémentaires nécessaires ?
///    - Vocabulaire/labels externes ?
/// 
/// 5. VALIDATION:
///    - Dataset de test fourni ?
///    - Seuil de confiance recommandé ?
/// ============================================================
