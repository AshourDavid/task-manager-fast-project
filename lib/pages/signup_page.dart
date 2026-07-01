import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/app/theme/dark_theme.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  
  // Controllers for validation/data access
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kinetic = theme.extension<KineticEffects>()!;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Ambient Background Glows
          _buildAmbientGlow(
            top: -100,
            right: -100,
            color: theme.colorScheme.primary.withOpacity(0.05),
          ),
          _buildAmbientGlow(
            bottom: -100,
            left: -100,
            color: theme.colorScheme.tertiaryContainer.withOpacity(0.05),
          ),

          Row(
            children: [
              // Main Form Area
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildHeader(theme),
                          const SizedBox(height: 48),
                          _buildSignupCard(theme, kinetic),
                          const SizedBox(height: 32),
                          _buildFooter(theme),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // 2. Desktop Side Decoration (Hidden on mobile)
              if (isDesktop) _buildDesktopAside(theme, kinetic),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Icon(
          Icons.grid_view_rounded,
          size: 48,
          color: theme.colorScheme.primaryContainer,
        ),
        const SizedBox(height: 16),
        Text("TaskFlow", style: theme.textTheme.displayLarge?.copyWith(color: theme.colorScheme.primary)),
        Text("Create Account", style: theme.textTheme.headlineMedium),
      ],
    );
  }

  Widget _buildSignupCard(ThemeData theme, KineticEffects kinetic) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kinetic.ghostBorder ?? Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            _buildLabel("Full Name", theme),
            TextFormField(
              controller: _nameController,
              style: theme.textTheme.bodyMedium,
              decoration: const InputDecoration(hintText: "John Doe"),
              validator: (value) => (value == null || value.isEmpty) ? "Please enter your name" : null,
            ),
            const SizedBox(height: 24),

            // Email Field
            _buildLabel("Email Address", theme),
            TextFormField(
              controller: _emailController,
              style: theme.textTheme.bodyMedium,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: "name@company.com"),
              validator: (value) {
                if (value == null || !RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                  return "Enter a valid email address";
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Password Field
            _buildLabel("Password", theme),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: "••••••••",
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, size: 20),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  color: Colors.white30,
                ),
              ),
              validator: (value) => (value != null && value.length < 8) ? "Password must be at least 8 characters" : null,
            ),
            const SizedBox(height: 32),

            // Submit Button with Gradient
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ElevatedButton(
                style: theme.elevatedButtonTheme.style?.copyWith(
                  backgroundColor: WidgetStateProperty.all(Colors.transparent),
                  shadowColor: WidgetStateProperty.all(Colors.transparent),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Logic for successful validation
                     context.go('/tasks');
                  }
                },
                child: const Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text.toUpperCase(), 
        style: theme.textTheme.labelMedium?.copyWith(
          letterSpacing: 1.2, 
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface.withOpacity(0.5)
        )
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account?", style: theme.textTheme.labelMedium),
        TextButton(
          onPressed: () {
            context.go('/auth/login');
          },
          child: Text("Log in", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildDesktopAside(ThemeData theme, KineticEffects kinetic) {
    return Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.only(right: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("PHASE 01", style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primaryContainer,
              letterSpacing: 4,
            )),
            const SizedBox(height: 8),
            Text(
              "Master your\nworkflow.",
              textAlign: TextAlign.right,
              style: theme.textTheme.displayLarge?.copyWith(fontSize: 48),
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kinetic.ghostBorder!),
              ),
              child: Text(
                "\"Simplicity is the ultimate sophistication. TaskFlow transforms the noise into a rhythmic ritual.\"",
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientGlow({double? top, double? bottom, double? left, double? right, required Color color}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
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