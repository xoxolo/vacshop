import 'package:isar/isar.dart';

part 'article.g.dart';

@collection
class Article {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String userId;
  
  @Index()
  int? budgetId; // Lien vers le budget (nullable si pas encore assigné)
  
  // Données du scan VLM
  late double amount; // Montant détecté
  late String detectedCurrency; // Devise détectée par le VLM
  late double confidence; // Confiance du modèle (0.0 - 1.0)
  
  // Données de conversion
  double? convertedAmount; // Montant converti dans la devise du budget
  String? targetCurrency; // Devise cible de conversion
  double? exchangeRate; // Taux de change utilisé
  
  // Informations ajoutées par l'utilisateur
  String? name; // Nom de l'article (ex: "Pizza carbonara")
  String? category; // Restaurant, Transport, etc.
  int quantity; // Quantité
  String? notes; // Notes additionnelles
  
  // Métadonnées
  String? imagePath; // Chemin local de l'image scannée
  @Index()
  DateTime? scannedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  
  // Localisation (optionnel)
  String? location;
  double? latitude;
  double? longitude;
  
  Article({
    this.userId = '',
    this.budgetId,
    this.amount = 0.0,
    this.detectedCurrency = '',
    this.confidence = 0.0,
    this.convertedAmount,
    this.targetCurrency,
    this.exchangeRate,
    this.name,
    this.category,
    this.quantity = 1,
    this.notes,
    this.imagePath,
    DateTime? scannedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.location,
    this.latitude,
    this.longitude,
  })  : scannedAt = scannedAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
  
  /// Montant total (montant × quantité)
  double get totalAmount => amount * quantity;
  
  /// Montant total converti
  double get totalConvertedAmount => 
      (convertedAmount ?? amount) * quantity;
}
