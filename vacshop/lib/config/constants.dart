/// Constantes de l'application VacShop
class AppConstants {
  // App Info
  static const String appName = 'VacShop';
  static const String appTagline = 'Voyagez malin, budgétez simple';
  static const String appVersion = '1.0.0';
  
  // Routes
  static const String routeSplash = '/';
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeSignup = '/signup';
  static const String routeHome = '/home';
  static const String routeDashboard = '/dashboard';
  static const String routeScan = '/scan';
  static const String routeScanResult = '/scan-result';
  static const String routeArticleDetails = '/article-details';
  static const String routeBudget = '/budget';
  static const String routeHistory = '/history';
  static const String routeSettings = '/settings';
  static const String routeProfile = '/profile';
  static const String routeCurrencies = '/currencies';
  
  // Storage Keys
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyDefaultCurrency = 'default_currency';
  static const String keyLastSyncDate = 'last_sync_date';
  static const String keyOfflineMode = 'offline_mode';
  
  // VLM Configuration
  static const String vlmModelPath = 'assets/models/vacshop_vlm.tflite';
  static const int vlmInputImageWidth = 224;
  static const int vlmInputImageHeight = 224;
  static const double vlmConfidenceThreshold = 0.75;
  
  // Currency API
  static const String currencyDataPath = 'assets/data/exchange_rates.json';
  static const int currencyUpdateIntervalHours = 24;
  
  // Limits
  static const int maxScansPerDay = 1000;
  static const int maxBudgets = 10;
  static const int maxArticlesPerBudget = 500;
  static const int historyRetentionDays = 365;
  
  // Categories
  static const List<String> defaultCategories = [
    'Restaurant',
    'Transport',
    'Hébergement',
    'Shopping',
    'Loisirs',
    'Santé',
    'Autre',
  ];
  
  // Supported Currencies (principales)
  static const List<String> popularCurrencies = [
    'CAD', // Dollar canadien
    'USD', // Dollar américain
    'EUR', // Euro
    'GBP', // Livre sterling
    'JPY', // Yen japonais
    'CHF', // Franc suisse
    'AUD', // Dollar australien
    'CNY', // Yuan chinois
  ];
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration vlmInferenceTimeout = Duration(seconds: 5);
  
  // Error Messages
  static const String errorGeneric = 'Une erreur est survenue. Veuillez réessayer.';
  static const String errorNetwork = 'Connexion internet indisponible.';
  static const String errorVLM = 'Impossible de détecter le prix. Réessayez avec une meilleure photo.';
  static const String errorAuth = 'Authentification échouée. Vérifiez vos identifiants.';
  static const String errorCamera = 'Impossible d\'accéder à la caméra.';
  
  // Success Messages
  static const String successLogin = 'Connexion réussie !';
  static const String successSignup = 'Compte créé avec succès !';
  static const String successScan = 'Prix détecté !';
  static const String successArticleAdded = 'Article ajouté au budget.';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
}
