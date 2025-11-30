import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _authService.signOut();
      Navigator.of(context).pushReplacementNamed(AppConstants.routeLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentFirebaseUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profil utilisateur
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? Text(
                          (user?.displayName ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Utilisateur',
                        style: AppTextStyles.h4.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.6),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Section Général
          const _SectionHeader(title: 'Général'),
          const SizedBox(height: 8),

          _SettingsTile(
            icon: Icons.monetization_on_outlined,
            title: 'Devise par défaut',
            subtitle: 'CAD - Dollar canadien',
            onTap: () {
              // TODO: Ouvrir le sélecteur de devise
            },
          ),

          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Gérer les alertes et rappels',
            onTap: () {
              // TODO: Ouvrir les paramètres de notifications
            },
          ),

          _SettingsTile(
            icon: Icons.language_outlined,
            title: 'Langue',
            subtitle: 'Français',
            onTap: () {
              // TODO: Sélecteur de langue
            },
          ),

          const SizedBox(height: 24),

          // Section Budget
          const _SectionHeader(title: 'Budget & Devises'),
          const SizedBox(height: 8),

          _SettingsTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Mes budgets',
            subtitle: '3 budgets actifs',
            onTap: () {
              // TODO: Liste des budgets
            },
          ),

          _SettingsTile(
            icon: Icons.currency_exchange_outlined,
            title: 'Taux de change',
            subtitle: 'Mis à jour il y a 3h',
            trailing: TextButton(
              onPressed: () {
                // TODO: Mettre à jour les taux
              },
              child: const Text('Actualiser'),
            ),
          ),

          const SizedBox(height: 24),

          // Section Données
          const _SectionHeader(title: 'Données'),
          const SizedBox(height: 8),

          _SettingsTile(
            icon: Icons.wifi_off_outlined,
            title: 'Mode hors ligne',
            subtitle: 'Utiliser l\'app sans connexion',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Toggle offline mode
              },
              activeColor: AppColors.primary,
            ),
          ),

          _SettingsTile(
            icon: Icons.cloud_upload_outlined,
            title: 'Synchronisation',
            subtitle: 'Sauvegarder vos données',
            onTap: () {
              // TODO: Paramètres de sync
            },
          ),

          _SettingsTile(
            icon: Icons.delete_outline,
            title: 'Effacer les données locales',
            subtitle: 'Supprimer le cache',
            onTap: () {
              // TODO: Confirmer et effacer
            },
          ),

          const SizedBox(height: 24),

          // Section À propos
          const _SectionHeader(title: 'À propos'),
          const SizedBox(height: 8),

          _SettingsTile(
            icon: Icons.info_outlined,
            title: 'Version',
            subtitle: AppConstants.appVersion,
          ),

          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Politique de confidentialité',
            onTap: () {
              // TODO: Ouvrir politique
            },
          ),

          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Conditions d\'utilisation',
            onTap: () {
              // TODO: Ouvrir conditions
            },
          ),

          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Aide et support',
            onTap: () {
              // TODO: Support
            },
          ),

          const SizedBox(height: 32),

          // Bouton de déconnexion
          OutlinedButton(
            onPressed: _handleLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Se déconnecter'),
          ),

          const SizedBox(height: 16),

          // Footer
          Center(
            child: Text(
              'Made with ❤️ by Da Vinci Nova Corp',
              style: AppTextStyles.caption,
            ),
          ),

          const SizedBox(height: 80), // Espace pour la barre de navigation
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.h4.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
