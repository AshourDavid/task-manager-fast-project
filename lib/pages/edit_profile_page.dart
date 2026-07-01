import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/app/theme/dark_theme.dart';
import 'package:task_manager/providers/username_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    // Initialize with current value from provider if available
    final currentUsername = ref.read(usernameProvider).value ?? "Alex Rivera";
    _usernameController = TextEditingController(text: currentUsername);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    final newName = _usernameController.text.trim();
    if (newName.isNotEmpty) {
      // Execute the changeUsername method from your AsyncNotifier
      await ref.read(usernameProvider.notifier).changeUsername(newName);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Identity updated in the flow.")),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kinetic = theme.extension<KineticEffects>();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 150,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Row(
            children: [
              Icon(Icons.grid_view_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                "TASKFLOW",
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 18,
                  letterSpacing: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // Page Header
            Text(
              "Edit Profile",
              style: theme.textTheme.displayLarge?.copyWith(fontSize: 36),
            ),
            const SizedBox(height: 8),
            Text(
              "Define your presence in the flow. Keep your identity sharp and focused.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 48),

            // Profile Photo Section
            _buildAvatarSection(theme),

            const SizedBox(height: 48),

            // Form Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel(theme, "Username"),
                const SizedBox(height: 8),
                TextField(
                  controller: _usernameController,
                  style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerLow,
                    suffixIcon: Icon(Icons.alternate_email, 
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.1)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "This is how your collaborators will see you on task boards.",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // CTA Actions
            ElevatedButton(
              onPressed: _onConfirm,
              style: theme.elevatedButtonTheme.style?.copyWith(
                minimumSize: WidgetStateProperty.all(const Size(double.infinity, 64)),
              ),
              child: const Text("Confirm Changes"),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                "DISCARD CHANGES",
                style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 2),
              ),
            ),

            const SizedBox(height: 32),

            // Activity Pulse Card
           
            
            const SizedBox(height: 100), // BottomNav padding
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(ThemeData theme) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 160,
          height: 160,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
            ),
          ),
          child: CircleAvatar(
            backgroundColor: theme.colorScheme.background,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: ClipOval(
                child: Image.network('https://picsum.photos/seed/editprof/400', fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.edit_rounded, size: 18, color: theme.colorScheme.onPrimary),
        ),
      ],
    );
  }

  Widget _buildLabel(ThemeData theme, String text) {
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        fontSize: 10,
        letterSpacing: 2,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

}