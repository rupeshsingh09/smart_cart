import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isOffline;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.xl),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          Text(
            isOffline ? 'No Internet Connection' : 'Something went wrong',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.xl),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
              ),
              child: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String subMessage;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.subMessage = "Try searching for something else",
    this.icon = Icons.search_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              subMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
