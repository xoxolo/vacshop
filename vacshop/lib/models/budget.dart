import 'package:isar/isar.dart';

part 'budget.g.dart';

@collection
class Budget {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String userId;
  
  late String name; // Ex: "Voyage Tokyo 2024"
  String? description;
  
  late double totalAmount; // Montant total du budget
  late String currency; // Devise du budget (CAD, EUR, etc.)
  
  DateTime? startDate;
  DateTime? endDate;
  
  bool isActive;
  
  DateTime? createdAt;
  DateTime? updatedAt;
  
  Budget({
    this.userId = '',
    this.name = '',
    this.description,
    this.totalAmount = 0.0,
    this.currency = 'CAD',
    this.startDate,
    this.endDate,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
  
  /// Calculer le montant utilisé (doit être fait via query des articles)
  double get usedAmount => 0.0; // Sera calculé dynamiquement
  
  /// Calculer le montant restant
  double get remainingAmount => totalAmount - usedAmount;
  
  /// Pourcentage utilisé
  double get usagePercentage => 
      totalAmount > 0 ? (usedAmount / totalAmount * 100) : 0.0;
}
