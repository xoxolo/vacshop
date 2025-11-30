import 'package:isar/isar.dart';

part 'exchange_rate.g.dart';

@collection
class ExchangeRate {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true, composite: [CompositeIndex('toCurrency')])
  late String fromCurrency; // Ex: 'CAD'
  
  late String toCurrency; // Ex: 'EUR'
  
  late double rate; // Taux de change
  
  DateTime? lastUpdated;
  
  ExchangeRate({
    this.fromCurrency = '',
    this.toCurrency = '',
    this.rate = 1.0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();
  
  /// Vérifier si le taux est obsolète (> 24h)
  bool get isStale {
    if (lastUpdated == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastUpdated!);
    return difference.inHours > 24;
  }
}

/// Modèle pour stocker les informations de devise
@collection
class Currency {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String code; // ISO 4217 code (CAD, EUR, USD, etc.)
  
  late String name; // Nom complet (Canadian Dollar, Euro, etc.)
  String? symbol; // Symbole ($, €, £, etc.)
  String? flag; // Emoji du drapeau ou path vers l'icône
  
  bool isPopular; // Pour afficher en priorité
  bool isEnabled; // Activé par l'utilisateur
  
  Currency({
    this.code = '',
    this.name = '',
    this.symbol,
    this.flag,
    this.isPopular = false,
    this.isEnabled = true,
  });
}
