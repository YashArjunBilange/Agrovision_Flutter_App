import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/farm/presentation/farm_screen.dart';
import '../features/disease_detection/presentation/scan_screen.dart';
import '../features/assistant/presentation/assistant_screen.dart';
import '../features/weather/presentation/weather_screen.dart';
import '../features/crop_lifecycle/presentation/lifecycle_screen.dart';
import '../features/finance/presentation/finance_screen.dart';
import '../features/stores/presentation/stores_screen.dart';
import '../features/crop_recommendation/presentation/recommendation_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../l10n/app_localizations.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.value != null;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (isLoading) return null;

      // If user is not authenticated and is trying to access protected shell
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // If user is authenticated and is on login/register screen
      if (isAuthenticated && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      // Authentication Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main App Shell Route
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // 0: Dashboard (Home)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // 1: Farm
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/farm',
                builder: (context, state) => const FarmScreen(),
              ),
            ],
          ),
          // 2: Scan Plant
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/scan',
                builder: (context, state) => const ScanScreen(),
              ),
            ],
          ),
          // 3: AI Assistant
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/assistant',
                builder: (context, state) => const AssistantScreen(),
              ),
            ],
          ),
          // 4: More Hub / Navigation
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'weather',
                    builder: (context, state) => const WeatherScreen(),
                  ),
                  GoRoute(
                    path: 'lifecycle',
                    builder: (context, state) => const LifecycleScreen(),
                  ),
                  GoRoute(
                    path: 'finance',
                    builder: (context, state) => const FinanceScreen(),
                  ),
                  GoRoute(
                    path: 'stores',
                    builder: (context, state) => const StoresScreen(),
                  ),
                  GoRoute(
                    path: 'recommendations',
                    builder: (context, state) => const RecommendationScreen(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              extended: MediaQuery.of(context).size.width >= 1100,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.eco, color: Color(0xFF1B5E20), size: 32),
                    if (MediaQuery.of(context).size.width >= 1100) ...[
                      const SizedBox(width: 8),
                      Text(
                        l10n.appTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: Text(l10n.home),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.grass_outlined),
                  selectedIcon: const Icon(Icons.grass),
                  label: Text(l10n.farm),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.document_scanner_outlined),
                  selectedIcon: const Icon(Icons.document_scanner),
                  label: Text(l10n.scan),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.smart_toy_outlined),
                  selectedIcon: const Icon(Icons.smart_toy),
                  label: Text(l10n.assistant),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.more_horiz_outlined),
                  selectedIcon: const Icon(Icons.more_horiz),
                  label: Text(l10n.more),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.grass_outlined),
            selectedIcon: const Icon(Icons.grass),
            label: l10n.farm,
          ),
          NavigationDestination(
            icon: const Icon(Icons.document_scanner_outlined),
            selectedIcon: const Icon(Icons.document_scanner),
            label: l10n.scan,
          ),
          NavigationDestination(
            icon: const Icon(Icons.smart_toy_outlined),
            selectedIcon: const Icon(Icons.smart_toy),
            label: l10n.assistant,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz_outlined),
            selectedIcon: const Icon(Icons.more_horiz),
            label: l10n.more,
          ),
        ],
      ),
    );
  }
}
