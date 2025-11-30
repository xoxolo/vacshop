import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String uid; // Firebase UID
  
  late String email;
  String? displayName;
  String? photoUrl;
  
  @Index()
  String? defaultCurrency; // Ex: 'CAD', 'EUR', etc.
  
  DateTime? createdAt;
  DateTime? lastLoginAt;
  
  bool isOnlineMode;
  
  User({
    this.uid = '',
    this.email = '',
    this.displayName,
    this.photoUrl,
    this.defaultCurrency = 'CAD',
    DateTime? createdAt,
    DateTime? lastLoginAt,
    this.isOnlineMode = true,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastLoginAt = lastLoginAt ?? DateTime.now();
}
