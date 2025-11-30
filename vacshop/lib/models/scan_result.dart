/// Résultat d'un scan VLM
class ScanResult {
  final double amount;
  final String currency;
  final double confidence;
  final String? imagePath;
  final DateTime scannedAt;
  
  // Données brutes du modèle (optionnel, pour debug)
  final Map<String, dynamic>? rawData;
  
  ScanResult({
    required this.amount,
    required this.currency,
    required this.confidence,
    this.imagePath,
    DateTime? scannedAt,
    this.rawData,
  }) : scannedAt = scannedAt ?? DateTime.now();
  
  /// Vérifier si le résultat est fiable
  bool get isConfident => confidence >= 0.75;
  
  /// Convertir en Map
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      'confidence': confidence,
      'imagePath': imagePath,
      'scannedAt': scannedAt.toIso8601String(),
      'rawData': rawData,
    };
  }
  
  /// Créer depuis JSON
  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      imagePath: json['imagePath'] as String?,
      scannedAt: DateTime.parse(json['scannedAt'] as String),
      rawData: json['rawData'] as Map<String, dynamic>?,
    );
  }
  
  @override
  String toString() {
    return 'ScanResult(amount: $amount $currency, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}
