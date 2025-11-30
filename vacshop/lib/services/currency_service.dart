import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'database_service.dart';
import '../models/exchange_rate.dart';
import '../config/constants.dart';

/// Service de conversion de devises (100% offline)
class CurrencyService {
  static CurrencyService? _instance;
  final DatabaseService _db = DatabaseService.instance;
  
  CurrencyService._();
  
  static CurrencyService get instance {
    _instance ??= CurrencyService._();
    return _instance!;
  }
  
  // API pour mettre à jour les taux (optionnel, quand online)
  static const String _exchangeRateApiUrl = 'https://api.exchangerate-api.com/v4/latest/';
  
  /// Initialiser les devises et taux de change depuis les assets
  Future<void> initialize() async {
    try {
      // Vérifier si déjà initialisé
      final existingRates = await _db.getAllExchangeRates();
      
      if (existingRates.isEmpty) {
        // Charger les taux depuis les assets
        await _loadInitialExchangeRates();
      }
      
      // Initialiser les devises
      await _initializeCurrencies();
      
      print('✅ Currency service initialized');
    } catch (e) {
      print('❌ Error initializing currency service: $e');
      throw Exception('Failed to initialize currency service: $e');
    }
  }
  
  /// Charger les taux de change initiaux depuis assets/data
  Future<void> _loadInitialExchangeRates() async {
    try {
      final jsonString = await rootBundle.loadString(AppConstants.currencyDataPath);
      final Map<String, dynamic> data = json.decode(jsonString);
      
      // Format attendu: {"rates": {"EUR": 0.85, "GBP": 0.73, ...}, "base": "USD"}
      final String baseCurrency = data['base'] ?? 'USD';
      final Map<String, dynamic> rates = data['rates'] ?? {};
      
      final List<ExchangeRate> exchangeRates = [];
      
      // Créer les taux de change depuis la devise de base
      rates.forEach((currency, rate) {
        exchangeRates.add(ExchangeRate(
          fromCurrency: baseCurrency,
          toCurrency: currency,
          rate: (rate as num).toDouble(),
          lastUpdated: DateTime.now(),
        ));
      });
      
      // Ajouter le taux 1:1 pour la devise de base
      exchangeRates.add(ExchangeRate(
        fromCurrency: baseCurrency,
        toCurrency: baseCurrency,
        rate: 1.0,
        lastUpdated: DateTime.now(),
      ));
      
      await _db.saveExchangeRates(exchangeRates);
      
      print('✅ Loaded ${exchangeRates.length} initial exchange rates');
    } catch (e) {
      print('⚠️ Could not load initial exchange rates: $e');
      // Créer des taux par défaut si le fichier n'existe pas
      await _createDefaultRates();
    }
  }
  
  /// Créer des taux de change par défaut si aucun fichier n'est disponible
  Future<void> _createDefaultRates() async {
    final defaultRates = [
      ExchangeRate(fromCurrency: 'CAD', toCurrency: 'USD', rate: 0.74),
      ExchangeRate(fromCurrency: 'CAD', toCurrency: 'EUR', rate: 0.68),
      ExchangeRate(fromCurrency: 'CAD', toCurrency: 'GBP', rate: 0.58),
      ExchangeRate(fromCurrency: 'USD', toCurrency: 'CAD', rate: 1.35),
      ExchangeRate(fromCurrency: 'USD', toCurrency: 'EUR', rate: 0.92),
      ExchangeRate(fromCurrency: 'EUR', toCurrency: 'USD', rate: 1.09),
      ExchangeRate(fromCurrency: 'EUR', toCurrency: 'CAD', rate: 1.47),
    ];
    
    await _db.saveExchangeRates(defaultRates);
  }
  
  /// Initialiser la liste des devises
  Future<void> _initializeCurrencies() async {
    final existingCurrencies = await _db.getAllCurrencies();
    
    if (existingCurrencies.isEmpty) {
      final currencies = [
        Currency(code: 'CAD', name: 'Dollar canadien', symbol: '\$', flag: '🇨🇦', isPopular: true),
        Currency(code: 'USD', name: 'Dollar américain', symbol: '\$', flag: '🇺🇸', isPopular: true),
        Currency(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺', isPopular: true),
        Currency(code: 'GBP', name: 'Livre sterling', symbol: '£', flag: '🇬🇧', isPopular: true),
        Currency(code: 'JPY', name: 'Yen japonais', symbol: '¥', flag: '🇯🇵', isPopular: true),
        Currency(code: 'CHF', name: 'Franc suisse', symbol: 'Fr', flag: '🇨🇭', isPopular: true),
        Currency(code: 'AUD', name: 'Dollar australien', symbol: '\$', flag: '🇦🇺', isPopular: true),
        Currency(code: 'CNY', name: 'Yuan chinois', symbol: '¥', flag: '🇨🇳', isPopular: true),
        Currency(code: 'MXN', name: 'Peso mexicain', symbol: '\$', flag: '🇲🇽', isPopular: false),
        Currency(code: 'BRL', name: 'Real brésilien', symbol: 'R\$', flag: '🇧🇷', isPopular: false),
        Currency(code: 'INR', name: 'Roupie indienne', symbol: '₹', flag: '🇮🇳', isPopular: false),
        Currency(code: 'KRW', name: 'Won sud-coréen', symbol: '₩', flag: '🇰🇷', isPopular: false),
        Currency(code: 'THB', name: 'Baht thaïlandais', symbol: '฿', flag: '🇹🇭', isPopular: false),
        Currency(code: 'SGD', name: 'Dollar de Singapour', symbol: '\$', flag: '🇸🇬', isPopular: false),
        Currency(code: 'NZD', name: 'Dollar néo-zélandais', symbol: '\$', flag: '🇳🇿', isPopular: false),
        Currency(code: 'SEK', name: 'Couronne suédoise', symbol: 'kr', flag: '🇸🇪', isPopular: false),
        Currency(code: 'NOK', name: 'Couronne norvégienne', symbol: 'kr', flag: '🇳🇴', isPopular: false),
        Currency(code: 'DKK', name: 'Couronne danoise', symbol: 'kr', flag: '🇩🇰', isPopular: false),
        Currency(code: 'PLN', name: 'Zloty polonais', symbol: 'zł', flag: '🇵🇱', isPopular: false),
        Currency(code: 'TRY', name: 'Livre turque', symbol: '₺', flag: '🇹🇷', isPopular: false),
      ];
      
      await _db.saveCurrencies(currencies);
      print('✅ Initialized ${currencies.length} currencies');
    }
  }
  
  /// Convertir un montant d'une devise à une autre
  Future<double?> convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) return amount;
    
    try {
      // Essayer de trouver le taux de change direct
      var rate = await _db.getExchangeRate(fromCurrency, toCurrency);
      
      if (rate != null) {
        return amount * rate.rate;
      }
      
      // Si pas de taux direct, essayer via USD comme pivot
      final rateToUSD = await _db.getExchangeRate(fromCurrency, 'USD');
      final rateFromUSD = await _db.getExchangeRate('USD', toCurrency);
      
      if (rateToUSD != null && rateFromUSD != null) {
        final convertedToUSD = amount * rateToUSD.rate;
        return convertedToUSD * rateFromUSD.rate;
      }
      
      print('⚠️ No exchange rate found for $fromCurrency -> $toCurrency');
      return null;
    } catch (e) {
      print('❌ Error converting currency: $e');
      return null;
    }
  }
  
  /// Obtenir le taux de change entre deux devises
  Future<double?> getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) return 1.0;
    
    final rate = await _db.getExchangeRate(fromCurrency, toCurrency);
    
    if (rate != null) {
      return rate.rate;
    }
    
    // Essayer via pivot USD
    final rateToUSD = await _db.getExchangeRate(fromCurrency, 'USD');
    final rateFromUSD = await _db.getExchangeRate('USD', toCurrency);
    
    if (rateToUSD != null && rateFromUSD != null) {
      return rateToUSD.rate * rateFromUSD.rate;
    }
    
    return null;
  }
  
  /// Mettre à jour les taux de change depuis l'API (quand online)
  Future<bool> updateExchangeRates({String baseCurrency = 'USD'}) async {
    try {
      // Vérifier la connexion
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('⚠️ No internet connection, using cached rates');
        return false;
      }
      
      // Appeler l'API
      final response = await http
          .get(Uri.parse('$_exchangeRateApiUrl$baseCurrency'))
          .timeout(AppConstants.networkTimeout);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> rates = data['rates'] ?? {};
        
        final List<ExchangeRate> exchangeRates = [];
        
        rates.forEach((currency, rate) {
          exchangeRates.add(ExchangeRate(
            fromCurrency: baseCurrency,
            toCurrency: currency,
            rate: (rate as num).toDouble(),
            lastUpdated: DateTime.now(),
          ));
        });
        
        await _db.saveExchangeRates(exchangeRates);
        
        print('✅ Updated ${exchangeRates.length} exchange rates');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error updating exchange rates: $e');
      return false;
    }
  }
  
  /// Obtenir toutes les devises
  Future<List<Currency>> getAllCurrencies() async {
    return await _db.getAllCurrencies();
  }
  
  /// Obtenir les devises populaires
  Future<List<Currency>> getPopularCurrencies() async {
    return await _db.getPopularCurrencies();
  }
  
  /// Obtenir une devise par son code
  Future<Currency?> getCurrencyByCode(String code) async {
    return await _db.getCurrencyByCode(code);
  }
  
  /// Formater un montant avec sa devise
  String formatAmount({
    required double amount,
    required String currencyCode,
    int decimals = 2,
  }) {
    final currency = _db.getCurrencyByCode(currencyCode);
    
    return currency.then((curr) {
      if (curr != null) {
        return '${curr.symbol ?? currencyCode} ${amount.toStringAsFixed(decimals)}';
      }
      return '$currencyCode ${amount.toStringAsFixed(decimals)}';
    }).toString();
  }
}
