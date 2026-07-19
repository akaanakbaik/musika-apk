import 'package:flutter/material.dart';
import '../config/theme.dart';

class ErrorDisplay extends StatelessWidget {
  final String? message;
  final String? details;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorDisplay({
    super.key,
    this.message,
    this.details,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              message ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorDisplay(
      icon: Icons.wifi_off,
      message: 'No Internet Connection',
      details: 'Please check your connection and try again.',
      onRetry: onRetry,
    );
  }
}

class ServerErrorWidget extends StatelessWidget {
  final String? error;
  final VoidCallback? onRetry;

  const ServerErrorWidget({super.key, this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorDisplay(
      icon: Icons.cloud_off,
      message: 'Server Error',
      details: error ?? 'The server is not responding. Please try again later.',
      onRetry: onRetry,
    );
  }
}

class AuthRequiredWidget extends StatelessWidget {
  final VoidCallback? onSignIn;

  const AuthRequiredWidget({super.key, this.onSignIn});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.person_outline, size: 40, color: AppTheme.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sign In Required',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to access this feature',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
            if (onSignIn != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onSignIn,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                ),
                child: const Text('Sign In'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: Colors.grey[600]),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(message!, style: const TextStyle(fontSize: 14)),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class RetryWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const RetryWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 48, color: Colors.grey[500]),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400])),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
