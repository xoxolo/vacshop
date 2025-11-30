import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  
  // Données mock pour la démo
  final int _totalScans = 127;
  final int _totalTrips = 12;
  final int _totalCurrencies = 8;
  
  final String _currentBudgetName = 'Voyage Tokyo 2024';
  final double _budgetTotal = 750.0;
  final double _budgetUsed = 180.0;
  final String _currency = 'CAD';

  @override
  Widget build(BuildContext context) {
    final budgetPercentage = (_budgetUsed / _budgetTotal * 100).toStringAsFixed(0);
    final budgetRemaining = _budgetTotal - _budgetUsed;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implémenter les notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salutation
            Text(
              'Bonjour, ${_authService.currentFirebaseUser?.displayName ?? "Voyageur"} !',
              style: AppTextStyles.h2,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Voici un résumé de vos dépenses',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Stats cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.camera_alt,
                    value: _totalScans.toString(),
                    label: 'Scans',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.flight_takeoff,
                    value: _totalTrips.toString(),
                    label: 'Voyages',
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.monetization_on,
                    value: _totalCurrencies.toString(),
                    label: 'Devises',
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Budget actuel
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _currentBudgetName,
                        style: AppTextStyles.h4.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$budgetPercentage%',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Montant utilisé
                  Text(
                    '\$ ${_budgetUsed.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  
                  Text(
                    'sur \$ ${_budgetTotal.toStringAsFixed(2)} $_currency',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Barre de progression
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _budgetUsed / _budgetTotal,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Restant: \$ ${budgetRemaining.toStringAsFixed(2)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        'Confiance: 98%',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Section Dépenses récentes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dépenses récentes',
                  style: AppTextStyles.h3,
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Naviguer vers l'historique complet
                  },
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Liste des transactions récentes (mock)
            _TransactionCard(
              icon: Icons.restaurant,
              category: 'Restaurant',
              name: 'Pizza carbonara',
              amount: 25.75,
              currency: 'EUR',
              convertedAmount: 36.18,
              targetCurrency: _currency,
              date: DateTime.now().subtract(const Duration(hours: 2)),
            ),
            
            const SizedBox(height: 12),
            
            _TransactionCard(
              icon: Icons.local_taxi,
              category: 'Transport',
              name: 'Taxi aéroport',
              amount: 45.00,
              currency: 'EUR',
              convertedAmount: 63.25,
              targetCurrency: _currency,
              date: DateTime.now().subtract(const Duration(days: 1)),
            ),
            
            const SizedBox(height: 12),
            
            _TransactionCard(
              icon: Icons.shopping_bag,
              category: 'Shopping',
              name: 'Souvenirs',
              amount: 32.50,
              currency: 'EUR',
              convertedAmount: 45.67,
              targetCurrency: _currency,
              date: DateTime.now().subtract(const Duration(days: 2)),
            ),
            
            const SizedBox(height: 80), // Espace pour le FAB
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final IconData icon;
  final String category;
  final String name;
  final double amount;
  final String currency;
  final double convertedAmount;
  final String targetCurrency;
  final DateTime date;
  
  const _TransactionCard({
    required this.icon,
    required this.category,
    required this.name,
    required this.amount,
    required this.currency,
    required this.convertedAmount,
    required this.targetCurrency,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(date);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      category,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Text(' • '),
                    Text(
                      timeAgo,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$ ${convertedAmount.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$amount $currency',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return 'Il y a ${difference.inMinutes}min';
    }
  }
}
