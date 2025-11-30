import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/social_auth_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isOnline = true;
  
  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }
  
  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = result != ConnectivityResult.none;
    });
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      // Essayer connexion online ou offline selon la connectivité
      final user = _isOnline
          ? await _authService.signInWithEmail(email: email, password: password)
          : await _authService.signInOffline(email: email, password: password);
      
      if (user != null && mounted) {
        // Succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isOnline ? AppConstants.successLogin : 'Connexion offline réussie'),
            backgroundColor: AppColors.success,
          ),
        );
        
        Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _handleGoogleSignIn() async {
    if (!_isOnline) {
      _showOfflineError();
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final user = await _authService.signInWithGoogle();
      
      if (user != null && mounted) {
        Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _handleFacebookSignIn() async {
    if (!_isOnline) {
      _showOfflineError();
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final user = await _authService.signInWithFacebook();
      
      if (user != null && mounted) {
        Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _showOfflineError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cette fonctionnalité nécessite une connexion internet'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo et titre
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: AppColors.primary,
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  'Connexion',
                  style: AppTextStyles.h1,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Bienvenue sur ${AppConstants.appName}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Indicateur de connexion
                if (!_isOnline)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warning),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_off, color: AppColors.warning, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Mode hors ligne - Utilisez vos identifiants existants',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Courriel',
                  hint: 'votre@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre courriel';
                    }
                    if (!RegExp(AppConstants.emailRegex).hasMatch(value)) {
                      return 'Courriel invalide';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Mot de passe
                CustomTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  hint: '••••••••',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    if (value.length < AppConstants.minPasswordLength) {
                      return 'Le mot de passe doit contenir au moins ${AppConstants.minPasswordLength} caractères';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Bouton de connexion
                CustomButton(
                  text: 'Se connecter',
                  onPressed: _isLoading ? null : _handleLogin,
                  isLoading: _isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // Lien "Continuer sans compte" visible seulement online
                if (_isOnline)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppConstants.routeSignup);
                    },
                    child: Text(
                      'Pas de compte ? Inscrivez-vous',
                      style: AppTextStyles.link,
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Divider
                if (_isOnline) ...[
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Ou continuer avec',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Boutons OAuth
                  Row(
                    children: [
                      Expanded(
                        child: SocialAuthButton(
                          icon: 'assets/icons/google.svg',
                          label: 'Google',
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SocialAuthButton(
                          icon: 'assets/icons/facebook.svg',
                          label: 'Facebook',
                          onPressed: _isLoading ? null : _handleFacebookSignIn,
                        ),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Conditions
                Text(
                  'En continuant, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
