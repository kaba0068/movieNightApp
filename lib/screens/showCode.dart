import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hugues_final_project24/utils/app_state.dart';
import 'package:hugues_final_project24/utils/http_helper.dart';
import 'package:hugues_final_project24/screens/movieChoice.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  String? code;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Share Code',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: isLoading
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
          _buildCodeDisplay(),
          const SizedBox(height: 40),
          _buildInstructions(),
          const SizedBox(height: 40),
          _buildBeginButton(),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildCodeDisplay() {
    final theme = Theme.of(context);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: theme.colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 48,
          vertical: 32,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          code ?? 'Error',
          style: theme.textTheme.displayLarge?.copyWith(
            letterSpacing: 4,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Share this code with your friend',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildBeginButton() {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      onPressed: _navigateToMovieScreen,
      style: ElevatedButton.styleFrom(
        iconColor: theme.colorScheme.onPrimary,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4,
      ),
      icon: const Icon(
        Icons.play_arrow_rounded,
        size: 28,
      ),
  
      label: Text(
        'Begin',
        style: theme.textTheme.labelLarge,
      ),
    );
  }

  Future<void> _startSession() async {
    try {
      setState(() => isLoading = true);

      final deviceId = Provider.of<AppState>(context, listen: false).deviceId;
      if (deviceId == null) {
        throw Exception('Device ID not found');
      }

      final response = await HttpHelper.startSession(deviceId);
      final sessionData = response['data'];

      final pref = await SharedPreferences.getInstance();
      await pref.setString("sessionId", sessionData['session_id']);

      setState(() {
        code = sessionData['code'].toString();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        code = 'Error';
        isLoading = false;
      });
      _showErrorDialog('Failed to start session: $e');
    }
  }

  void _navigateToMovieScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MovieCodeScreen(),
      ),
    );
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
