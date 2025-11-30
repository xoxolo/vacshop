import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/budget.dart';
import '../models/article.dart';
import '../models/exchange_rate.dart';

/// Service de gestion de la base de données Isar
class DatabaseService {
  static DatabaseService? _instance;
  static Isar? _isar;
  
  DatabaseService._();
  
  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }
  
  /// Initialiser la base de données
  Future<void> initialize() async {
    if (_isar != null) return;
    
    final dir = await getApplicationDocumentsDirectory();
    
    _isar = await Isar.open(
      [
        UserSchema,
        BudgetSchema,
        ArticleSchema,
        ExchangeRateSchema,
        CurrencySchema,
      ],
      directory: dir.path,
      name: 'vacshop_db',
    );
  }
  
  /// Obtenir l'instance Isar
  Isar get isar {
    if (_isar == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _isar!;
  }
  
  /// Fermer la base de données
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
  
  /// Nettoyer toute la base de données (pour logout/reset)
  Future<void> clearAll() async {
    await _isar?.writeTxn(() async {
      await _isar!.clear();
    });
  }
  
  // ============== USER OPERATIONS ==============
  
  Future<User?> getUserByUid(String uid) async {
    return await isar.users.filter().uidEqualTo(uid).findFirst();
  }
  
  Future<void> saveUser(User user) async {
    await isar.writeTxn(() async {
      await isar.users.put(user);
    });
  }
  
  Future<void> deleteUser(int id) async {
    await isar.writeTxn(() async {
      await isar.users.delete(id);
    });
  }
  
  // ============== BUDGET OPERATIONS ==============
  
  Future<List<Budget>> getBudgetsByUserId(String userId) async {
    return await isar.budgets
        .filter()
        .userIdEqualTo(userId)
        .sortByCreatedAtDesc()
        .findAll();
  }
  
  Future<List<Budget>> getActiveBudgets(String userId) async {
    return await isar.budgets
        .filter()
        .userIdEqualTo(userId)
        .isActiveEqualTo(true)
        .sortByCreatedAtDesc()
        .findAll();
  }
  
  Future<Budget?> getBudgetById(int id) async {
    return await isar.budgets.get(id);
  }
  
  Future<int> saveBudget(Budget budget) async {
    late int id;
    await isar.writeTxn(() async {
      budget.updatedAt = DateTime.now();
      id = await isar.budgets.put(budget);
    });
    return id;
  }
  
  Future<void> deleteBudget(int id) async {
    await isar.writeTxn(() async {
      await isar.budgets.delete(id);
      // Optionnel: supprimer aussi les articles liés
      await isar.articles.filter().budgetIdEqualTo(id).deleteAll();
    });
  }
  
  // ============== ARTICLE OPERATIONS ==============
  
  Future<List<Article>> getArticlesByUserId(String userId) async {
    return await isar.articles
        .filter()
        .userIdEqualTo(userId)
        .sortByScannedAtDesc()
        .findAll();
  }
  
  Future<List<Article>> getArticlesByBudgetId(int budgetId) async {
    return await isar.articles
        .filter()
        .budgetIdEqualTo(budgetId)
        .sortByScannedAtDesc()
        .findAll();
  }
  
  Future<List<Article>> getUnassignedArticles(String userId) async {
    return await isar.articles
        .filter()
        .userIdEqualTo(userId)
        .budgetIdIsNull()
        .sortByScannedAtDesc()
        .findAll();
  }
  
  Future<int> saveArticle(Article article) async {
    late int id;
    await isar.writeTxn(() async {
      article.updatedAt = DateTime.now();
      id = await isar.articles.put(article);
    });
    return id;
  }
  
  Future<void> deleteArticle(int id) async {
    await isar.writeTxn(() async {
      await isar.articles.delete(id);
    });
  }
  
  /// Calculer le montant total utilisé d'un budget
  Future<double> getBudgetUsedAmount(int budgetId) async {
    final articles = await getArticlesByBudgetId(budgetId);
    return articles.fold(0.0, (sum, article) => sum + article.totalConvertedAmount);
  }
  
  // ============== EXCHANGE RATE OPERATIONS ==============
  
  Future<ExchangeRate?> getExchangeRate(String from, String to) async {
    return await isar.exchangeRates
        .filter()
        .fromCurrencyEqualTo(from)
        .and()
        .toCurrencyEqualTo(to)
        .findFirst();
  }
  
  Future<void> saveExchangeRate(ExchangeRate rate) async {
    await isar.writeTxn(() async {
      await isar.exchangeRates.put(rate);
    });
  }
  
  Future<List<ExchangeRate>> getAllExchangeRates() async {
    return await isar.exchangeRates.where().findAll();
  }
  
  Future<void> saveExchangeRates(List<ExchangeRate> rates) async {
    await isar.writeTxn(() async {
      await isar.exchangeRates.putAll(rates);
    });
  }
  
  // ============== CURRENCY OPERATIONS ==============
  
  Future<List<Currency>> getAllCurrencies() async {
    return await isar.currencys.where().sortByCode().findAll();
  }
  
  Future<List<Currency>> getPopularCurrencies() async {
    return await isar.currencys
        .filter()
        .isPopularEqualTo(true)
        .sortByCode()
        .findAll();
  }
  
  Future<Currency?> getCurrencyByCode(String code) async {
    return await isar.currencys.filter().codeEqualTo(code).findFirst();
  }
  
  Future<void> saveCurrency(Currency currency) async {
    await isar.writeTxn(() async {
      await isar.currencys.put(currency);
    });
  }
  
  Future<void> saveCurrencies(List<Currency> currencies) async {
    await isar.writeTxn(() async {
      await isar.currencys.putAll(currencies);
    });
  }
  
  // ============== STATISTICS ==============
  
  Future<int> getTotalScansCount(String userId) async {
    return await isar.articles.filter().userIdEqualTo(userId).count();
  }
  
  Future<int> getTotalBudgetsCount(String userId) async {
    return await isar.budgets.filter().userIdEqualTo(userId).count();
  }
  
  Future<List<String>> getUsedCurrencies(String userId) async {
    final articles = await isar.articles
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    
    final currencies = <String>{};
    for (var article in articles) {
      currencies.add(article.detectedCurrency);
      if (article.targetCurrency != null) {
        currencies.add(article.targetCurrency!);
      }
    }
    
    return currencies.toList();
  }
}
