import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:hugues_final_project24/utils/app_state.dart';
import 'package:hugues_final_project24/screens/enterCode.dart';
import 'package:hugues_final_project24/screens/showCode.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeDeviceId();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Movie Night',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: _isInitializing
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          _buildLogo(),
          const SizedBox(height: 48),
          _buildButtons(),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          Icons.movie_outlined,
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Welcome to Movie Night',
          style: theme.textTheme.displayMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Find the perfect movie to watch together',
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildButtons() {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActionButton(
              onPressed: () => _navigateToScreen(const CreateScreen()),
              icon: Icons.add_circle_outline,
              label: 'Start New Session',
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              onPressed: () => _navigateToScreen(const JoinScreen()),
              icon: Icons.login_rounded,
              label: 'Join Session',
              isPrimary: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        iconColor:
            isPrimary ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
        backgroundColor:
            isPrimary ? theme.colorScheme.primary : theme.colorScheme.surface,
        foregroundColor:
            isPrimary ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: isPrimary
              ? BorderSide.none
              : BorderSide(color: theme.colorScheme.primary),
        ),
        elevation: isPrimary ? 4 : 0,
      ),
      icon: Icon(icon, size: 24),
      label: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: isPrimary
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.primary,
        ),
      ),
    );
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Future<void> _initializeDeviceId() async {
    try {
      final deviceId = await _fetchDeviceId();
      if (mounted) {
        Provider.of<AppState>(context, listen: false).setDeviceId(deviceId);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to initialize device: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<String> _fetchDeviceId() async {
    try {
      if (Platform.isAndroid) {
        const androidPlugin = AndroidId();
        return await androidPlugin.getId() ?? 'Unknown Android ID';
      } else if (Platform.isIOS) {
        final deviceInfo = await DeviceInfoPlugin().iosInfo;
        return deviceInfo.identifierForVendor ?? 'Unknown iOS ID';
      }
      return 'Unsupported platform';
    } catch (e) {
      throw Exception('Failed to fetch device ID: $e');
    }
  }

  void _showErrorDialog(String message) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Error',
          style: theme.textTheme.titleMedium,
        ),
        content: Text(
          message,
          style: theme.textTheme.bodyMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
