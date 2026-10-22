import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/expiry/presentation/screens/expiry_calendar_screen.dart';
import '../../features/inventory/presentation/screens/food_details_screen.dart';
import '../../features/inventory/presentation/screens/food_form_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/recipes/presentation/screens/recipe_details_screen.dart';
import '../../features/recipes/presentation/screens/recipes_screen.dart';
import '../../features/scan/presentation/screens/scan_workflow_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../presentation/screens/main_shell_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Centralized declarative routing configuration for all primary tabs and secondary workflows.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    routes: [
      // 1. Primary Bottom Navigation Stateful Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inventory',
                name: 'inventory',
                builder: (context, state) => const InventoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/expiry',
                name: 'expiry',
                builder: (context, state) => const ExpiryCalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/recipes',
                name: 'recipes',
                builder: (context, state) => const RecipesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // 2. Authentication Secondary Routes
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // 3. Inventory Details & Form Secondary Routes
      GoRoute(
        path: '/food-details/:id',
        name: 'food-details',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return FoodDetailsScreen(itemId: id);
        },
      ),
      GoRoute(
        path: '/food-form',
        name: 'food-form',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return FoodFormScreen(itemId: id);
        },
      ),

      // 4. IN / OUT Camera Capture & Review Flow
      GoRoute(
        path: '/scan-workflow',
        name: 'scan-workflow',
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'in';
          return ScanWorkflowScreen(initialMode: mode);
        },
      ),

      // 5. Recipe Details
      GoRoute(
        path: '/recipe-details/:id',
        name: 'recipe-details',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return RecipeDetailsScreen(recipeId: id);
        },
      ),

      // 6. Notification Center
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
});
