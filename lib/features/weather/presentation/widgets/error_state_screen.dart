import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ErrorStateScreen extends StatelessWidget {
  final ErrorStateType errorType;
  final String? customMessage;
  final VoidCallback onRetry;
  final VoidCallback? onOpenSettings;

  const ErrorStateScreen({
    super.key,
    required this.errorType,
    this.customMessage,
    required this.onRetry,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildErrorIllustration(context),
              const SizedBox(height: 32),
              _buildErrorTitle(context),
              const SizedBox(height: 16),
              _buildErrorMessage(context),
              const SizedBox(height: 32),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIllustration(BuildContext context) {
    return SizedBox(
      height: 200,
      child: _getErrorAnimation(),
    );
  }

  Widget _getErrorAnimation() {
    switch (errorType) {
      case ErrorStateType.offline:
        return LottieBuilder.asset(
          'assets/lottie/Cloud.json',
          repeat: true,
        );
      case ErrorStateType.permissionDenied:
        return Icon(
          Icons.location_off,
          size: 120,
          color: Colors.orange,
        );
      case ErrorStateType.notFound:
        return Icon(
          Icons.location_off,
          size: 120,
          color: Colors.blue,
        );
      case ErrorStateType.networkError:
        return Icon(
          Icons.cloud_off,
          size: 120,
          color: Colors.red,
        );
      case ErrorStateType.generic:
        return Icon(
          Icons.error_outline,
          size: 120,
          color: Colors.red,
        );
    }
  }

  String _getErrorTitle() {
    switch (errorType) {
      case ErrorStateType.offline:
        return 'No Connection';
      case ErrorStateType.permissionDenied:
        return 'Permission Denied';
      case ErrorStateType.notFound:
        return 'Location Not Found';
      case ErrorStateType.networkError:
        return 'Network Error';
      case ErrorStateType.generic:
        return 'Oops!';
    }
  }

  String _getErrorDescription() {
    switch (errorType) {
      case ErrorStateType.offline:
        return 'Please check your internet connection and try again.';
      case ErrorStateType.permissionDenied:
        return 'We need location permission to get your current weather. Please enable it in settings.';
      case ErrorStateType.notFound:
        return 'We couldn\'t find the location you\'re looking for.';
      case ErrorStateType.networkError:
        return 'There was a problem connecting to the weather service.';
      case ErrorStateType.generic:
        return customMessage ?? 'Something went wrong. Please try again.';
    }
  }

  Widget _buildErrorTitle(BuildContext context) {
    return Text(
      _getErrorTitle(),
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Text(
      _getErrorDescription(),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white70,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        if (errorType == ErrorStateType.permissionDenied &&
            onOpenSettings != null)
          Column(
            children: [
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onOpenSettings,
                  icon: const Icon(Icons.settings),
                  label: const Text('Open Settings'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

enum ErrorStateType {
  offline,
  permissionDenied,
  notFound,
  networkError,
  generic,
}
