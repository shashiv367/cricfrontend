import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class InningsStoreScreen extends StatelessWidget {
  const InningsStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Market', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront_rounded, size: 80, color: AppColors.primaryElectric.withOpacity(0.2)),
              const SizedBox(height: 16),
              const Text(
                'Market',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Sell cricket products, services, or your cricket skills to millions of cricket enthusiasts.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
