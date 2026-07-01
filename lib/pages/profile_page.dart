import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/app/theme/dark_theme.dart';
import 'package:task_manager/providers/theme_provider.dart';
import 'package:task_manager/providers/username_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final theme = Theme.of(context);
    final kinetic = theme.extension<KineticEffects>();
    late final String  username ; ref.watch(usernameProvider).whenData((value) {
      username = value;
    });
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        leadingWidth: 150,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Row(
            children: [
              Icon(Icons.grid_view_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                "TaskFlow",
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 14,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.surfaceContainerHigh,
             
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            const SizedBox(height: 32),
            _buildProfileHeader(theme,context,username),
            const SizedBox(height: 48),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(theme, "Settings"),
                  const SizedBox(height: 16),
                  
                  // Interactive Theme Tile
                  _buildSettingTile(
                    theme: theme,
                    kinetic: kinetic,
                    icon: Icons.dark_mode_outlined,
                    iconColor: theme.colorScheme.primary,
                    title: "App Theme",
                    subtitle: "Currently: Dark",
                    onTap: () => _handleThemeChange(context),
                    trailing: _buildWorkingThemeSwitcher(theme:theme,isDark: ref.watch(themeProvider.notifier).isDark ,onThemeChanged: (v){
                      ref.read(themeProvider.notifier).toggle();
                    } ),
                  ),
                  
                  const SizedBox(height: 16),

                  // Interactive Font Size Tile
                 

                  const SizedBox(height: 40),
                  _buildSectionTitle(theme, "Configurations"),
                  const SizedBox(height: 16),
                  
                  // Interactive App Configs Tile
                  _buildSettingTile(
                    theme: theme,
                    kinetic: kinetic,
                    icon: Icons.tune_rounded,
                    iconColor: theme.colorScheme.onTertiaryContainer,
                    title: "App Configurations",
                    subtitle: "Sync, Notifications, Privacy",
                    onTap: () => _handleAppConfigs(context),
                    trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                  ),

                  const SizedBox(height: 48),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _handleLogout(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error.withOpacity(0.1)),
                        backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action Handlers
  void _handleThemeChange(BuildContext context) => print("Navigating to Theme Settings...");
  void _handleAppConfigs(BuildContext context) { print("Opening App Configs...");showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Required for custom rounded corners
      builder: (context) {
        return const _ConfigurationsSheet();
      },
    );}
  void _handleLogout(BuildContext context) =>context.go('/auth/login');

  Widget _buildProfileHeader(ThemeData theme,BuildContext context,String username) {
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 132,
              height: 132,
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
                    child: Image.network('https://picsum.photos/seed/user2/300', fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => print("Edit Photo Tapped"),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
                ),
                child: Icon(Icons.edit_rounded, size: 16, color: theme.colorScheme.onPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(username, style: theme.textTheme.displayLarge?.copyWith(fontSize: 32)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            context.push('/edit_profile');},
          style: theme.elevatedButtonTheme.style?.copyWith(
            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
          ),
          child: const Text("Edit Profile"),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        letterSpacing: 3,
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSettingTile({
    required ThemeData theme,
    KineticEffects? kinetic,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias, // Ensures the Inkwell doesn't bleed past corners
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kinetic?.ghostBorder ?? Colors.white10),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: theme.colorScheme.primary.withOpacity(0.05),
        highlightColor: theme.colorScheme.primary.withOpacity(0.02),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.headlineMedium?.copyWith(fontSize: 16)),
                    Text(subtitle, style: theme.textTheme.labelMedium?.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkingThemeSwitcher({
  required ThemeData theme,
  required bool isDark,
  required Function(bool) onThemeChanged,
}) {
  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dark Mode Option
        GestureDetector(
          onTap: () => onThemeChanged(true),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              // Only show the "active" background if isDark is true
              color: isDark ? theme.colorScheme.background : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              boxShadow: isDark 
                ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] 
                : [],
            ),
            child: Icon(
              Icons.dark_mode_rounded,
              size: 18,
              color: isDark ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        
        const SizedBox(width: 4),

        // Light Mode Option
        GestureDetector(
          onTap: () => onThemeChanged(false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              // Only show the "active" background if isDark is false
              color: !isDark ? theme.colorScheme.background : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              boxShadow: !isDark 
                ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] 
                : [],
            ),
            child: Icon(
              Icons.light_mode_rounded,
              size: 18,
              color: !isDark ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildThemeSwitcher(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
            ),
            child: Icon(Icons.dark_mode_rounded, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.light_mode_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ConfigurationsSheet extends StatefulWidget {
  const _ConfigurationsSheet();

  @override
  State<_ConfigurationsSheet> createState() => _ConfigurationsSheetState();
}
class _ConfigurationsSheetState extends State<_ConfigurationsSheet> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kinetic = theme.extension<KineticEffects>();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // surface-dim in your palette
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: theme.colorScheme.primary.withOpacity(0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.08),
            blurRadius: 48,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Drag Handle
            const SizedBox(height: 16),
            Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
              child: Column(
                children: [
                  // 2. Header
                  Text(
                    "App Configurations",
                    style: theme.textTheme.displayLarge?.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Personalize your kinetic experience",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 3. Local Notifications Item
                  _buildListItem(
                    theme: theme,
                    icon: Icons.notifications_none_rounded,
                    title: "Local Notifications",
                    subtitle: "Stay updated with task alerts",
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (val) => setState(() => _notificationsEnabled = val),
                      activeColor: theme.colorScheme.onPrimaryContainer,
                      activeTrackColor: theme.colorScheme.primaryContainer,
                      inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 4. Locked Item (Visual Consistency)
                  Opacity(
                    opacity: 0.5,
                    child: _buildListItem(
                      theme: theme,
                      icon: Icons.dark_mode_outlined,
                      title: "Dynamic Themes",
                      subtitle: "Locked for premium users",
                      trailing: Icon(
                        Icons.lock_outline_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 5. Done Button
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: theme.elevatedButtonTheme.style?.copyWith(
                      minimumSize: WidgetStateProperty.all(const Size(double.infinity, 64)),
                    ),
                    child: const Text("Done"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(fontSize: 14),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}