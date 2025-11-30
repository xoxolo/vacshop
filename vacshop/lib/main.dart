import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/theme.dart';
import 'config/constants.dart';
import 'services/database_service.dart';
import 'services/currency_service.dart';
import 'services/vlm_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/scan/scan_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuration du système
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialiser Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('⚠️ Firebase initialization error: $e');
  }
  
  // Initialiser la base de données
  await DatabaseService.instance.initialize();
  
  // Initialiser le service de devises
  await CurrencyService.instance.initialize();
  
  // Initialiser le service VLM
  try {
    await VLMService.instance.initialize();
  } catch (e) {
    print('⚠️ VLM initialization error: $e');
    // L'app peut fonctionner sans VLM en mode dégradé
  }
  
  runApp(
    const ProviderScope(
      child: VacShopApp(),
    ),
  );
}

class VacShopApp extends StatelessWidget {
  const VacShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      
      // Route initiale
      initialRoute: AppConstants.routeSplash,
      
      // Routes de l'application
      routes: {
        AppConstants.routeSplash: (context) => const SplashScreen(),
        AppConstants.routeOnboarding: (context) => const OnboardingScreen(),
        AppConstants.routeLogin: (context) => const LoginScreen(),
        AppConstants.routeSignup: (context) => const SignupScreen(),
        AppConstants.routeHome: (context) => const HomeScreen(),
        AppConstants.routeDashboard: (context) => const DashboardScreen(),
        AppConstants.routeScan: (context) => const ScanScreen(),
      },
    );
  }
}
