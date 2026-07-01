import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/app/theme/dark_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _TaskFlowLoginPageState();
}

class _TaskFlowLoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Validation Logic
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid corporate email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Minimum 6 characters required';
    return null;
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {

        context.go('/tasks');

    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final kinetic = theme.extension<KineticEffects>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // 1. Background Atmospheric Glows
          _buildAmbientGlow(Alignment.topLeft, colorScheme.primary.withOpacity(0.05)),
          _buildAmbientGlow(Alignment.bottomRight, colorScheme.tertiaryContainer.withOpacity(0.05)),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 2. Brand Identity Section
                  _buildBrandHeader(colorScheme, theme.textTheme),
                  const SizedBox(height: 48),

                  // 3. Login Container
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kinetic?.ghostBorder ?? Colors.white10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel("Email Address", theme),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            validator: _validateEmail,
                            style: theme.textTheme.bodyMedium,
                            decoration: const InputDecoration(
                              hintText: "name@company.com",
                              prefixIcon: Icon(Icons.alternate_email, size: 20),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildFieldLabel("Password", theme),
                              TextButton(
                                onPressed: () {},
                                child: Text("Forgot Password?", 
                                  style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.primary)),
                              ),
                            ],
                          ),
                          TextFormField(
                            controller: _passwordController,
                            validator: _validatePassword,
                            obscureText: true,
                            style: theme.textTheme.bodyMedium,
                            decoration: const InputDecoration(
                              hintText: "••••••••",
                              prefixIcon: Icon(Icons.lock_outline, size: 20),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // 4. Action Button (Gradient to match HTML)
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                colors: [colorScheme.primary, colorScheme.primaryContainer],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: _handleSignIn,
                              style: theme.elevatedButtonTheme.style?.copyWith(
                                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                                shadowColor: WidgetStateProperty.all(Colors.transparent),
                                
                              ),
                              child: const Text("Sign In"),
                            ),
                          ),

                          const SizedBox(height: 32),
                          _buildSocialDivider(theme),
                          const SizedBox(height: 24),
                          _buildSocialGrid(theme),
                        ],
                      ),
                    ),
                  ),
                  
                  // 5. Footer Link
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("New to TaskFlow?", style: theme.textTheme.labelMedium),
                      TextButton(
                        onPressed: () {
                          context.go('/auth/signup');
                        },
                        child: Text("Create an account", 
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary, 
                            fontWeight: FontWeight.bold
                          )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Field Labels
  Widget _buildFieldLabel(String label, ThemeData theme) {
    return Text(
      label.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        letterSpacing: 1.5,
        fontWeight: FontWeight.w700,
        fontSize: 10,
      ),
    );
  }

  // Helper: Brand Header
  Widget _buildBrandHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.grid_view_rounded, color: colorScheme.primary, size: 40),
        ),
        const SizedBox(height: 16),
        Text("TaskFlow", style: textTheme.displayLarge?.copyWith(fontSize: 48, color: colorScheme.primary)),
        const SizedBox(height: 8),
        Text("Welcome back to your focus ritual.", style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6))),
      ],
    );
  }

  // Helper: Social Login Divider
  Widget _buildSocialDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("CONTINUE WITH", style: theme.textTheme.labelMedium?.copyWith(fontSize: 9, fontWeight: FontWeight.bold)),
        ),
        Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
      ],
    );
  }

  // Helper: Social Buttons
  Widget _buildSocialGrid(ThemeData theme) {
    return Row(
      children: [
        Expanded(child: _buildSocialButton(Icons.g_mobiledata, "Google", theme)),
        const SizedBox(width: 16),
        Expanded(child: _buildSocialButton(Icons.apple, "Apple", theme)),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label, ThemeData theme) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: theme.textTheme.labelMedium?.copyWith(color: Colors.white)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildAmbientGlow(Alignment alignment, Color color) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color, blurRadius: 120, spreadRadius: 50)],
        ),
      ),
    );
  }
}