import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/pages/analytics_page.dart';
import 'package:task_manager/pages/edit_profile_page.dart';
import 'package:task_manager/pages/loading_page.dart';
import 'package:task_manager/pages/login_page.dart';
import 'package:task_manager/pages/profile_page.dart';
import 'package:task_manager/pages/signup_page.dart';
import 'package:task_manager/pages/tasks_page.dart';

final appRouterProvider = Provider(
  (ref) => GoRouter(
    initialLocation: '/loading',
    routes: [
      GoRoute(path: '/loading', builder: (context, state) => LoadingPage()),
      GoRoute(
        path: '/auth',
        routes: [
          GoRoute(
            path: 'login',
            builder: (context, state) => const LoginPage(),
          ),
          GoRoute(
            path: 'signup',
            builder: (context, state) => const SignupPage(),
          ),
        ],
        redirect: (context, state) => null,
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return KineticShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Tasks
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) =>TaskFlowPage() ,
              ),
            ],
          ),
          // Branch 2: Analytics
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) =>
                    const AnalyticsPage(),
              ),
            ],
          ),
          // Branch 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) =>
                    const ProfilePage(),
              ),
              GoRoute(path: '/edit_profile', builder: (context, state) {
                return EditProfilePage();
              },)
            ],
          ),
        ],
      ),
    ],
  ),
);

int _calculateSelectedIndex(String path) {
  if (path.startsWith('/tasks')) return 0;
  if (path.startsWith('/analytics')) return 1;
  if (path.startsWith('/profile')) return 2;
  return 0;
}





class KineticShellScaffold extends StatelessWidget {
  const KineticShellScaffold({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('KineticShellScaffold'));

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      // The body is the current branch's navigator
      body: navigationShell,
      bottomNavigationBar: Container(
        height: 85,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.85),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.05), width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _KineticNavItem(
              icon: Icons.checklist_rounded,
              label: "Tasks",
              isActive: navigationShell.currentIndex == 0,
              onTap: () => _onTap(context, 0),
            ),
            _KineticNavItem(
              icon: Icons.insights_rounded,
              label: "Analytics",
              isActive: navigationShell.currentIndex == 1,
              onTap: () => _onTap(context, 1),
            ),
            _KineticNavItem(
              icon: Icons.person_outline_rounded,
              label: "Profile",
              isActive: navigationShell.currentIndex == 2,
              onTap: () => _onTap(context, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _KineticNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _KineticNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = Colors.white.withOpacity(0.3);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Kinetic Glow Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 20 : 0,
              height: 2,
              margin: const EdgeInsets.only(bottom:8),
              decoration: BoxDecoration(
                color: activeColor,
                boxShadow: [
                  if (isActive)
                    BoxShadow(
                      color: activeColor.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                ],
              ),
            ),
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}